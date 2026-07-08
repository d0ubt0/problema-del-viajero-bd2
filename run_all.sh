#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="${ROOT_DIR}/resultados"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
SUMMARY_FILE="${RESULTS_DIR}/resumen_${TIMESTAMP}.txt"

mkdir -p "$RESULTS_DIR"

echo "================================================================"
echo " PROBLEMA DEL VIAJERO - EJECUCION COMPLETA"
echo " Fecha: $(date)"
echo "================================================================"
echo ""

check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: '$1' no encontrado. Instalar $1 primero."
        echo "  $2"
        return 1
    fi
}

check_cmd python3 "apt install python3"
check_cmd docker  "https://docs.docker.com/engine/install/"
check_cmd docker compose "apt install docker-compose-plugin"

mkdir -p "$RESULTS_DIR/punto2" "$RESULTS_DIR/punto3" "$RESULTS_DIR/punto4" "$RESULTS_DIR/punto5" "$RESULTS_DIR/punto6"

# =============================================================
# PUNTO 2: Neo4j Local
# =============================================================
run_punto2() {
    echo ""
    echo "================================================================"
    echo " PUNTO 2: Neo4j Local"
    echo "================================================================"
    cd "$ROOT_DIR/punto2-neo4j-local" || return

    docker compose down 2>/dev/null
    docker compose up -d --build

    echo "  Esperando Neo4j..."
    for i in $(seq 1 60); do
        if docker exec neo4j-tsp-local cypher-shell -u neo4j -p password123 "RETURN 1" > /dev/null 2>&1; then
            echo "  Neo4j listo tras ${i}s"
            break
        fi
        if [ "$i" -eq 60 ]; then
            echo "  ERROR: Neo4j no respondio"
            docker compose down 2>/dev/null
            return
        fi
        sleep 2
    done

    echo "  Cargando grafo..."
    docker exec -i neo4j-tsp-local cypher-shell -u neo4j -p password123 < setup.cypher

    echo "  Ejecutando TSP..."
    for N in 4 6 8 10; do
        echo -n "    N=${N}... "
        QUERY=$(python3 generate_tsp.py "$N" 2>/dev/null)
        START=$(date +%s.%N)
        RESULT=$(echo "$QUERY" | timeout 300 docker exec -i neo4j-tsp-local cypher-shell -u neo4j -p password123 --format plain 2>&1)
        RC=$?
        END=$(date +%s.%N)
        ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END - $START}")
        if [ $RC -eq 124 ]; then
            echo "TIMEOUT (300s)"
            break
        elif [ $RC -ne 0 ]; then
            echo "ERROR"
            break
        else
            COSTO=$(echo "$RESULT" | grep -E '^\s*[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$1); print $1}')
            RUTA=$(echo "$RESULT" | grep -E '^\s*[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
            echo "OK (${ELAPSED}s, ${COSTO}km)"
            echo "${N},${ELAPSED},${COSTO},\"${RUTA}\"" >> "$RESULTS_DIR/punto2/resultados.csv"
        fi
    done

    docker compose down 2>/dev/null
}

# =============================================================
# PUNTO 3: Python Optimal
# =============================================================
run_punto3() {
    echo ""
    echo "================================================================"
    echo " PUNTO 3: Python Optimo (Held-Karp)"
    echo "================================================================"
    cd "$ROOT_DIR/punto3-python-optimo" || return

    python3 tsp_optimo.py 2>&1 | tee "$RESULTS_DIR/punto3/salida.txt"
    echo "  Resultados guardados en $RESULTS_DIR/punto3/"
}

