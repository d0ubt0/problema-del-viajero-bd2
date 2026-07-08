#!/usr/bin/env python3
import json
import sys
import os

def load_data():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(script_dir, 'ciudades.json'), 'r') as f:
        return json.load(f)

def get_distance(distancias, i, j):
    if i == j:
        return 0
    key = f"{min(i,j)}-{max(i,j)}"
    return distancias[key]

def get_subset(data, n):
    return data["subsets"][str(n)]

def get_cities_for_n(data, n):
    ids = get_subset(data, n)
    ciudades = [c for c in data["ciudades"] if c["id"] in ids]
    return ciudades

def get_distance_matrix(data, n):
    ids = get_subset(data, n)
    matrix = []
    for i in ids:
        row = []
        for j in ids:
            row.append(get_distance(data["distancias_km"], i, j))
        matrix.append(row)
    return matrix

def generate_cypher(data, n):
    ids = get_subset(data, n)
    ciudades = {c["id"]: c["nombre"] for c in data["ciudades"]}
    lines = []
    lines.append("// Crear nodos de ciudades")
    for cid in ids:
        nombre = ciudades[cid]
        lines.append(f'MERGE (c{cid}:Ciudad {{id: {cid}, nombre: "{nombre}"}})')
    lines.append("")
    lines.append("// Crear relaciones con distancias")
    for i in range(len(ids)):
        for j in range(i+1, len(ids)):
            d = get_distance(data["distancias_km"], ids[i], ids[j])
            lines.append(f'MERGE (c{ids[i]})-[:RUTA {{distancia: {d}}}]->(c{ids[j]})')
            lines.append(f'MERGE (c{ids[j]})-[:RUTA {{distancia: {d}}}]->(c{ids[i]})')
    lines.append("")
    return "\n".join(lines)

def generate_cypher_tsp(data, n):
    ids = get_subset(data, n)
    ciudades = {c["id"]: c["nombre"] for c in data["ciudades"]}
    city_vars = [f"c{cid}" for cid in ids]
    start = ids[0]

    lines = []
    lines.append(f"// TSP óptimo para {n} ciudades - Fuerza bruta con Cypher")
    lines.append(f"// Ciudades: {', '.join(ciudades[cid] for cid in ids)}")
    lines.append("")

    match_parts = []
    match_parts.append(f"MATCH (c{start}:Ciudad {{id: {start}}})")

    used = {start}
    remaining = [cid for cid in ids if cid != start]

    for idx, cid in enumerate(remaining):
        match_parts.append(f"MATCH (c{cid}:Ciudad {{id: {cid}}})")

    where_parts = []
    all_vars = [f"c{cid}" for cid in ids]
    for i in range(len(all_vars)):
        for j in range(i+1, len(all_vars)):
            where_parts.append(f"{all_vars[i]} <> {all_vars[j]}")

    path_parts = []
    ordered = [start] + remaining
    for i in range(len(ordered)-1):
        path_parts.append(f"(c{ordered[i]})-[r{i}:RUTA]->(c{ordered[i+1]})")
    path_parts.append(f"(c{ordered[-1]})-[r{len(ordered)-1}:RUTA]->(c{ordered[0]})")

    dist_parts = []
    for i in range(len(ordered)):
        dist_parts.append(f"r{i}.distancia")
    total_dist = " + ".join(dist_parts)

    lines.append(", ".join(match_parts))
    lines.append("WHERE " + " AND ".join(where_parts))
    lines.append(f"WITH {total_dist} AS distanciaTotal, " + ", ".join(f"c{cid}.nombre AS n{cid}" for cid in ordered))
    lines.append(f"RETURN distanciaTotal, [{', '.join(f'n{cid}' for cid in ordered)}] AS ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")

    return "\n".join(lines)

