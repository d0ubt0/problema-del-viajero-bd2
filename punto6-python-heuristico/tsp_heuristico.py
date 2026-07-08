#!/usr/bin/env python3
import json
import time
import sys
import os
import random
import math
from itertools import combinations


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
    coords = [(c["lat"], c["lon"]) for c in ciudades]
    return dist, nombres, subsets, coords


def build_sub_matrix(dist_full, indices):
    n = len(indices)
    sub = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            sub[i][j] = dist_full[indices[i]][indices[j]]
    return sub


def tour_cost(tour, dist):
    cost = 0
    for i in range(len(tour) - 1):
        cost += dist[tour[i]][tour[i + 1]]
    return cost


# =============================================================================
# Held-Karp (optimal, for comparison)
# =============================================================================
def held_karp(dist, n):
    if n > 20:
        return None, float("inf")
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


# =============================================================================
# Nearest Neighbor
# =============================================================================
def nearest_neighbor(dist, n):
    best_tour = None
    best_cost = float("inf")
    for start in range(n):
        visited = [False] * n
        tour = [start]
        visited[start] = True
        for _ in range(n - 1):
            curr = tour[-1]
            nearest = -1
            nearest_d = float("inf")
            for j in range(n):
                if not visited[j] and dist[curr][j] < nearest_d:
                    nearest_d = dist[curr][j]
                    nearest = j
            tour.append(nearest)
            visited[nearest] = True
        tour.append(start)
        c = tour_cost(tour, dist)
        if c < best_cost:
            best_cost = c
            best_tour = tour[:]
    return best_tour, best_cost


# =============================================================================
# 2-opt improvement
# =============================================================================
def two_opt(dist, n, initial_tour=None, max_iterations=1000):
    if initial_tour is None:
        tour = list(range(n))
        random.shuffle(tour)
        tour.append(tour[0])
    else:
        tour = initial_tour[:]
    improved = True
    iterations = 0
    while improved and iterations < max_iterations:
        improved = False
        iterations += 1
        for i in range(1, len(tour) - 2):
            for j in range(i + 1, len(tour) - 1):
                d1 = dist[tour[i - 1]][tour[i]] + dist[tour[j]][tour[j + 1]]
                d2 = dist[tour[i - 1]][tour[j]] + dist[tour[i]][tour[j + 1]]
                if d2 < d1:
                    tour[i:j + 1] = reversed(tour[i:j + 1])
                    improved = True
    return tour, tour_cost(tour, dist)


def two_opt_multi(dist, n, runs=10):
    best_tour = None
    best_cost = float("inf")
    for _ in range(runs):
        tour, cost = two_opt(dist, n)
        if cost < best_cost:
            best_cost = cost
            best_tour = tour[:]
    nn_tour, nn_cost = nearest_neighbor(dist, n)
    tour, cost = two_opt(dist, n, initial_tour=nn_tour)
    if cost < best_cost:
        best_cost = cost
        best_tour = tour[:]
    return best_tour, best_cost


# =============================================================================
# Christofides-like algorithm
# =============================================================================
def prim_mst(dist, n):
    in_tree = [False] * n
    min_edge = [float("inf")] * n
    parent = [-1] * n
    min_edge[0] = 0
    edges = []
    for _ in range(n):
        u = -1
        for v in range(n):
            if not in_tree[v] and (u == -1 or min_edge[v] < min_edge[u]):
                u = v
        in_tree[u] = True
        if parent[u] != -1:
            edges.append((parent[u], u, dist[parent[u]][u]))
        for v in range(n):
            if not in_tree[v] and dist[u][v] < min_edge[v]:
                min_edge[v] = dist[u][v]
                parent[v] = u
    return edges


def min_weight_matching(adj, odd_vertices, dist):
    edges = []
    used = set()
    pairs = list(combinations(odd_vertices, 2))
    pairs.sort(key=lambda p: dist[p[0]][p[1]])
    for u, v in pairs:
        if u not in used and v not in used:
            edges.append((u, v, dist[u][v]))
            used.add(u)
            used.add(v)
            if len(used) == len(odd_vertices):
                break
    return edges