# =============================================================
# PUNTO 4: MongoDB
# =============================================================
run_punto4() {
    echo ""
    echo "================================================================"
    echo " PUNTO 4: MongoDB"
    echo "================================================================"
    cd "$ROOT_DIR/punto4-mongodb" || return

    docker compose down 2>/dev/null
    docker compose up -d --build

    echo "  Esperando MongoDB..."
    for i in $(seq 1 30); do
        if docker exec tsp_mongodb mongosh --quiet --eval "db.runCommand({ping:1})" 2>/dev/null | grep -q "ok"; then
            echo "  MongoDB listo tras ${i}s"
            break
        fi
        if [ "$i" -eq 30 ]; then
            echo "  ERROR: MongoDB no respondio"
            docker compose down 2>/dev/null
            return
        fi
        sleep 2
    done

    echo "  Cargando datos..."
    docker exec tsp_mongodb mongosh --quiet /docker-entrypoint-initdb.d/setup.js
    docker cp tsp.js tsp_mongodb:/tmp/tsp.js

    echo "  Ejecutando TSP..."
    for N in 4 6 8 10; do
        echo -n "    N=${N}... "
        START=$(date +%s.%N)
        RESULT=$(timeout 300 docker exec tsp_mongodb mongosh --quiet --eval "var N=${N}" /tmp/tsp.js 2>&1)
        RC=$?
        END=$(date +%s.%N)
        ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END - $START}")
        if [ $RC -eq 124 ]; then
            echo "TIMEOUT (300s)"
            break
        elif [ $RC -ne 0 ]; then
            echo "ERROR"
            break
        else
            COSTO=$(echo "$RESULT" | grep "Distancia total:" | grep -o '[0-9]\+' | head -1)
            RUTA=$(echo "$RESULT" | grep "Ruta optima:" | tail -1)
            echo "OK (${ELAPSED}s, ${COSTO}km)"
            echo "${N},${ELAPSED},${COSTO},\"${RUTA}\"" >> "$RESULTS_DIR/punto4/resultados.csv"
        fi
    done

    docker compose down 2>/dev/null
}

