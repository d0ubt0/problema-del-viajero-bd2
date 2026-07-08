#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Punto 6: TSP Heurístico con Python ==="
echo ""

if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo "Ejecutando con Docker..."
    cd "$SCRIPT_DIR"
    docker compose up --build
elif command -v docker &> /dev/null; then
    echo "Ejecutando con Docker..."
    cd "$SCRIPT_DIR"
    docker compose up --build
else
    echo "Docker no disponible, ejecutando localmente..."
    cd "$SCRIPT_DIR"
    python3 tsp_heuristico.py
fi
