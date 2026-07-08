import json
import sys
from pathlib import Path


def generate_tsp(n):
    ciudades_path = Path(__file__).resolve().parent.parent / "shared" / "ciudades.json"
    with open(ciudades_path) as f:
        data = json.load(f)

    subset = data["subsets"][str(n)]
    rest = subset[1:]

    lines = []
    lines.append(f"// TSP {n} ciudades")
    lines.append(f"// Subconjunto: {subset}")
    lines.append(f"// Permutaciones a evaluar: {len(rest)}! = {__import__('math').factorial(len(rest))}")
    lines.append("")

    lines.append(f"MATCH (n0:Ciudad {{id: {subset[0]}}})")
    for i in range(1, n):
        lines.append(f"MATCH (n{i}:Ciudad)")

    where_parts = []
    for i in range(1, n):
        where_parts.append(f"n{i}.id IN {rest}")
    for i in range(n):
        for j in range(i + 1, n):
            where_parts.append(f"n{i} <> n{j}")
    lines.append("WHERE " + " AND ".join(where_parts))

    match_edges = []
    for i in range(n - 1):
        match_edges.append(f"(n{i})-[r{i}:RUTA]->(n{i+1})")
    match_edges.append(f"(n{n-1})-[r{n-1}:RUTA]->(n0)")
    lines.append("MATCH " + ",\n      ".join(match_edges))

    dist_sum = " + ".join(f"r{i}.distancia" for i in range(n))
    ruta_list = ", ".join(f"n{i}.nombre" for i in range(n)) + ", n0.nombre"
    lines.append(f"RETURN {dist_sum} AS distanciaTotal,")
    lines.append(f"       [{ruta_list}] AS ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")

    return "\n".join(lines)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 generate_tsp.py <N>", file=sys.stderr)
        sys.exit(1)
    print(generate_tsp(int(sys.argv[1])))