# =============================================================
# PUNTO 5: MemGraph
# =============================================================
run_punto5() {
    echo ""
    echo "================================================================"
    echo " PUNTO 5: MemGraph"
    echo "================================================================"
    cd "$ROOT_DIR/punto5-memgraph" || return

    docker compose down 2>/dev/null
    docker compose up -d --build

    echo "  Esperando MemGraph..."
    for i in $(seq 1 30); do
        if docker exec memgraph-tsp mgconsole --no-history -c "RETURN 1;" > /dev/null 2>&1; then
            echo "  MemGraph listo tras ${i}s"
            break
        fi
        if [ "$i" -eq 30 ]; then
            echo "  ERROR: MemGraph no respondio"
            docker compose down 2>/dev/null
            return
        fi
        sleep 2
    done

    echo "  Cargando grafo..."
    docker exec -i memgraph-tsp mgconsole --no-history < setup.cypher

    echo "  Ejecutando TSP (Cypher brute force)..."
    for N in 4 6 8 10; do
        echo -n "    N=${N} (Cypher)... "
        QUERY=$(python3 generate_tsp.py "$N" 2>/dev/null)
        START=$(date +%s.%N)
        RESULT=$(echo "$QUERY" | timeout 300 docker exec -i memgraph-tsp mgconsole --no-history 2>&1)
        RC=$?
        END=$(date +%s.%N)
        ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END - $START}")
        if [ $RC -eq 124 ]; then
            echo "TIMEOUT (300s)"
            break
        elif [ $RC -ne 0 ]; then
            echo "ERROR"
            break
        else
            COSTO=$(echo "$RESULT" | grep -E '^\| *[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}' | tail -1)
            RUTA=$(echo "$RESULT" | grep -E '^\| *[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}' | tail -1)
            echo "OK (${ELAPSED}s, ${COSTO}km)"
            echo "${N},${ELAPSED},${COSTO},\"${RUTA}\"" >> "$RESULTS_DIR/punto5/resultados_cypher.csv"
        fi
    done

    echo "  Ejecutando TSP (MAGE brute_force)..."
    for N in 4 6 8 10; do
        echo -n "    N=${N} (MAGE)... "
        CITY_IDS=$(python3 -c "
import json
with open('$ROOT_DIR/shared/ciudades.json') as f:
    data = json.load(f)
print(','.join(str(x) for x in data['subsets'][str($N)]))
" 2>&1)
        START=$(date +%s.%N)
        RESULT=$(timeout 300 docker exec memgraph-tsp mgconsole --no-history -c "CALL tsp_mage.brute_force([${CITY_IDS}]) YIELD distancia_total, ruta;" 2>&1)
        RC=$?
        END=$(date +%s.%N)
        ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END - $START}")
        if [ $RC -eq 124 ]; then
            echo "TIMEOUT (300s)"
            break
        elif [ $RC -ne 0 ]; then
            echo "ERROR"
            break
        else
            COSTO=$(echo "$RESULT" | grep -E '^\| *[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}' | tail -1)
            RUTA=$(echo "$RESULT" | grep -E '^\| *[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}' | tail -1)
            echo "OK (${ELAPSED}s, ${COSTO}km)"
            echo "${N},${ELAPSED},${COSTO},\"${RUTA}\"" >> "$RESULTS_DIR/punto5/resultados_mage_bf.csv"
        fi
    done

    echo "  Ejecutando TSP (MAGE held_karp)..."
    for N in 4 6 8 10 12 14 16 18 20; do
        echo -n "    N=${N} (HK)... "
        CITY_IDS=$(python3 -c "
import json
with open('$ROOT_DIR/shared/ciudades.json') as f:
    data = json.load(f)
print(','.join(str(x) for x in data['subsets'][str($N)]))
" 2>&1)
        START=$(date +%s.%N)
        RESULT=$(timeout 300 docker exec memgraph-tsp mgconsole --no-history -c "CALL tsp_mage.held_karp([${CITY_IDS}]) YIELD distancia_total, ruta;" 2>&1)
        RC=$?
        END=$(date +%s.%N)
        ELAPSED=$(awk "BEGIN {printf \"%.4f\", $END - $START}")
        if [ $RC -eq 124 ]; then
            echo "TIMEOUT (300s)"
            break
        elif [ $RC -ne 0 ]; then
            echo "ERROR"
            break
        else
            COSTO=$(echo "$RESULT" | grep -E '^\| *[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}' | tail -1)
            RUTA=$(echo "$RESULT" | grep -E '^\| *[0-9]' | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}' | tail -1)
            echo "OK (${ELAPSED}s, ${COSTO}km)"
            echo "${N},${ELAPSED},${COSTO},\"${RUTA}\"" >> "$RESULTS_DIR/punto5/resultados_mage_hk.csv"
        fi
    done

    docker compose down 2>/dev/null
}

# =============================================================
# PUNTO 6: Python Heuristico
# =============================================================
run_punto6() {
    echo ""
    echo "================================================================"
    echo " PUNTO 6: Python Heuristico"
    echo "================================================================"
    cd "$ROOT_DIR/punto6-python-heuristico" || return

    python3 tsp_heuristico.py 2>&1 | tee "$RESULTS_DIR/punto6/salida.txt"
    echo "  Resultados guardados en $RESULTS_DIR/punto6/"
}

