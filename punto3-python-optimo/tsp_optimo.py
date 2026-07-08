#!/usr/bin/env python3
import json
import time
import sys
import os
from itertools import permutations


def load_data(path=None):
    if path is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        path = os.path.join(script_dir, "..", "shared", "ciudades.json")
    with open(path, "r") as f:
        data = json.load(f)
    ciudades = data["ciudades"]
    dist_raw = data["distancias_km"]
    subsets = data["subsets"]
    n = len(ciudades)
    dist = [[0] * n for _ in range(n)]
    for key, val in dist_raw.items():
        a, b = key.split("-")
        a, b = int(a), int(b)
        dist[a][b] = val
        dist[b][a] = val
    nombres = [c["nombre"] for c in ciudades]
    return dist, nombres, subsets


def build_sub_matrix(dist_full, indices):
    n = len(indices)
    sub = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            sub[i][j] = dist_full[indices[i]][indices[j]]
    return sub


def held_karp(dist, n):
    INF = float("inf")
    full_mask = (1 << n) - 1
    dp = [[INF] * n for _ in range(1 << n)]
    parent = [[-1] * n for _ in range(1 << n)]
    dp[1][0] = 0

    for mask in range(1, 1 << n):
        if not (mask & 1):
            continue
        for u in range(n):
            if not (mask & (1 << u)):
                continue
            if dp[mask][u] == INF:
                continue
            for v in range(n):
                if mask & (1 << v):
                    continue
                new_mask = mask | (1 << v)
                new_cost = dp[mask][u] + dist[u][v]
                if new_cost < dp[new_mask][v]:
                    dp[new_mask][v] = new_cost
                    parent[new_mask][v] = u

    best_cost = INF
    last_city = -1
    for u in range(1, n):
        cost = dp[full_mask][u] + dist[u][0]
        if cost < best_cost:
            best_cost = cost
            last_city = u

    if best_cost == INF:
        return None, INF

    route = []
    mask = full_mask
    curr = last_city
    while curr != -1:
        route.append(curr)
        prev = parent[mask][curr]
        mask = mask ^ (1 << curr)
        curr = prev
    route.reverse()
    route.append(0)
    return route, best_cost


def brute_force(dist, n):
    if n == 1:
        return [0, 0], 0
    cities = list(range(1, n))
    best_cost = float("inf")
    best_perm = None
    for perm in permutations(cities):
        cost = dist[0][perm[0]]
        for i in range(len(perm) - 1):
            cost += dist[perm[i]][perm[i + 1]]
        cost += dist[perm[-1]][0]
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    route = [0] + list(best_perm) + [0]
    return route, best_cost


