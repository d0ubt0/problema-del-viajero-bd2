# Punto 3: TSP Óptimo con Python

Resolución del Problema del Viajero (TSP) utilizando **solo Python** para encontrar la solución **óptima exacta**.

## Algoritmos

| Algoritmo | Complejidad | Descripción |
|-----------|-------------|-------------|
| Fuerza Bruta | O(n!) | Evalúa todas las permutaciones. Solo viable hasta ~10 ciudades |
| Held-Karp | O(n² · 2ⁿ) | Programación dinámica con bitmask. Viable hasta ~20 ciudades |

## Estructura

```
punto3-python-optimo/
├── tsp_optimo.py            # Script principal
├── tsp_optimo_colab.ipynb   # Notebook para Google Colab
├── Dockerfile
├── docker-compose.yml
├── run.sh
└── README.md
```

## Ejecución local

```bash
python tsp_optimo.py
```

## Ejecución con Docker

```bash
chmod +x run.sh
./run.sh
```

## Google Colab

Subir `tsp_optimo_colab.ipynb` a Google Colab y ejecutar las celdas en orden.

## Datos

Se utilizan 20 ciudades colombianas desde `../shared/ciudades.json` con subconjuntos de 4, 6, 8, 10, 12, 14, 16, 18 y 20 ciudades.