# =============================================================
# Resumen final
# =============================================================
make_summary() {
    echo ""
    echo "================================================================"
    echo " RESUMEN COMPARATIVO"
    echo "================================================================"
    {
        echo "================================================================"
        echo " RESULTADOS - $(date)"
        echo "================================================================"
        echo ""

        echo "--- Punto 3: Python Optimo ---"
        if [ -f "$RESULTS_DIR/punto3/salida.txt" ]; then
            grep -E "Fuerza Bruta:|Held-Karp:|n=" "$RESULTS_DIR/punto3/salida.txt"
        fi
        echo ""

        echo "--- Punto 6: Python Heuristico ---"
        if [ -f "$RESULTS_DIR/punto6/salida.txt" ]; then
            grep -E "^\|" "$RESULTS_DIR/punto6/salida.txt" | head -20
        fi
        echo ""

        echo "--- Punto 2: Neo4j Local ---"
        [ -f "$RESULTS_DIR/punto2/resultados.csv" ] && cat "$RESULTS_DIR/punto2/resultados.csv" || echo "  Sin datos"
        echo ""

        echo "--- Punto 4: MongoDB ---"
        [ -f "$RESULTS_DIR/punto4/resultados.csv" ] && cat "$RESULTS_DIR/punto4/resultados.csv" || echo "  Sin datos"
        echo ""

        echo "--- Punto 5: MemGraph ---"
        echo "  Cypher BF:"
        [ -f "$RESULTS_DIR/punto5/resultados_cypher.csv" ] && cat "$RESULTS_DIR/punto5/resultados_cypher.csv" || echo "    Sin datos"
        echo "  MAGE BF:"
        [ -f "$RESULTS_DIR/punto5/resultados_mage_bf.csv" ] && cat "$RESULTS_DIR/punto5/resultados_mage_bf.csv" || echo "    Sin datos"
        echo "  MAGE HK:"
        [ -f "$RESULTS_DIR/punto5/resultados_mage_hk.csv" ] && cat "$RESULTS_DIR/punto5/resultados_mage_hk.csv" || echo "    Sin datos"

        echo ""
        echo "--- Cuadro Comparativo ---"
        printf "%-12s | %-14s | %-14s | %-14s | %-14s | %-14s | %-14s\n" "Ciudades" "P2: Neo4jL" "P3: PyOpt" "P4: Mongo" "P5: Cypher" "P5: MAGEbf" "P6: Heur"
        echo "-----------------------------------------------------------------------------------------"
        for N in 4 6 8 10; do
            p2=$(grep "^${N}," "$RESULTS_DIR/punto2/resultados.csv" 2>/dev/null | cut -d',' -f3 || echo "-")
            p3=$(grep " ${N} " "$RESULTS_DIR/punto3/salida.txt" 2>/dev/null | grep "HK Distancia" || echo "-")
            p4=$(grep "^${N}," "$RESULTS_DIR/punto4/resultados.csv" 2>/dev/null | cut -d',' -f3 || echo "-")
            p5c=$(grep "^${N}," "$RESULTS_DIR/punto5/resultados_cypher.csv" 2>/dev/null | cut -d',' -f3 || echo "-")
            p5m=$(grep "^${N}," "$RESULTS_DIR/punto5/resultados_mage_bf.csv" 2>/dev/null | cut -d',' -f3 || echo "-")
            p6=$(grep "^\|" "$RESULTS_DIR/punto6/salida.txt" 2>/dev/null | grep " 2-opt " | head -1 || echo "-")
            printf "%-12s | %-14s | %-14s | %-14s | %-14s | %-14s | %-14s\n" "$N" "$p2" "$p3" "$p4" "$p5c" "$p5m" "$p6"
        done
    } | tee "$SUMMARY_FILE"
    echo ""
    echo "Resumen completo guardado en: $SUMMARY_FILE"
}

# =============================================================
# MAIN
# =============================================================
case "${1:-all}" in
    all)
        run_punto2
        run_punto3
        run_punto4
        run_punto5
        run_punto6
        make_summary
        ;;
    punto2) run_punto2 ;;
    punto3) run_punto3 ;;
    punto4) run_punto4 ;;
    punto5) run_punto5 ;;
    punto6) run_punto6 ;;
    summary) make_summary ;;
    *)
        echo "Uso: $0 [all|punto2|punto3|punto4|punto5|punto6|summary]"
        echo "  all     - Ejecuta todo (default)"
        echo "  summary - Solo genera resumen de resultados existentes"
        exit 1
        ;;
esac