def run_benchmarks(dist_full, nombres, subsets):
    sizes = [4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26]
    results = []

    print("=" * 100)
    print("PUNTO 3: TSP ÓPTIMO CON PYTHON (Held-Karp + Fuerza Bruta)")
    print("=" * 100)
    print()

    for size in sizes:
        key = str(size)
        if key not in subsets:
            continue
        indices = subsets[key]
        sub_dist = build_sub_matrix(dist_full, indices)
        sub_nombres = [nombres[i] for i in indices]

        print("-" * 100)
        print(f"Subconjunto de {size} ciudades: {', '.join(sub_nombres)}")
        print("-" * 100)

        bf_result = None
        bf_time = None
        if size <= 10:
            t0 = time.perf_counter()
            bf_route, bf_cost = brute_force(sub_dist, size)
            t1 = time.perf_counter()
            bf_time = t1 - t0
            bf_route_names = [sub_nombres[c] for c in bf_route]
            bf_result = {
                "route": bf_route_names,
                "cost": bf_cost,
                "time": bf_time,
            }
            print(f"  Fuerza Bruta:")
            print(f"    Ruta: {' -> '.join(bf_route_names)}")
            print(f"    Distancia total: {bf_cost} km")
            print(f"    Tiempo: {bf_time:.6f} s")
        else:
            print(f"  Fuerza Bruta: OMITIDA (n={size} es demasiado grande)")

        hk_feasible = True
        hk_result = None
        hk_time = None
        try:
            t0 = time.perf_counter()
            hk_route, hk_cost = held_karp(sub_dist, size)
            t1 = time.perf_counter()
            hk_time = t1 - t0
            if hk_route is not None:
                hk_route_names = [sub_nombres[c] for c in hk_route]
                hk_result = {
                    "route": hk_route_names,
                    "cost": hk_cost,
                    "time": hk_time,
                }
                print(f"  Held-Karp:")
                print(f"    Ruta: {' -> '.join(hk_route_names)}")
                print(f"    Distancia total: {hk_cost} km")
                print(f"    Tiempo: {hk_time:.6f} s")
            else:
                print(f"  Held-Karp: No se encontró solución")
                hk_feasible = False
        except MemoryError:
            print(f"  Held-Karp: ERROR DE MEMORIA (n={size})")
            hk_feasible = False
        except Exception as e:
            print(f"  Held-Karp: ERROR - {e}")
            hk_feasible = False

        if bf_result and hk_result:
            match = "SI" if bf_result["cost"] == hk_result["cost"] else "NO"
            print(f"  Coinciden: {match} (BF={bf_result['cost']}, HK={hk_result['cost']})")

        results.append({
            "size": size,
            "bf_cost": bf_result["cost"] if bf_result else None,
            "bf_time": bf_result["time"] if bf_result else None,
            "hk_cost": hk_result["cost"] if hk_result else None,
            "hk_time": hk_result["time"] if hk_result else None,
            "hk_feasible": hk_feasible,
        })
        print()

    print("=" * 100)
    print("TABLA RESUMEN")
    print("=" * 100)
    header = f"{'Ciudades':>10} | {'BF Distancia':>14} | {'BF Tiempo (s)':>14} | {'HK Distancia':>14} | {'HK Tiempo (s)':>14} | {'Coinciden':>10}"
    print(header)
    print("-" * len(header))
    for r in results:
        bf_d = f"{r['bf_cost']}" if r["bf_cost"] is not None else "N/A"
        bf_t = f"{r['bf_time']:.6f}" if r["bf_time"] is not None else "N/A"
        hk_d = f"{r['hk_cost']}" if r["hk_cost"] is not None else "N/A"
        hk_t = f"{r['hk_time']:.6f}" if r["hk_time"] is not None else "N/A"
        match = ""
        if r["bf_cost"] is not None and r["hk_cost"] is not None:
            match = "SI" if r["bf_cost"] == r["hk_cost"] else "NO"
        elif r["hk_feasible"]:
            match = "-"
        else:
            match = "N/A"
        print(f"{r['size']:>10} | {bf_d:>14} | {bf_t:>14} | {hk_d:>14} | {hk_t:>14} | {match:>10}")

    print()
    print("=" * 100)
    print("ANÁLISIS DE FACTIBILIDAD")
    print("=" * 100)
    for r in results:
        status = "FACTIBLE" if r["hk_feasible"] else "NO FACTIBLE"
        time_str = f"{r['hk_time']:.6f}s" if r["hk_time"] is not None else "N/A"
        print(f"  n={r['size']:>2}: Held-Karp {status} ({time_str})")

    infeasible = [r for r in results if not r["hk_feasible"]]
    if infeasible:
        print(f"\n  Held-Karp se vuelve no factible a partir de n={infeasible[0]['size']} ciudades.")
    else:
        print(f"\n  Held-Karp fue factible para todos los tamaños probados (hasta n={results[-1]['size']}).")

    bf_expensive = [r for r in results if r["bf_time"] is not None and r["bf_time"] > 1.0]
    if bf_expensive:
        print(f"  Fuerza Bruta se vuelve costosa (>1s) a partir de n={bf_expensive[0]['size']} ciudades.")
    else:
        feasible_bf = [r for r in results if r["bf_time"] is not None]
        if feasible_bf:
            print(f"  Fuerza Bruta fue rápida para todos los tamaños probados (hasta n={feasible_bf[-1]['size']}).")

    return results


if __name__ == "__main__":
    data_path = sys.argv[1] if len(sys.argv) > 1 else None
    dist, nombres, subsets = load_data(data_path)
    run_benchmarks(dist, nombres, subsets)
