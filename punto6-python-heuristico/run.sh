#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
    echo " TABLA RESUMEN - Punto 6: Python Heuristico (Mejor heuristica)"
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

WRAPPER=$(mktemp /tmp/tsp6_wrapper_XXXXXX.py)
trap "rm -f '$WRAPPER'" EXIT

cat > "$WRAPPER" << 'PYEOF'
import sys, os, random
sys.path.insert(0, os.environ['SCRIPT_DIR'])
random.seed(42)
from tsp_heuristico import (load_data, build_sub_matrix, tour_cost,
    nearest_neighbor, two_opt_multi, christofides,
    simulated_annealing, genetic_algorithm)

N = int(sys.argv[1])
dist, nombres, subsets, coords = load_data()
key = str(N)
if key not in subsets:
    print(f"ERROR|No hay subset para N={N}|")
    sys.exit(1)

indices = subsets[key]
sub_dist = build_sub_matrix(dist, indices)
sub_nombres = [nombres[i] for i in indices]

heuristics = [
    ("Vecino cercano", nearest_neighbor),
    ("2-opt", two_opt_multi),
    ("Christofides", christofides),
    ("Simulated Annealing", simulated_annealing),
    ("Genetico", genetic_algorithm),
]

try:
    best_cost = float('inf')
    best_route = None
    best_name = ""
    for name, func in heuristics:
        tour, cost = func(sub_dist, N)
        if cost < best_cost:
            best_cost = cost
            best_route = tour
            best_name = name
    route_names = [sub_nombres[c] for c in best_route]
    print(f"OK|{int(best_cost)}|{' -> '.join(route_names)}")
except MemoryError:
    print("ERROR|Memoria insuficiente|")
    sys.exit(1)
except Exception as e:
    print(f"ERROR|{e}|")
    sys.exit(1)
PYEOF

N=4
STOP=false

while [ "$STOP" = false ]; do
    echo "=========================================="
    echo " TSP ${N} ciudades"
    echo "=========================================="

    START_TIME=$(date +%s.%N)
    OUTPUT=$(timeout "$TIMEOUT_SECS" env SCRIPT_DIR="$SCRIPT_DIR" python3 "$WRAPPER" "$N" 2>&1)
    RC=$?
    END_TIME=$(date +%s.%N)
    ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END_TIME - $START_TIME}")

    if [ $RC -eq 124 ]; then
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "Timeout (>${TIMEOUT_SECS}s)"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - Timeout"
        STOP=true
    elif [ $RC -ne 0 ]; then
        LAST_LINE=$(echo "$OUTPUT" | tail -1)
        ERR_MSG=$(echo "$LAST_LINE" | cut -d'|' -f2)
        if [ -z "$ERR_MSG" ] || [ "$ERR_MSG" = "$LAST_LINE" ]; then
            ERR_MSG=$(echo "$OUTPUT" | tr '\n' ' ' | head -c 200)
        fi
        add_result "$N" "$ELAPSED" "-" "-" "ERROR" "$ERR_MSG"
        echo "  Tiempo: ${ELAPSED}s | Estado: ERROR - $ERR_MSG"
        STOP=true
    else
        LAST_LINE=$(echo "$OUTPUT" | tail -1)
        STATUS=$(echo "$LAST_LINE" | cut -d'|' -f1)
        COSTO=$(echo "$LAST_LINE" | cut -d'|' -f2)
        RUTA=$(echo "$LAST_LINE" | cut -d'|' -f3)

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

print_summary
export_csv
echo ""
echo "Limite practico alcanzado: ${RES_N[-1]} ciudades"
