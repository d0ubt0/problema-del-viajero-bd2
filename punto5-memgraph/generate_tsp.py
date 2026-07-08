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
    start_id = city_ids[0]
    rest_ids = city_ids[1:]

    lines = []

    lines.append(f"MATCH (n0:Ciudad {{id: {start_id}}})")
    for i in range(1, n):
        lines.append(f"MATCH (n{i}:Ciudad)")

    where_parts = []
    for i in range(1, n):
        where_parts.append(f"n{i}.id IN {rest_ids}")
    for i in range(n):
        for j in range(i + 1, n):
            where_parts.append(f"n{i} <> n{j}")
    lines.append("WHERE " + " AND ".join(where_parts))

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
