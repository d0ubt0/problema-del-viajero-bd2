# Punto 6: TSP Heurístico con Python

Resolución del Problema del Viajero (TSP) usando algoritmos heurísticos en Python puro.

## Algoritmos implementados

| Algoritmo | Tipo | Descripción |
|-----------|------|-------------|
| Vecino más cercano | Constructivo greedy | Desde cada ciudad, ir siempre a la más cercana no visitada |
| 2-opt | Mejora local | Intercambiar pares de aristas para reducir distancia |
| Christofides | Constructivo avanzado | MST + matching + tour euleriano (factor 3/2) |
| Simulated Annealing | Metaheurística | Aceptar peores soluciones con probabilidad decreciente |
| Genético | Metaheurística | Población, cruce ordenado, mutación, selección |

Se incluye Held-Karp como referencia óptima.

## Estructura

```
punto6-python-heuristico/
├── tsp_heuristico.py            # Script principal
├── tsp_heuristico_colab.ipynb   # Notebook para Google Colab
├── Dockerfile
├── docker-compose.yml
├── run.sh
└── README.md
```

## Ejecución

### Local

```bash
python3 tsp_heuristico.py
```

### Docker

```bash
chmod +x run.sh
./run.sh
```

O manualmente:

```bash
docker compose up --build
```

### Google Colab

1. Subir `tsp_heuristico_colab.ipynb` a Google Colab
2. Subir `ciudades.json` cuando se solicite (o colocar en la ruta esperada)
3. Ejecutar todas las celdas

## Datos

Se utilizan 20 ciudades colombianas definidas en `../shared/ciudades.json` con subconjuntos de 4, 6, 8, 10, 12, 14, 16, 18 y 20 ciudades.

## Salida

Para cada tamaño de subconjunto se muestra:
- Distancia total encontrada por cada algoritmo
- Tiempo de ejecución en milisegundos
- Desviación porcentual respecto al óptimo (Held-Karp)

Al final se presenta una tabla resumen y análisis de cuál heurística es más precisa y cuál es más rápida.
