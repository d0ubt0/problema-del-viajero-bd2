#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_NAME="memgraph-tsp"
TIMEOUT_SECS=3600

RES_N=()
RES_T=()
RES_C=()
RES_R=()
RES_E=()
RES_ERR=()

add_result() {
    RES_N+=("$1"); RES_T+=("$2"); RES_C+=("$3")
    RES_R+=("$4"); RES_E+=("$5"); RES_ERR+=("$6")
}

reset_results() {
    RES_N=(); RES_T=(); RES_C=(); RES_R=(); RES_E=(); RES_ERR=()
}

print_summary() {
    local title="$1"
    echo ""
    echo "================================================================"
    echo " TABLA RESUMEN - $title"
    echo "================================================================"
    printf "%-10s | %-12s | %-8s | %s\n" "Ciudades" "Tiempo(s)" "Costo" "Estado"
    echo "----------------------------------------------------------------"
    for i in "${!RES_N[@]}"; do
        if [ "${RES_E[$i]}" = "ERROR" ]; then
            printf "%-10s | %-12s | %-8s | %s\n" "${RES_N[$i]}" "ERROR" "-" "${RES_ERR[$i]}"
        else
            printf "%-10s | %-12s | %-8s | %s\n" "${RES_N[$i]}" "${RES_T[$i]}" "${RES_C[$i]}" "${RES_E[$i]}"
        fi
    done
}

export_csv() {
    local csv_file="$1"
    echo "ciudades,tiempo_segundos,costo,ruta,estado,error" > "$csv_file"
    for i in "${!RES_N[@]}"; do
        echo "${RES_N[$i]},${RES_T[$i]},${RES_C[$i]},\"${RES_R[$i]//\"/\"\"}\",${RES_E[$i]},\"${RES_ERR[$i]//\"/\"\"}\"" >> "$csv_file"
    done
    echo "Resultados exportados a: $csv_file"
}

