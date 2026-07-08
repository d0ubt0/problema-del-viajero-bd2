if (typeof N === 'undefined') var N = 4;

db = db.getSiblingDB('tsp_colombia');

var subsets = {
  4: [0, 1, 2, 3],
  6: [0, 1, 2, 3, 4, 5],
  8: [0, 1, 2, 3, 4, 5, 6, 7],
  10: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  12: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  14: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
  16: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
  18: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
  20: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
  22: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21],
  24: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
  26: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
};

if (!subsets[N]) {
  print("Error: N=" + N + " no es valido. Use: 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26");
  quit(1);
}

var cityIds = subsets[N];
var n = cityIds.length;

var cityNames = {};
db.ciudades.find({id: {$in: cityIds}}).forEach(function(c) { cityNames[c.id] = c.nombre; });

var distDoc = db.distancias.findOne();
var fullMatrix = distDoc.matrix;

function getDist(a, b) { return fullMatrix[a][b]; }

function permute(arr) {
  var result = [];
  if (arr.length <= 1) return [arr];
  for (var i = 0; i < arr.length; i++) {
    var rest = arr.slice(0, i).concat(arr.slice(i + 1));
    var perms = permute(rest);
    for (var j = 0; j < perms.length; j++) {
      result.push([arr[i]].concat(perms[j]));
    }
  }
  return result;
}

function bruteForce() {
  var first = cityIds[0];
  var rest = cityIds.slice(1);
  var perms = permute(rest);

  var minDist = Infinity;
  var bestRoute = null;

  for (var i = 0; i < perms.length; i++) {
    var route = [first].concat(perms[i]);
    var dist = 0;
    for (var j = 0; j < route.length - 1; j++) {
      dist += getDist(route[j], route[j + 1]);
    }
    dist += getDist(route[route.length - 1], route[0]);
    if (dist < minDist) {
      minDist = dist;
      bestRoute = route.slice();
    }
  }

  return {cost: minDist, route: bestRoute, permutations: perms.length};
}

function heldKarp() {
  var dist = [];
  for (var i = 0; i < n; i++) {
    dist[i] = [];
    for (var j = 0; j < n; j++) {
      dist[i][j] = fullMatrix[cityIds[i]][cityIds[j]];
    }
  }

  var size = 1 << n;
  var INF = 1e15;

  var dp = [];
  var parent = [];
  for (var s = 0; s < size; s++) {
    dp[s] = [];
    parent[s] = [];
    for (var i = 0; i < n; i++) {
      dp[s][i] = INF;
      parent[s][i] = -1;
    }
  }

  dp[1][0] = 0;

  for (var mask = 1; mask < size; mask++) {
    if (!(mask & 1)) continue;
    for (var u = 0; u < n; u++) {
      if (!(mask & (1 << u))) continue;
      if (dp[mask][u] === INF) continue;
      for (var v = 0; v < n; v++) {
        if (mask & (1 << v)) continue;
        var newMask = mask | (1 << v);
        var newCost = dp[mask][u] + dist[u][v];
        if (newCost < dp[newMask][v]) {
          dp[newMask][v] = newCost;
          parent[newMask][v] = u;
        }
      }
    }
  }

  var fullMask = size - 1;
  var minCost = INF;
  var lastCity = -1;
  for (var u = 1; u < n; u++) {
    var cost = dp[fullMask][u] + dist[u][0];
    if (cost < minCost) {
      minCost = cost;
      lastCity = u;
    }
  }

  var route = [];
  var mask = fullMask;
  var curr = lastCity;
  while (curr !== -1) {
    route.push(curr);
    var prev = parent[mask][curr];
    mask = mask ^ (1 << curr);
    curr = prev;
  }
  route.reverse();

  var routeIds = route.map(function(idx) { return cityIds[idx]; });
  return {cost: minCost, route: routeIds};
}

print("=== TSP " + N + " Ciudades ===");
print("");

if (N <= 10) {
  var startBF = new Date();
  var resultBF = bruteForce();
  var endBF = new Date();
  var elapsedBF = endBF - startBF;

  var routeNamesBF = resultBF.route.map(function(id) { return cityNames[id]; });
  print("[Fuerza Bruta]");
  print("Ruta optima: " + routeNamesBF.join(" -> ") + " -> " + routeNamesBF[0]);
  print("IDs: " + resultBF.route.join(" -> ") + " -> " + resultBF.route[0]);
  print("Distancia total: " + resultBF.cost + " km");
  print("Tiempo: " + elapsedBF + "ms");
  print("Permutaciones evaluadas: " + resultBF.permutations);
  print("");
}

var startHK = new Date();
var resultHK = heldKarp();
var endHK = new Date();
var elapsedHK = endHK - startHK;

var routeNamesHK = resultHK.route.map(function(id) { return cityNames[id]; });
print("[Held-Karp DP]");
print("Ruta optima: " + routeNamesHK.join(" -> ") + " -> " + routeNamesHK[0]);
print("IDs: " + resultHK.route.join(" -> ") + " -> " + resultHK.route[0]);
print("Distancia total: " + resultHK.cost + " km");
print("Tiempo: " + elapsedHK + "ms");
print("Complejidad: O(2^n * n^2) con n=" + n);
