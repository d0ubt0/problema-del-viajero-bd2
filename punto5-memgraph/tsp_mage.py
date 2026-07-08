import mgp
import itertools


@mgp.read_proc
def brute_force(
    ctx: mgp.ProcCtx,
    city_ids: mgp.List[int]
) -> mgp.Record(distancia_total=int, ruta=mgp.List[str]):
    cities = {}
    for node in ctx.graph.vertices:
        if "Ciudad" in node.labels and node.properties.get("id") in city_ids:
            cities[node.properties["id"]] = node

    if len(cities) != len(city_ids):
        return mgp.Record(distancia_total=-1, ruta=[])

    def get_dist(id1, id2):
        node1 = cities[id1]
        for edge in node1.out_edges:
            if edge.type == "RUTA" and edge.to_node.properties.get("id") == id2:
                return edge.properties.get("distancia", 999999)
        return 999999

    best_dist = float("inf")
    best_route = []

    first = city_ids[0]
    rest = city_ids[1:]

    for perm in itertools.permutations(rest):
        route = [first] + list(perm)
        total = 0
        for i in range(len(route)):
            d = get_dist(route[i], route[(i + 1) % len(route)])
            total += d
            if total >= best_dist:
                break
        if total < best_dist:
            best_dist = total
            best_route = route

    route_names = [cities[cid].properties["nombre"] for cid in best_route]
    return mgp.Record(distancia_total=int(best_dist), ruta=route_names)


@mgp.read_proc
def held_karp(
    ctx: mgp.ProcCtx,
    city_ids: mgp.List[int]
) -> mgp.Record(distancia_total=int, ruta=mgp.List[str]):
    cities = {}
    for node in ctx.graph.vertices:
        if "Ciudad" in node.labels and node.properties.get("id") in city_ids:
            cities[node.properties["id"]] = node

    if len(cities) != len(city_ids):
        return mgp.Record(distancia_total=-1, ruta=[])

    n = len(city_ids)
    idx = {cid: i for i, cid in enumerate(city_ids)}

    def get_dist(id1, id2):
        node1 = cities[id1]
        for edge in node1.out_edges:
            if edge.type == "RUTA" and edge.to_node.properties.get("id") == id2:
                return edge.properties.get("distancia", 999999)
        return 999999

    dist = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                dist[i][j] = get_dist(city_ids[i], city_ids[j])

    INF = float("inf")
    full_mask = (1 << n) - 1

    dp = {}
    parent = {}

    def solve(mask, pos):
        if mask == full_mask:
            return dist[pos][0]
        key = (mask, pos)
        if key in dp:
            return dp[key]
        best = INF
        best_next = -1
        for nxt in range(n):
            if not (mask & (1 << nxt)):
                cost = dist[pos][nxt] + solve(mask | (1 << nxt), nxt)
                if cost < best:
                    best = cost
                    best_next = nxt
        dp[key] = best
        parent[key] = best_next
        return best

    min_cost = solve(1, 0)

    route = [0]
    mask = 1
    pos = 0
    for _ in range(n - 1):
        nxt = parent.get((mask, pos), -1)
        if nxt == -1:
            break
        route.append(nxt)
        mask |= (1 << nxt)
        pos = nxt

    route_names = [cities[city_ids[i]].properties["nombre"] for i in route]
    return mgp.Record(distancia_total=int(min_cost), ruta=route_names)