parse_mgconsole_result() {
    local result="$1"
    local costo="" ruta="" data_line=""

    data_line=$(echo "$result" | grep -E '^\| *[0-9]' | tail -1)
    if [ -n "$data_line" ]; then
        costo=$(echo "$data_line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
        ruta=$(echo "$data_line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}')
    fi

    if [ -z "$costo" ]; then
        data_line=$(echo "$result" | grep -E '^\s*[0-9]+\s*\|' | tail -1)
        if [ -n "$data_line" ]; then
            costo=$(echo "$data_line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$1); print $1}')
            ruta=$(echo "$data_line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
        fi
    fi

    if [ -z "$costo" ] || [ -z "$ruta" ]; then
        echo "ERROR|Sin resultados|"
        return
    fi
    echo "OK|$costo|$ruta"
}

get_city_ids() {
    local n="$1"
    python3 -c "
import json
with open('$SCRIPT_DIR/../shared/ciudades.json') as f:
    data = json.load(f)
key = str($n)
if key not in data['subsets']:
    exit(1)
print(','.join(str(x) for x in data['subsets'][key]))
" 2>&1
}

cleanup() {
    echo ""
    echo "Deteniendo contenedor..."
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" down 2>/dev/null
}
trap cleanup EXIT

echo "[1/5] Levantando contenedor MemGraph..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d --build || {
    echo "ERROR: No se pudo levantar el contenedor MemGraph"
    exit 1
}

echo "[2/5] Esperando que MemGraph este listo..."
for i in $(seq 1 30); do
    if echo "RETURN 1;" | docker exec -i "$CONTAINER_NAME" mgconsole --no-history > /dev/null 2>&1; then
        echo "MemGraph listo despues de $((i*2))s"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: MemGraph no respondio en 60s"
        exit 1
    fi
    sleep 2
done

echo "[3/5] Limpiando datos previos y cargando grafo..."
docker exec -i "$CONTAINER_NAME" mgconsole --no-history < "$SCRIPT_DIR/cleanup.cypher"
docker exec -i "$CONTAINER_NAME" mgconsole --no-history < "$SCRIPT_DIR/setup.cypher"
echo "Grafo cargado."

echo "[3.5/5] Cargando modulos MAGE..."
echo "CALL mg.load_all();" | docker exec -i "$CONTAINER_NAME" mgconsole --no-history
echo "Modulos MAGE cargados."

# =========================================================================
# Bateria 1: Cypher Brute Force
# =========================================================================
echo ""
echo "================================================================"
echo "[4/5] Bateria 1: Cypher Brute Force"
echo "================================================================"

reset_results
N=4
STOP=false

while [ "$STOP" = false ]; do
    echo "--- TSP ${N} ciudades ---"

    QUERY=$(python3 "$SCRIPT_DIR/generate_tsp.py" "$N" 2>&1)
    if [ $? -ne 0 ]; then
        add_result "$N" "ERROR" "-" "-" "ERROR" "Error generando query"
        STOP=true
        break
    fi

    START_TIME=$(date +%s.%N)
    RESULT=$(echo "$QUERY" | timeout "$TIMEOUT_SECS" docker exec -i "$CONTAINER_NAME" mgconsole --no-history 2>&1)
    RC=$?
    END_TIME=$(date +%s.%N)
    ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END_TIME - $START_TIME}")

    if [ $RC -eq 124 ]; then
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "Timeout (>${TIMEOUT_SECS}s)"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - Timeout"
        STOP=true
    elif [ $RC -ne 0 ]; then
        ERR_MSG=$(echo "$RESULT" | tr '\n' ' ' | head -c 200)
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$ERR_MSG"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR"
        STOP=true
    else
        PARSED=$(parse_mgconsole_result "$RESULT")
        STATUS=$(echo "$PARSED" | cut -d'|' -f1)
        COSTO=$(echo "$PARSED" | cut -d'|' -f2)
        RUTA=$(echo "$PARSED" | cut -d'|' -f3)
        if [ "$STATUS" = "ERROR" ]; then
            add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$COSTO"
            echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - $COSTO"
            STOP=true
        else
            add_result "$N" "$ELAPSED" "$COSTO" "$RUTA" "OK" ""
            echo "  Ciudades: $N | Tiempo: ${ELAPSED}s | Costo: $COSTO | Ruta: $RUTA | Estado: OK"
        fi
    fi

    N=$((N + 2))
done

print_summary "Punto 5: MemGraph - Cypher Brute Force"
export_csv "${SCRIPT_DIR}/resultados_cypher.csv"

# =========================================================================
# Bateria 2: MAGE brute_force
# =========================================================================
echo ""
echo "================================================================"
echo "[5/5] Bateria 2: MAGE brute_force"
echo "================================================================"

reset_results
N=4
STOP=false

while [ "$STOP" = false ]; do
    echo "--- TSP ${N} ciudades ---"

    CITY_IDS=$(get_city_ids "$N")
    if [ $? -ne 0 ]; then
        add_result "$N" "ERROR" "-" "-" "ERROR" "No hay subset para N=$N"
        STOP=true
        break
    fi

    MAGE_QUERY="CALL tsp_mage.brute_force([${CITY_IDS}]) YIELD distancia_total, ruta;"

    START_TIME=$(date +%s.%N)
    RESULT=$(echo "$MAGE_QUERY" | timeout "$TIMEOUT_SECS" docker exec -i "$CONTAINER_NAME" mgconsole --no-history 2>&1)
    RC=$?
    END_TIME=$(date +%s.%N)
    ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END_TIME - $START_TIME}")

    if [ $RC -eq 124 ]; then
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "Timeout (>${TIMEOUT_SECS}s)"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - Timeout"
        STOP=true
    elif [ $RC -ne 0 ]; then
        ERR_MSG=$(echo "$RESULT" | tr '\n' ' ' | head -c 200)
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$ERR_MSG"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR"
        STOP=true
    else
        PARSED=$(parse_mgconsole_result "$RESULT")
        STATUS=$(echo "$PARSED" | cut -d'|' -f1)
        COSTO=$(echo "$PARSED" | cut -d'|' -f2)
        RUTA=$(echo "$PARSED" | cut -d'|' -f3)
        if [ "$STATUS" = "ERROR" ]; then
            add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$COSTO"
            echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - $COSTO"
            STOP=true
        else
            add_result "$N" "$ELAPSED" "$COSTO" "$RUTA" "OK" ""
            echo "  Ciudades: $N | Tiempo: ${ELAPSED}s | Costo: $COSTO | Ruta: $RUTA | Estado: OK"
        fi
    fi

    N=$((N + 2))
done

print_summary "Punto 5: MemGraph - MAGE brute_force"
export_csv "${SCRIPT_DIR}/resultados_mage_bf.csv"

# =========================================================================
# Bateria 3: MAGE held_karp
# =========================================================================
echo ""
echo "================================================================"
echo "Bateria 3: MAGE held_karp"
echo "================================================================"

reset_results
N=4
STOP=false

while [ "$STOP" = false ]; do
    echo "--- TSP ${N} ciudades ---"

    CITY_IDS=$(get_city_ids "$N")
    if [ $? -ne 0 ]; then
        add_result "$N" "ERROR" "-" "-" "ERROR" "No hay subset para N=$N"
        STOP=true
        break
    fi

    MAGE_QUERY="CALL tsp_mage.held_karp([${CITY_IDS}]) YIELD distancia_total, ruta;"

    START_TIME=$(date +%s.%N)
    RESULT=$(echo "$MAGE_QUERY" | timeout "$TIMEOUT_SECS" docker exec -i "$CONTAINER_NAME" mgconsole --no-history 2>&1)
    RC=$?
    END_TIME=$(date +%s.%N)
    ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END_TIME - $START_TIME}")

    if [ $RC -eq 124 ]; then
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "Timeout (>${TIMEOUT_SECS}s)"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - Timeout"
        STOP=true
    elif [ $RC -ne 0 ]; then
        ERR_MSG=$(echo "$RESULT" | tr '\n' ' ' | head -c 200)
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$ERR_MSG"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR"
        STOP=true
    else
        PARSED=$(parse_mgconsole_result "$RESULT")
        STATUS=$(echo "$PARSED" | cut -d'|' -f1)
        COSTO=$(echo "$PARSED" | cut -d'|' -f2)
        RUTA=$(echo "$PARSED" | cut -d'|' -f3)
        if [ "$STATUS" = "ERROR" ]; then
            add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$COSTO"
            echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - $COSTO"
            STOP=true
        else
            add_result "$N" "$ELAPSED" "$COSTO" "$RUTA" "OK" ""
            echo "  Ciudades: $N | Tiempo: ${ELAPSED}s | Costo: $COSTO | Ruta: $RUTA | Estado: OK"
        fi
    fi

    N=$((N + 2))
done

print_summary "Punto 5: MemGraph - MAGE held_karp"
export_csv "${SCRIPT_DIR}/resultados_mage_hk.csv"

echo ""
echo "================================================================"
echo "Todas las baterias completadas."
echo "Limite practico alcanzado: ${RES_N[-1]} ciudades"
echo "================================================================"