def generate_neo4j_tsp_allpaths(data, n):
    ids = get_subset(data, n)
    ciudades = {c["id"]: c["nombre"] for c in data["ciudades"]}

    lines = []
    lines.append(f"// TSP óptimo para {n} ciudades - Todas las permutaciones")
    lines.append(f"// Ciudades: {', '.join(ciudades[cid] for cid in ids)}")
    lines.append("")

    start = ids[0]
    remaining = [cid for cid in ids if cid != start]

    match_clauses = []
    match_clauses.append(f"MATCH (inicio:Ciudad {{id: {start}}})")
    for cid in remaining:
        match_clauses.append(f"MATCH (c{cid}:Ciudad {{id: {cid}}})")

    lines.append("\n".join(match_clauses))

    where_parts = []
    all_vars = ["inicio"] + [f"c{cid}" for cid in remaining]
    for i in range(len(all_vars)):
        for j in range(i+1, len(all_vars)):
            where_parts.append(f"{all_vars[i]} <> {all_vars[j]}")
    lines.append("WHERE " + " AND ".join(where_parts))

    order = ["inicio"] + [f"c{cid}" for cid in remaining]
    route_exprs = []
    dist_exprs = []
    for i in range(len(order)):
        next_var = order[(i+1) % len(order)]
        cur_var = order[i]
        route_exprs.append(f"{cur_var}.nombre")
        dist_exprs.append(f"({cur_var})-[r{i}:RUTA]->({next_var})")

    with_parts = []
    for i in range(len(order)):
        with_parts.append(f"r{i}.distancia AS d{i}")
    with_parts.append("[" + ", ".join(f"{v}.nombre" for v in order) + "] AS ruta")

    lines.append("MATCH " + ", ".join(dist_exprs))

    total = " + ".join(f"d{i}" for i in range(len(order)))
    lines.append(f"WITH {total} AS distanciaTotal, ruta")
    lines.append("RETURN distanciaTotal, ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")

    return "\n".join(lines)

def generate_neo4j_tsp_v2(data, n):
    ids = get_subset(data, n)
    ciudades = {c["id"]: c["nombre"] for c in data["ciudades"]}

    lines = []
    lines.append(f"// TSP óptimo para {n} ciudades")
    lines.append(f"// Ciudades: {', '.join(ciudades[cid] for cid in ids)}")
    lines.append("")

    start = ids[0]
    others = [cid for cid in ids if cid != start]

    match_parts = [f"MATCH (n0:Ciudad {{id: {start}}})"]
    for i, cid in enumerate(others):
        match_parts.append(f"MATCH (n{i+1}:Ciudad {{id: {cid}}})")

    lines.append("\n".join(match_parts))

    all_vars = [f"n{i}" for i in range(len(ids))]
    where_parts = []
    for i in range(len(all_vars)):
        for j in range(i+1, len(all_vars)):
            where_parts.append(f"{all_vars[i]} <> {all_vars[j]}")
    lines.append("WHERE " + " AND ".join(where_parts))

    rel_parts = []
    for i in range(len(all_vars)):
        next_i = (i + 1) % len(all_vars)
        rel_parts.append(f"({all_vars[i]})-[r{i}:RUTA]->({all_vars[next_i]})")
    lines.append("MATCH " + ", ".join(rel_parts))

    dist_sum = " + ".join(f"r{i}.distancia" for i in range(len(all_vars)))
    names_list = "[" + ", ".join(f"{v}.nombre" for v in all_vars) + "]"
    lines.append(f"RETURN {dist_sum} AS distanciaTotal, {names_list} AS ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")

    return "\n".join(lines)

if __name__ == "__main__":
    data = load_data()
    if len(sys.argv) < 2:
        print("Usage: python generate_data.py <command> [args]")
        print("Commands: cypher <n>, tsp <n>, matrix <n>, cities <n>")
        sys.exit(1)

    cmd = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 4

    if cmd == "cypher":
        print(generate_cypher(data, n))
    elif cmd == "tsp":
        print(generate_neo4j_tsp_v2(data, n))
    elif cmd == "matrix":
        print(json.dumps(get_distance_matrix(data, n), indent=2))
    elif cmd == "cities":
        print(json.dumps(get_cities_for_n(data, n), indent=2, ensure_ascii=False))
