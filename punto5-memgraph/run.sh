#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_NAME="memgraph-tsp"
BOLT_PORT=7687
RESULTS_FILE="$SCRIPT_DIR/results.txt"

echo "=== Punto 5: MemGraph TSP ===" > "$RESULTS_FILE"
echo "Fecha: $(date)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

echo "[1/6] Levantando contenedor MemGraph..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d --build

echo "[2/6] Esperando a que MemGraph esté listo..."
MAX_RETRIES=30
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if docker exec "$CONTAINER_NAME" mgconsole --no-history -c "RETURN 1;" > /dev/null 2>&1; then
        echo "MemGraph está listo."
        break
    fi
    RETRY=$((RETRY + 1))
    echo "  Intento $RETRY/$MAX_RETRIES..."
    sleep 2
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "ERROR: MemGraph no respondió a tiempo."
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" logs
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
    exit 1
fi

echo "[3/6] Ejecutando setup.cypher..."
docker exec -i "$CONTAINER_NAME" mgconsole --no-history < "$SCRIPT_DIR/setup.cypher"
echo "Grafo cargado correctamente."

echo "[4/6] Verificando datos..."
docker exec "$CONTAINER_NAME" mgconsole --no-history -c "MATCH (c:Ciudad) RETURN count(c) AS ciudades;"
docker exec "$CONTAINER_NAME" mgconsole --no-history -c "MATCH ()-[r:RUTA]->() RETURN count(r) AS rutas;"

echo "[5/6] Ejecutando consultas TSP (fuerza bruta Cypher)..."
echo "" >> "$RESULTS_FILE"
echo "--- Resultados TSP con MemGraph (fuerza bruta Cypher) ---" >> "$RESULTS_FILE"

for N in 4 6 8 10 12 14 16 18 20; do
    echo "  Generando y ejecutando TSP para $N ciudades..."
    python3 "$SCRIPT_DIR/generate_tsp.py" "$N" > /tmp/tsp_query.cypher

    START_TIME=$(date +%s%N)
    RESULT=$(docker exec -i "$CONTAINER_NAME" mgconsole --no-history < /tmp/tsp_query.cypher 2>&1)
    END_TIME=$(date +%s%N)
    ELAPSED=$(( (END_TIME - START_TIME) / 1000000 ))

    echo "    Tiempo: ${ELAPSED}ms"
    echo "    Resultado: $RESULT"

    echo "TSP $N ciudades | Tiempo: ${ELAPSED}ms" >> "$RESULTS_FILE"
    echo "  $RESULT" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
done

echo "[6/6] Probando módulo MAGE (tsp_mage.py)..."
echo "--- Resultados TSP con módulo MAGE ---" >> "$RESULTS_FILE"

for N in 4 6 8 10 12 14 16 18 20; do
    CITY_IDS=$(python3 -c "
import json
with open('$SCRIPT_DIR/../shared/ciudades.json') as f:
    data = json.load(f)
print(','.join(str(x) for x in data['subsets']['$N']))
")

    echo "  MAGE brute_force para $N ciudades..."
    START_TIME=$(date +%s%N)
    RESULT=$(docker exec "$CONTAINER_NAME" mgconsole --no-history -c "CALL tsp_mage.brute_force([$CITY_IDS]) YIELD distancia_total, ruta;" 2>&1) || true
    END_TIME=$(date +%s%N)
    ELAPSED=$(( (END_TIME - START_TIME) / 1000000 ))
    echo "    Tiempo: ${ELAPSED}ms"
    echo "MAGE brute_force $N ciudades | Tiempo: ${ELAPSED}ms" >> "$RESULTS_FILE"
    echo "  $RESULT" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"

    echo "  MAGE held_karp para $N ciudades..."
    START_TIME=$(date +%s%N)
    RESULT=$(docker exec "$CONTAINER_NAME" mgconsole --no-history -c "CALL tsp_mage.held_karp([$CITY_IDS]) YIELD distancia_total, ruta;" 2>&1) || true
    END_TIME=$(date +%s%N)
    ELAPSED=$(( (END_TIME - START_TIME) / 1000000 ))
    echo "    Tiempo: ${ELAPSED}ms"
    echo "MAGE held_karp $N ciudades | Tiempo: ${ELAPSED}ms" >> "$RESULTS_FILE"
    echo "  $RESULT" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
done

echo "" >> "$RESULTS_FILE"
echo "=== Ejecución completada ===" >> "$RESULTS_FILE"

echo ""
echo "=== Resultados guardados en $RESULTS_FILE ==="
cat "$RESULTS_FILE"

echo "Deteniendo contenedor..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