def euler_tour(adj, start, n):
    tour = []
    stack = [start]
    edge_count = {}
    for u in adj:
        for v in adj[u]:
            key = (min(u, v), max(u, v))
            edge_count[key] = edge_count.get(key, 0) + 1
    while stack:
        u = stack[-1]
        found = False
        for v in adj[u]:
            key = (min(u, v), max(u, v))
            if edge_count.get(key, 0) > 0:
                edge_count[key] -= 1
                adj[u].remove(v)
                adj[v].remove(u)
                stack.append(v)
                found = True
                break
        if not found:
            tour.append(stack.pop())
    tour.reverse()
    return tour


def christofides(dist, n):
    if n <= 2:
        tour = list(range(n)) + [0]
        return tour, tour_cost(tour, dist)
    mst_edges = prim_mst(dist, n)
    degree = [0] * n
    adj = {i: [] for i in range(n)}
    for u, v, w in mst_edges:
        adj[u].append(v)
        adj[v].append(u)
        degree[u] += 1
        degree[v] += 1
    odd_vertices = [i for i in range(n) if degree[i] % 2 == 1]
    matching_edges = min_weight_matching(adj, odd_vertices, dist)
    for u, v, w in matching_edges:
        adj[u].append(v)
        adj[v].append(u)
    euler = euler_tour(adj, 0, n)
    visited = set()
    tour = []
    for node in euler:
        if node not in visited:
            tour.append(node)
            visited.add(node)
    tour.append(tour[0])
    return tour, tour_cost(tour, dist)


# =============================================================================
# Simulated Annealing
# =============================================================================
def simulated_annealing(dist, n, initial_temp=10000, cooling_rate=0.9995, min_temp=0.1):
    tour = list(range(n))
    random.shuffle(tour)
    tour.append(tour[0])
    current_cost = tour_cost(tour, dist)
    best_tour = tour[:]
    best_cost = current_cost
    temp = initial_temp
    while temp > min_temp:
        i = random.randint(1, n - 1)
        j = random.randint(1, n - 1)
        if i > j:
            i, j = j, i
        new_tour = tour[:]
        new_tour[i:j + 1] = reversed(new_tour[i:j + 1])
        new_cost = tour_cost(new_tour, dist)
        delta = new_cost - current_cost
        if delta < 0 or random.random() < math.exp(-delta / temp):
            tour = new_tour
            current_cost = new_cost
            if current_cost < best_cost:
                best_cost = current_cost
                best_tour = tour[:]
        temp *= cooling_rate
    return best_tour, best_cost


# =============================================================================
# Genetic Algorithm
# =============================================================================
def ga_crossover(parent1, parent2, n):
    start = random.randint(0, n - 1)
    end = random.randint(start + 1, n)
    child = [-1] * n
    p1 = parent1[:-1]
    p2 = parent2[:-1]
    child[start:end] = p1[start:end]
    used = set(child[start:end])
    pos = end % n
    for gene in p2:
        if gene not in used:
            child[pos] = gene
            used.add(gene)
            pos = (pos + 1) % n
    child.append(child[0])
    return child


def ga_mutate(tour, n, mutation_rate=0.3):
    if random.random() < mutation_rate:
        t = tour[:-1]
        i = random.randint(0, n - 1)
        j = random.randint(0, n - 1)
        t[i], t[j] = t[j], t[i]
        t.append(t[0])
        return t
    return tour


