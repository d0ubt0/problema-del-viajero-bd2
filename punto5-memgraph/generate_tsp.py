#!/usr/bin/env python3
import json
import sys
import os
from itertools import combinations


def main():
    if len(sys.argv) != 2:
        print(f"Uso: {sys.argv[0]} <N>", file=sys.stderr)
        sys.exit(1)

    n = int(sys.argv[1])

    json_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'shared', 'ciudades.json')
    with open(json_path) as f:
        data = json.load(f)

    city_ids = data["subsets"][str(n)]

    lines = []

    for i, cid in enumerate(city_ids):
        lines.append(f"MATCH (n{i}:Ciudad {{id: {cid}}})")

    pairs = [f"n{i} <> n{j}" for i, j in combinations(range(n), 2)]
    lines.append("WHERE " + " AND ".join(pairs))

    route_parts = []
    for i in range(n):
        j = (i + 1) % n
        route_parts.append(f"(n{i})-[r{i}:RUTA]->(n{j})")

    lines.append("MATCH " + ",\n      ".join(route_parts))

    dist_sum = " + ".join(f"r{i}.distancia" for i in range(n))
    route_names = ", ".join(f"n{i}.nombre" for i in range(n))

    lines.append(f"RETURN {dist_sum} AS distanciaTotal,")
    lines.append(f"       [{route_names}] AS ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")

    print("\n".join(lines))


if __name__ == "__main__":
    main()
