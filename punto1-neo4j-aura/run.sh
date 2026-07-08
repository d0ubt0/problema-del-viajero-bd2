#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for N in 4 6 8 10 12 14 16 18 20; do
    echo "=========================================="
    echo " TSP ${N} ciudades"
    echo "=========================================="
    QUERY=$(python3 "$SCRIPT_DIR/generate_tsp.py" "$N")
    echo "$QUERY"
    echo ""

    if command -v cypher-shell &>/dev/null; then
        echo "Ejecutando con cypher-shell..."
        echo "$QUERY" | time cypher-shell -a "${NEO4J_URI:-bolt://localhost:7687}" \
            -u "${NEO4J_USER:-neo4j}" \
            -p "${NEO4J_PASS:-neo4j}" 2>&1
        echo ""
    else
        echo "cypher-shell no encontrado. Copia la consulta anterior y pégala en Neo4j Browser."
        echo ""
    fi
done
