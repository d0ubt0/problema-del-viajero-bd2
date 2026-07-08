#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_NAME="tsp_mongodb"
TIMEOUT_SECS=3600
CSV_FILE="${SCRIPT_DIR}/resultados.csv"

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

print_summary() {
    echo ""
    echo "================================================================"
    echo " TABLA RESUMEN - Punto 4: MongoDB (Held-Karp DP)"
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
    echo "ciudades,tiempo_segundos,costo,ruta,estado,error" > "$CSV_FILE"
    for i in "${!RES_N[@]}"; do
        echo "${RES_N[$i]},${RES_T[$i]},${RES_C[$i]},\"${RES_R[$i]//\"/\"\"}\",${RES_E[$i]},\"${RES_ERR[$i]//\"/\"\"}\"" >> "$CSV_FILE"
    done
    echo "Resultados exportados a: $CSV_FILE"
}

cleanup() {
    echo ""
    echo "Deteniendo contenedor..."
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" down 2>/dev/null
}
trap cleanup EXIT

echo "[1/4] Levantando contenedor MongoDB..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d --build

echo "[2/4] Esperando que MongoDB este listo..."
for i in $(seq 1 30); do
    if docker exec "$CONTAINER_NAME" mongosh --quiet --eval "db.runCommand({ping:1})" 2>/dev/null | grep -q "ok"; then
        echo "MongoDB listo despues de $((i*2))s"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: MongoDB no respondio en 60s"
        exit 1
    fi
    sleep 2
done

echo "[3/4] Cargando datos (setup.js)..."
docker exec "$CONTAINER_NAME" mongosh --quiet /docker-entrypoint-initdb.d/setup.js
echo "Datos cargados."

echo "[4/4] Ejecutando pruebas TSP..."
docker cp "$SCRIPT_DIR/tsp.js" "${CONTAINER_NAME}:/tmp/tsp.js"
echo ""

N=4
STOP=false

while [ "$STOP" = false ]; do
    echo "=========================================="
    echo " TSP ${N} ciudades"
    echo "=========================================="

    START_TIME=$(date +%s.%N)
    RESULT=$(timeout "$TIMEOUT_SECS" docker exec "$CONTAINER_NAME" mongosh --quiet --eval "var N=${N}" /tmp/tsp.js 2>&1)
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
        HK_SECTION=$(echo "$RESULT" | grep -A10 "\[Held-Karp DP\]")
        COSTO=$(echo "$HK_SECTION" | grep "Distancia total:" | grep -o '[0-9]\+' | head -1)
        RUTA=$(echo "$HK_SECTION" | grep "Ruta optima:" | sed 's/Ruta optima: //')

        if [ -z "$COSTO" ]; then
            ERR_MSG=$(echo "$RESULT" | tr '\n' ' ' | head -c 200)
            add_result "$N" "$ELAPSED" "-" "-" "ERROR" "No se pudo parsear resultado"
            echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - No se pudo parsear resultado"
            STOP=true
        else
            add_result "$N" "$ELAPSED" "$COSTO" "$RUTA" "OK" ""
            echo "  Ciudades: $N | Tiempo: ${ELAPSED}s | Costo: $COSTO | Ruta: $RUTA | Estado: OK"
        fi
    fi

    N=$((N + 2))
done

print_summary
export_csv
echo ""
echo "Limite practico alcanzado: ${RES_N[-1]} ciudades"
