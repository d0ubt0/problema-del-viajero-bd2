#!/bin/bash
set -e

CONTAINER_NAME="neo4j-tsp-local"
CYPHER_SHELL="docker exec $CONTAINER_NAME cypher-shell -u neo4j -p password123"
RESULTS_FILE="results.txt"

echo "=== Punto 2: Neo4j Local - TSP Brute Force ===" | tee "$RESULTS_FILE"
echo "Fecha: $(date)" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

echo "[1/5] Levantando contenedor Neo4j..."
docker compose up -d --build

echo "[2/5] Esperando que Neo4j esté listo..."
for i in $(seq 1 60); do
    if docker exec "$CONTAINER_NAME" cypher-shell -u neo4j -p password123 "RETURN 1" > /dev/null 2>&1; then
        echo "Neo4j listo después de ${i}s"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "ERROR: Neo4j no respondió en 60s"
        docker compose logs
        exit 1
    fi
    sleep 2
done

echo "[3/5] Cargando grafo (setup.cypher)..."
docker exec -i "$CONTAINER_NAME" cypher-shell -u neo4j -p password123 < setup.cypher
echo "Grafo cargado correctamente."

echo "[4/5] Ejecutando consultas TSP..."
echo "" | tee -a "$RESULTS_FILE"

for size in 4 6 8 10 12 14 16 18 20; do
    echo "--- TSP ${size} ciudades ---" | tee -a "$RESULTS_FILE"

    python3 generate_tsp.py "$size" > /tmp/tsp_query.cypher

    START_TIME=$(date +%s%N)
    RESULT=$(docker exec -i "$CONTAINER_NAME" cypher-shell -u neo4j -p password123 --format plain < /tmp/tsp_query.cypher 2>&1) || true
    END_TIME=$(date +%s%N)

    ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

    echo "Tiempo: ${ELAPSED_MS}ms" | tee -a "$RESULTS_FILE"
    echo "Resultado:" | tee -a "$RESULTS_FILE"
    echo "$RESULT" | tee -a "$RESULTS_FILE"
    echo "" | tee -a "$RESULTS_FILE"

    if [ "$size" -ge 12 ]; then
        echo "(Nota: TSP con ${size} ciudades por fuerza bruta puede tardar mucho o no completar)" | tee -a "$RESULTS_FILE"
    fi
done

echo "[5/5] Deteniendo contenedor..."
docker compose down

echo "" | tee -a "$RESULTS_FILE"
echo "=== Ejecución completada ===" | tee -a "$RESULTS_FILE"
echo "Resultados guardados en $RESULTS_FILE"
