# Punto 5: MemGraph - Problema del Viajero (TSP)

## Elección de MemGraph

**MemGraph** es una base de datos de grafos pura (no multi-modelo) del ranking de [DB-Engines](https://db-engines.com/en/ranking/graph+dbms).

Características principales:
- **Modelo**: Grafo puro (Graph DBMS)
- **Lenguaje de consulta**: Cypher (compatible con openCypher)
- **Protocolo**: Bolt (compatible con Neo4j)
- **Motor**: Escrito en C++ con almacenamiento en memoria para alto rendimiento
- **Extensiones**: MAGE (MemGraph Advanced Graph Extensions) permite módulos personalizados en Python/C++
- **Compatibilidad**: Compatible con drivers de Neo4j y herramientas del ecosistema Cypher

### Diferencias con Neo4j
- Usa `CREATE` en lugar de `MERGE` en muchos casos
- No soporta `MERGE` con `ON CREATE SET` / `ON MATCH SET` de la misma forma
- Los índices se crean con `CREATE INDEX ON :Label(property)`
- Incluye MAGE para procedimientos personalizados
- Usa `mgconsole` como cliente de línea de comandos nativo

## Estructura de archivos

| Archivo | Descripción |
|---------|-------------|
| `Dockerfile` | Imagen basada en `memgraph/memgraph:latest` |
| `docker-compose.yml` | Servicio MemGraph con puerto Bolt 7687 |
| `setup.cypher` | Script Cypher para crear el grafo completo (20 ciudades, 380 rutas bidireccionales) |
| `cleanup.cypher` | Elimina todos los datos del grafo |
| `generate_tsp.py` | Generador dinámico de consultas TSP en Cypher para N ciudades |
| `tsp_mage.py` | Módulo MAGE con procedimientos `brute_force` y `held_karp` |
| `run.sh` | Script de ejecución automatizada |

## Datos

Se utilizan 20 ciudades colombianas con distancias en kilómetros (datos en `shared/ciudades.json`):

- **Nodos**: `Ciudad` con propiedades `id` (int) y `nombre` (string)
- **Relaciones**: `RUTA` con propiedad `distancia` (int, km), bidireccionales
- **Total**: 20 nodos, 190 pares × 2 direcciones = 380 relaciones

### Subconjuntos evaluados

| Ciudades | IDs |
|----------|-----|
| 4 | 0, 1, 2, 3 |
| 6 | 0, 1, 2, 3, 4, 5 |
| 8 | 0, 1, 2, 3, 4, 5, 6, 7 |
| 10 | 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 |
| 12 | 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 |
| 14 | 0-13 |
| 16 | 0-15 |
| 18 | 0-17 |
| 20 | 0-19 |

## Cómo ejecutar

### Requisitos
- Docker y Docker Compose
- Python 3

### Ejecución automática

```bash
chmod +x run.sh
./run.sh
```

### Ejecución manual

```bash
# Levantar MemGraph
docker compose up -d --build

# Esperar a que esté listo (~10s)
sleep 10

# Cargar datos
docker exec -i memgraph-tsp mgconsole --no-history < setup.cypher

# Verificar
docker exec memgraph-tsp mgconsole --no-history -c "MATCH (c:Ciudad) RETURN count(c);"

# Generar consulta TSP para N ciudades
python3 generate_tsp.py 4 > /tmp/tsp_query.cypher

# Ejecutar consulta
docker exec -i memgraph-tsp mgconsole --no-history < /tmp/tsp_query.cypher

# Limpiar datos
docker exec -i memgraph-tsp mgconsole --no-history < cleanup.cypher

# Detener
docker compose down
```

### Usar módulo MAGE

```bash
# Copiar el módulo al contenedor
docker cp tsp_mage.py memgraph-tsp:/opt/memgraph/query_modules/tsp_mage.py

# Recargar módulos
docker exec memgraph-tsp mgconsole --no-history -c "CALL mg.load_all();"

# Ejecutar brute force
docker exec memgraph-tsp mgconsole --no-history -c \
  "CALL tsp_mage.brute_force([0,1,2,3]) YIELD distancia_total, ruta;"

# Ejecutar Held-Karp
docker exec memgraph-tsp mgconsole --no-history -c \
  "CALL tsp_mage.held_karp([0,1,2,3,4,5]) YIELD distancia_total, ruta;"
```

## Enfoque de las consultas TSP

### Fuerza bruta en Cypher (generate_tsp.py)
El script `generate_tsp.py` genera dinámicamente una consulta Cypher para N ciudades:
1. Hace `MATCH` de cada nodo `Ciudad` por su `id` específico (leídos de `shared/ciudades.json`)
2. Usa `WHERE` con todas las desigualdades de pares para asegurar nodos distintos
3. Hace `MATCH` de las relaciones `RUTA` formando un ciclo Hamiltoniano
4. Suma las distancias y ordena ascendente con `LIMIT 1`

### Módulo MAGE (Python)
- **`brute_force`**: Enumera todas las permutaciones con poda por cota superior
- **`held_karp`**: Programación dinámica con bitmask, complejidad O(n² × 2ⁿ)

## Notas de rendimiento

- MemGraph al ser in-memory ofrece consultas muy rápidas
- Las consultas de fuerza bruta Cypher son viables hasta ~12 ciudades
- Para 14+ ciudades se recomienda usar el módulo MAGE con Held-Karp
- El protocolo Bolt permite conexión eficiente desde cualquier driver compatible
