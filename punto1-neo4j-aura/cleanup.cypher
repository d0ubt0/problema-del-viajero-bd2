// ============================================
// CLEANUP: Eliminar todos los datos del grafo
// Ejecutar en Neo4j Browser o Cypher Shell
// ============================================

// Eliminar todos los nodos y relaciones
MATCH (n) DETACH DELETE n;

// Verificar que el grafo está vacío
MATCH (n) RETURN count(n) AS nodos_restantes;
