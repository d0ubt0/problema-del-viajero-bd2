#!/usr/bin/env python3
"""Fuente unica de datos y generacion de queries para el TSP.

Uso desde CLI:
  python3 shared/generate_data.py cities <N>
  python3 shared/generate_data.py matrix <N>
  python3 shared/generate_data.py tsp_cypher <N>
"""
import json
import sys
import os


def load_data(path=None):
    if path is None:
        path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ciudades.json')
    with open(path, 'r') as f:
        data = json.load(f)
    ciudades = data["ciudades"]
    dist_raw = data["distancias_km"]
    subsets = data["subsets"]
    n_total = len(ciudades)
    dist = [[0] * n_total for _ in range(n_total)]
    for key, val in dist_raw.items():
        a, b = key.split("-")
        a, b = int(a), int(b)
        dist[a][b] = val
        dist[b][a] = val
    nombres = [c["nombre"] for c in ciudades]
    return dist, nombres, subsets


def get_subset(data, n):
    return data["subsets"][str(n)]


def get_cities_for_n(data, n):
    ids = get_subset(data, n)
    return [c for c in data["ciudades"] if c["id"] in ids]


def build_sub_matrix(dist_full, indices):
    n = len(indices)
    sub = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            sub[i][j] = dist_full[indices[i]][indices[j]]
    return sub


def generate_tsp_query_cypher(n):
    """Genera query Cypher de fuerza bruta para N ciudades.
    Solo n0 se fija; n1..n(N-1) son libres con restricciones.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(script_dir, 'ciudades.json')
    with open(path) as f:
        data = json.load(f)

    city_ids = data["subsets"][str(n)]
    start = city_ids[0]
    rest = city_ids[1:]

    lines = [f"MATCH (n0:Ciudad {{id: {start}}})"]
    for i in range(1, n):
        lines.append(f"MATCH (n{i}:Ciudad)")

    where_parts = [f"n{i}.id IN {rest}" for i in range(1, n)]
    for i in range(n):
        for j in range(i + 1, n):
            where_parts.append(f"n{i} <> n{j}")
    lines.append("WHERE " + " AND ".join(where_parts))

    route_parts = []
    for i in range(n - 1):
        route_parts.append(f"(n{i})-[r{i}:RUTA]->(n{i+1})")
    route_parts.append(f"(n{n-1})-[r{n-1}:RUTA]->(n0)")
    lines.append("MATCH " + ",\n      ".join(route_parts))

    dist_sum = " + ".join(f"r{i}.distancia" for i in range(n))
    route_list = ", ".join(f"n{i}.nombre" for i in range(n))
    lines.append(f"RETURN {dist_sum} AS distanciaTotal,")
    lines.append(f"       [{route_list}] AS ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")
    return "\n".join(lines)


if __name__ == "__main__":
    data = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ciudades.json')))
    if len(sys.argv) < 2:
        cmds = ['cities', 'matrix', 'tsp_cypher']
        print(f"Uso: python3 generate_data.py <{'|'.join(cmds)}> <N>", file=sys.stderr)
        sys.exit(1)

    cmd = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 4

    if cmd == "tsp_cypher":
        print(generate_tsp_query_cypher(n))
    elif cmd == "matrix":
        ids = get_subset(data, n)
        dist_full, _, _ = load_data()
        print(json.dumps(build_sub_matrix(dist_full, ids), indent=2))
    elif cmd == "cities":
        c = get_cities_for_n(data, n)
        print(json.dumps(c, indent=2, ensure_ascii=False))
    else:
        print(f"Comando desconocido: {cmd}", file=sys.stderr)
        sys.exit(1)
