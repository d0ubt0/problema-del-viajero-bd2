import sys
import json
import os


def generate_tsp_query(n):
    json_path = os.path.join(os.path.dirname(__file__), '..', 'shared', 'ciudades.json')
    with open(json_path) as f:
        data = json.load(f)

    city_ids = data['subsets'][str(n)]
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
    for i in range(n - 1):
        route_parts.append(f"(n{i})-[r{i}:RUTA]->(n{i+1})")
    route_parts.append(f"(n{n-1})-[r{n-1}:RUTA]->(n0)")
    lines.append("MATCH " + ",\n      ".join(route_parts))

    dist_parts = [f"r{i}.distancia" for i in range(n)]
    ruta_parts = [f"n{i}.nombre" for i in range(n)]
    lines.append(f"RETURN {' + '.join(dist_parts)} AS distanciaTotal,")
    lines.append(f"       [{', '.join(ruta_parts)}] AS ruta")
    lines.append("ORDER BY distanciaTotal ASC")
    lines.append("LIMIT 1")

    return "\n".join(lines)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Uso: python3 {sys.argv[0]} <N>", file=sys.stderr)
        sys.exit(1)
    n = int(sys.argv[1])
    print(generate_tsp_query(n))