def genetic_algorithm(dist, n, population_size=100, generations=300, mutation_rate=0.3):
    population = []
    for _ in range(population_size):
        tour = list(range(n))
        random.shuffle(tour)
        tour.append(tour[0])
        population.append(tour)
    best_tour = None
    best_cost = float("inf")
    for gen in range(generations):
        fitness = [(tour_cost(t, dist), t) for t in population]
        fitness.sort(key=lambda x: x[0])
        if fitness[0][0] < best_cost:
            best_cost = fitness[0][0]
            best_tour = fitness[0][1][:]
        elite_count = max(2, population_size // 10)
        new_population = [f[1][:] for f in fitness[:elite_count]]
        while len(new_population) < population_size:
            tournament_size = 5
            candidates = random.sample(fitness, min(tournament_size, len(fitness)))
            candidates.sort(key=lambda x: x[0])
            p1 = candidates[0][1]
            candidates2 = random.sample(fitness, min(tournament_size, len(fitness)))
            candidates2.sort(key=lambda x: x[0])
            p2 = candidates2[0][1]
            child = ga_crossover(p1, p2, n)
            child = ga_mutate(child, n, mutation_rate)
            new_population.append(child)
        population = new_population
    return best_tour, best_cost


# =============================================================================
# Main benchmark runner
# =============================================================================
def run_heuristic(func, dist, n, *args, **kwargs):
    t0 = time.perf_counter()
    tour, cost = func(dist, n, *args, **kwargs)
    t1 = time.perf_counter()
    return tour, cost, (t1 - t0) * 1000


def run_benchmarks(dist_full, nombres, subsets, coords):
    sizes = [4, 6, 8, 10, 12, 14, 16, 18, 20]
    all_results = []

    print("=" * 110)
    print("PUNTO 6: TSP HEURÍSTICO CON PYTHON")
    print("Algoritmos: Vecino más cercano, 2-opt, Christofides, Simulated Annealing, Genético")
    print("=" * 110)
    print()

    for size in sizes:
        key = str(size)
        if key not in subsets:
            continue
        indices = subsets[key]
        sub_dist = build_sub_matrix(dist_full, indices)
        sub_nombres = [nombres[i] for i in indices]

        print("-" * 110)
        print(f"=== {size} ciudades: {', '.join(sub_nombres)} ===")
        print("-" * 110)

        optimal_cost = None
        optimal_time = None
        if size <= 20:
            try:
                t0 = time.perf_counter()
                hk_route, hk_cost = held_karp(sub_dist, size)
                t1 = time.perf_counter()
                optimal_time = (t1 - t0) * 1000
                if hk_route is not None:
                    optimal_cost = hk_cost
            except (MemoryError, Exception):
                pass

        nn_tour, nn_cost, nn_time = run_heuristic(nearest_neighbor, sub_dist, size)
        to_tour, to_cost, to_time = run_heuristic(two_opt_multi, sub_dist, size)
        ch_tour, ch_cost, ch_time = run_heuristic(christofides, sub_dist, size)
        sa_tour, sa_cost, sa_time = run_heuristic(simulated_annealing, sub_dist, size)
        ga_tour, ga_cost, ga_time = run_heuristic(genetic_algorithm, sub_dist, size)

        def dev(cost):
            if optimal_cost is not None and optimal_cost > 0:
                return ((cost - optimal_cost) / optimal_cost) * 100
            return None

        header = f"{'Algoritmo':<28} | {'Distancia':>10} | {'Tiempo (ms)':>12} | {'Desviación (%)':>14}"
        print(header)
        print("-" * len(header))

        if optimal_cost is not None:
            print(f"{'Óptimo (Held-Karp)':<28} | {optimal_cost:>10} | {optimal_time:>12.2f} | {'0.00':>14}")

        algos = [
            ("Vecino más cercano", nn_cost, nn_time),
            ("2-opt", to_cost, to_time),
            ("Christofides", ch_cost, ch_time),
            ("Simulated Annealing", sa_cost, sa_time),
            ("Genético", ga_cost, ga_time),
        ]

        for name, cost, t in algos:
            d = dev(cost)
            d_str = f"{d:.2f}" if d is not None else "N/A"
            print(f"{name:<28} | {cost:>10} | {t:>12.2f} | {d_str:>14}")

        print()

        all_results.append({
            "size": size,
            "optimal_cost": optimal_cost,
            "optimal_time": optimal_time,
            "nn": {"cost": nn_cost, "time": nn_time, "dev": dev(nn_cost)},
            "two_opt": {"cost": to_cost, "time": to_time, "dev": dev(to_cost)},
            "christofides": {"cost": ch_cost, "time": ch_time, "dev": dev(ch_cost)},
            "sa": {"cost": sa_cost, "time": sa_time, "dev": dev(sa_cost)},
            "ga": {"cost": ga_cost, "time": ga_time, "dev": dev(ga_cost)},
        })

    print("=" * 110)
    print("TABLA RESUMEN COMPARATIVA")
    print("=" * 110)
    header = (
        f"{'N':>3} | {'Óptimo':>8} | {'Vecino':>8} | {'2-opt':>8} | "
        f"{'Christof.':>9} | {'SA':>8} | {'Genético':>8} | "
        f"{'Mejor heurística':<20}"
    )
    print(header)
    print("-" * len(header))
    for r in all_results:
        heuristics = {
            "Vecino": r["nn"]["cost"],
            "2-opt": r["two_opt"]["cost"],
            "Christof.": r["christofides"]["cost"],
            "SA": r["sa"]["cost"],
            "Genético": r["ga"]["cost"],
        }
        best_name = min(heuristics, key=heuristics.get)
        best_val = heuristics[best_name]
        opt = f"{r['optimal_cost']}" if r["optimal_cost"] is not None else "N/A"
        print(
            f"{r['size']:>3} | {opt:>8} | {r['nn']['cost']:>8} | {r['two_opt']['cost']:>8} | "
            f"{r['christofides']['cost']:>9} | {r['sa']['cost']:>8} | {r['ga']['cost']:>8} | "
            f"{best_name} ({best_val})"
        )

    print()
    print("=" * 110)
    print("ANÁLISIS")
    print("=" * 110)

    best_dev_algo = {}
    fastest_algo = {}
    for r in all_results:
        if r["optimal_cost"] is not None:
            devs = {
                "Vecino": r["nn"]["dev"],
                "2-opt": r["two_opt"]["dev"],
                "Christofides": r["christofides"]["dev"],
                "SA": r["sa"]["dev"],
                "Genético": r["ga"]["dev"],
            }
            best = min(devs, key=lambda k: devs[k] if devs[k] is not None else float("inf"))
            best_dev_algo[r["size"]] = (best, devs[best])

        times = {
            "Vecino": r["nn"]["time"],
            "2-opt": r["two_opt"]["time"],
            "Christofides": r["christofides"]["time"],
            "SA": r["sa"]["time"],
            "Genético": r["ga"]["time"],
        }
        fastest = min(times, key=times.get)
        fastest_algo[r["size"]] = (fastest, times[fastest])

    print("\nMejor heurística (menor desviación del óptimo):")
    for size, (name, dev) in best_dev_algo.items():
        print(f"  n={size:>2}: {name} ({dev:.2f}%)")

    print("\nHeurística más rápida:")
    for size, (name, t) in fastest_algo.items():
        print(f"  n={size:>2}: {name} ({t:.2f} ms)")

    avg_devs = {}
    for algo_name in ["Vecino", "2-opt", "Christofides", "SA", "Genético"]:
        devs = []
        for r in all_results:
            d = r[{"Vecino": "nn", "2-opt": "two_opt", "Christofides": "christofides", "SA": "sa", "Genético": "ga"}[algo_name]]["dev"]
            if d is not None:
                devs.append(d)
        if devs:
            avg_devs[algo_name] = sum(devs) / len(devs)

    if avg_devs:
        print("\nDesviación promedio del óptimo:")
        for name, avg in sorted(avg_devs.items(), key=lambda x: x[1]):
            print(f"  {name:<20}: {avg:.2f}%")
        overall_best = min(avg_devs, key=avg_devs.get)
        print(f"\n  >>> En promedio, '{overall_best}' es la heurística más cercana al óptimo.")

    return all_results


if __name__ == "__main__":
    random.seed(42)
    data_path = sys.argv[1] if len(sys.argv) > 1 else None
    dist, nombres, subsets, coords = load_data(data_path)
    run_benchmarks(dist, nombres, subsets, coords)
