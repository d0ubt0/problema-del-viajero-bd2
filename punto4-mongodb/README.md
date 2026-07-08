# Punto 4: TSP con MongoDB

Resolución del Problema del Viajero (Travelling Salesperson Problem) utilizando exclusivamente MongoDB con JavaScript (mongosh).

## Estructura

| Archivo | Descripción |
|---|---|
| `Dockerfile` | Imagen basada en `mongo:latest` |
| `docker-compose.yml` | Servicio MongoDB con puerto 27017 y volumen persistente |
| `setup.js` | Script de inicialización: crea BD, colecciones e inserta datos |
| `tsp.js` | Script unificado TSP: fuerza bruta (N<=10) y Held-Karp (todos los tamaños) |
| `cleanup.js` | Elimina todas las colecciones |
| `run.sh` | Script automatizado para ejecutar todo |

## Datos

- **Base de datos:** `tsp_colombia`
- **Colecciones:**
  - `ciudades`: 20 ciudades colombianas con id, nombre, latitud y longitud
  - `rutas`: grafo completo con distancias en ambas direcciones (380 aristas)
  - `distancias`: matriz de distancias 20x20 completa

## Uso rápido

```bash
chmod +x run.sh
./run.sh
```

## Uso manual

```bash
# Levantar MongoDB
docker compose up -d --build

# Esperar a que esté listo y ejecutar setup
docker exec tsp_mongodb mongosh /docker-entrypoint-initdb.d/setup.js

# Copiar tsp.js al contenedor
docker cp tsp.js tsp_mongodb:/tmp/tsp.js

# Ejecutar TSP para N ciudades (4, 6, 8, 10, 12, 14, 16, 18, 20)
docker exec tsp_mongodb mongosh --quiet --eval "var N=4" /tmp/tsp.js
docker exec tsp_mongodb mongosh --quiet --eval "var N=20" /tmp/tsp.js

# Limpiar colecciones
docker cp cleanup.js tsp_mongodb:/tmp/cleanup.js
docker exec tsp_mongodb mongosh /tmp/cleanup.js

# Detener
docker compose down
```

## Algoritmos

### Fuerza Bruta (N <= 10)
Genera todas las permutaciones posibles (fijando la primera ciudad) y evalúa cada ruta. Garantiza la solución óptima pero tiene complejidad O((n-1)!).

| Ciudades | Permutaciones |
|---|---|
| 4 | 6 |
| 6 | 120 |
| 8 | 5,040 |
| 10 | 362,880 |

### Held-Karp (Programación Dinámica)
Algoritmo exacto con complejidad O(2^n * n^2). Se ejecuta para todos los tamaños. Para 20 ciudades: ~1.6 x 10^8 operaciones, ejecutable en tiempo razonable.

## Parámetro N

El script `tsp.js` acepta el número de ciudades mediante la variable `N`, pasada vía `--eval`:

```bash
mongosh --quiet --eval "var N=12" /tmp/tsp.js
```

Valores válidos: 4, 6, 8, 10, 12, 14, 16, 18, 20. Si no se especifica, N=4 por defecto.

Para N <= 10 se ejecutan ambos algoritmos (fuerza bruta y Held-Karp). Para N > 10 solo se ejecuta Held-Karp.
