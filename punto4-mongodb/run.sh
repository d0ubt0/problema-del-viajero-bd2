#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER_NAME="tsp_mongodb"
RESULTS_FILE="${SCRIPT_DIR}/results.txt"

echo "=== Punto 4: TSP con MongoDB ==="
echo ""

echo "Levantando contenedor MongoDB..."
docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d --build

echo "Esperando a que MongoDB esté listo..."
for i in $(seq 1 30); do
  if docker exec ${CONTAINER_NAME} mongosh --quiet --eval "db.runCommand({ping:1})" 2>/dev/null | grep -q "ok"; then
    echo "MongoDB está listo."
    break
  fi
  sleep 2
done

echo "Ejecutando setup.js..."
docker exec ${CONTAINER_NAME} mongosh --quiet /docker-entrypoint-initdb.d/setup.js

echo ""
echo "=== Ejecutando scripts TSP ===" | tee "${RESULTS_FILE}"
echo "Fecha: $(date)" >> "${RESULTS_FILE}"
echo "" >> "${RESULTS_FILE}"

echo "Copiando tsp.js al contenedor..."
docker cp "${SCRIPT_DIR}/tsp.js" ${CONTAINER_NAME}:/tmp/tsp.js

SIZES=(4 6 8 10 12 14 16 18 20)

for N in "${SIZES[@]}"; do
  echo "----------------------------------------"
  echo "Ejecutando TSP con N=${N}..."
  echo "--- N=${N} ---" >> "${RESULTS_FILE}"
  docker exec ${CONTAINER_NAME} mongosh --quiet --eval "var N=${N}" /tmp/tsp.js 2>&1 | tee -a "${RESULTS_FILE}"
  echo "" >> "${RESULTS_FILE}"
done

echo "----------------------------------------"
echo ""
echo "=== Todos los scripts ejecutados ==="
echo "Resultados en: ${RESULTS_FILE}"

read -p "Desea detener el contenedor? (s/n): " stop
if [ "$stop" = "s" ] || [ "$stop" = "S" ]; then
  echo "Deteniendo contenedor..."
  docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down
fi
