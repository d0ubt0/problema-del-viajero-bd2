#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Construyendo imagen Docker..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" build

echo "Ejecutando TSP Óptimo..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up --abort-on-container-exit

docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
