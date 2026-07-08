#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMEOUT_SECS=3600
CSV_FILE="${SCRIPT_DIR}/resultados.csv"

NEO4J_URI="${NEO4J_URI:-bolt://localhost:7687}"
NEO4J_USER="${NEO4J_USER:-neo4j}"
NEO4J_PASS="${NEO4J_PASS:-neo4j}"

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
    echo " TABLA RESUMEN - Punto 1: Neo4j Aura (Cypher Brute Force)"
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

if ! command -v cypher-shell &>/dev/null; then
    echo "ERROR: cypher-shell no encontrado. Instalar Neo4j tools o configurar PATH."
    exit 1
fi

N=4
STOP=false

while [ "$STOP" = false ]; do
    echo "=========================================="
    echo " TSP ${N} ciudades"
    echo "=========================================="

    QUERY=$(python3 "$SCRIPT_DIR/generate_tsp.py" "$N" 2>&1)
    if [ $? -ne 0 ]; then
        add_result "$N" "ERROR" "-" "-" "ERROR" "Error generando query"
        echo "  Estado: ERROR - Error generando query"
        STOP=true
        break
    fi

    START_TIME=$(date +%s.%N)
    RESULT=$(timeout "$TIMEOUT_SECS" cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USER" -p "$NEO4J_PASS" --format plain <<< "$QUERY" 2>&1)
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
        DATA_LINE=$(echo "$RESULT" | grep -E '^\s*[0-9]' | tail -1)
        if [ -z "$DATA_LINE" ]; then
            add_result "$N" "$ELAPSED" "-" "-" "ERROR" "Sin resultados"
            echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - Sin resultados"
            STOP=true
        else
            COSTO=$(echo "$DATA_LINE" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$1); print $1}')
            RUTA=$(echo "$DATA_LINE" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
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
