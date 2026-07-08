# Punto 2: Neo4j Local - TSP por Fuerza Bruta

Resolución del Problema del Viajero (TSP) usando **exclusivamente Cypher** sobre una instancia local de Neo4j en Docker.

## Requisitos

- Docker y Docker Compose
- Python 3
- cypher-shell (incluido en la imagen de Neo4j)

## Estructura

| Archivo | Descripción |
|---|---|
| `Dockerfile` | Imagen Neo4j con APOC |
| `docker-compose.yml` | Servicio Neo4j con volúmenes y healthcheck |
| `setup.cypher` | Crea el grafo completo (20 ciudades, todas las rutas bidireccionales) |
| `generate_tsp.py` | Genera dinámicamente la consulta Cypher TSP para N ciudades |
| `cleanup.cypher` | Elimina todos los datos del grafo |
| `run.sh` | Script de ejecución automatizada |

## Generador de consultas

`generate_tsp.py` reemplaza los archivos estáticos `tsp_*.cypher`. Lee los subconjuntos de ciudades desde `../shared/ciudades.json` y genera la consulta Cypher de fuerza bruta para el tamaño solicitado.

```bash
# Generar consulta para 4 ciudades
python3 generate_tsp.py 4

# Generar consulta para 10 ciudades
python3 generate_tsp.py 10
```

Los subconjuntos disponibles son: 4, 6, 8, 10, 12, 14, 16, 18 y 20 ciudades.

## Ejecución rápida

```bash
chmod +x run.sh
./run.sh
```

Esto levanta Neo4j, carga el grafo, genera y ejecuta cada consulta TSP con medición de tiempo, y guarda resultados en `results.txt`.

## Ejecución manual

```bash
# Levantar Neo4j
docker compose up -d --build

# Esperar a que esté listo (~30s)
docker exec neo4j-tsp-local cypher-shell -u neo4j -p password123 "RETURN 1"

# Cargar grafo
docker exec -i neo4j-tsp-local cypher-shell -u neo4j -p password123 < setup.cypher

# Generar y ejecutar una consulta TSP
python3 generate_tsp.py 4 | docker exec -i neo4j-tsp-local cypher-shell -u neo4j -p password123

# Limpiar datos
docker exec -i neo4j-tsp-local cypher-shell -u neo4j -p password123 < cleanup.cypher

# Detener
docker compose down
```

## Acceso web

Neo4j Browser: http://localhost:7474 (usuario: `neo4j`, contraseña: `password123`)

## Notas

- Los subconjuntos de 4, 6 y 8 ciudades resuelven en segundos.
- A partir de 10 ciudades, el espacio de búsqueda crece factorialmente: `(n-1)!` permutaciones.
- 12+ ciudades por fuerza bruta pura en Cypher puede no completar en tiempo razonable.
