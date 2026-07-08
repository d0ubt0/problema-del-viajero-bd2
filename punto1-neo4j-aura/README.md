# Punto 1: Neo4j Aura - TSP con Cypher Puro

Resolución del Problema del Viajero (TSP) utilizando **únicamente Cypher** sobre **Neo4j Aura Free Tier** (nube). No se usa Python ni ningún driver externo — todo se ejecuta directamente en el navegador de Neo4j o via `cypher-shell`.

## Configuración de Neo4j Aura Free Tier

1. Ir a [https://neo4j.com/cloud/aura/](https://neo4j.com/cloud/aura/) y crear una cuenta gratuita.
2. Crear una nueva instancia **Aura Free** (Neo4j 5.x).
3. Anotar la **URI de conexión** (bolt://...), **usuario** y **contraseña**.
4. Abrir **Neo4j Browser** (incluido en la consola de Aura) o conectar con `cypher-shell`:
   ```bash
   cypher-shell -a "bolt://<tu-uri>" -u neo4j -p "<tu-password>"
   ```

## Archivos del Proyecto

| Archivo | Descripción |
|---------|-------------|
| `setup.cypher` | Crea el grafo completo: 20 ciudades + 380 relaciones RUTA (bidireccional) |
| `generate_tsp.py` | Generador de consultas TSP para N ciudades (lee `../shared/ciudades.json`) |
| `run.sh` | Script que genera e imprime las consultas TSP para N = 4, 6, ..., 20 |
| `cleanup.cypher` | Elimina todos los datos del grafo |

## Cómo Ejecutar

### 1. Cargar los datos

Copiar y pegar el contenido de `setup.cypher` en el Neo4j Browser. Ejecutar sentencia por sentencia (el Browser ejecuta una sentencia a la vez separada por `;`).

### 2. Generar y ejecutar consultas TSP

**Generar una consulta individual:**
```bash
python3 generate_tsp.py 8
```

**Generar y ejecutar todas (4 a 20 ciudades):**
```bash
./run.sh
```

Si `cypher-shell` está disponible y las variables `NEO4J_URI`, `NEO4J_USER`, `NEO4J_PASS` están configuradas, `run.sh` ejecuta cada consulta automáticamente con medición de tiempo. De lo contrario, imprime cada consulta para copiar y pegar en Neo4j Browser.

**Orden recomendado** (de menor a mayor complejidad):
```
N=4    →  instantáneo
N=6    →  instantáneo
N=8    →  segundos
N=10   →  minutos
N=12   →  posiblemente horas / timeout
N=14+  →  inviable (ver notas abajo)
```

### 3. Medir tiempos de ejecución

En **Neo4j Browser**, el tiempo de ejecución se muestra en la parte inferior del resultado de cada consulta.

Con **cypher-shell**, medir con `time`:
```bash
python3 generate_tsp.py 4 | time cypher-shell -a "bolt://<uri>" -u neo4j -p "<pass>"
python3 generate_tsp.py 6 | time cypher-shell -a "bolt://<uri>" -u neo4j -p "<pass>"
python3 generate_tsp.py 8 | time cypher-shell -a "bolt://<uri>" -u neo4j -p "<pass>"
```

## Enfoque: Fuerza Bruta en Cypher

Cada consulta TSP sigue este patrón:

1. **Fijar** Bogotá (id=0) como ciudad de inicio/fin.
2. **MATCH** las N-1 ciudades restantes sin fijar su posición.
3. **WHERE** restringe que cada variable solo pueda tomar IDs del subconjunto y que todas sean distintas.
4. **MATCH** las relaciones RUTA que forman el ciclo completo: n0→n1→n2→...→n(N-1)→n0.
5. **RETURN** la suma de distancias y la ruta, ordenado ascendente, LIMIT 1.

Esto genera todas las (N-1)! permutaciones y selecciona la de menor distancia.

## Notas sobre Escalabilidad

| Ciudades | Permutaciones | Viabilidad en Aura Free |
|----------|--------------|------------------------|
| 4 | 6 | Instantáneo |
| 6 | 120 | Instantáneo |
| 8 | 5,040 | Segundos |
| 10 | 362,880 | Minutos |
| 12 | 39,916,800 | Posible timeout (>30 min) |
| 14 | 6,227,020,800 | **Inviable** - timeout seguro |
| 16 | 1.3 × 10¹² | **Inviable** |
| 18 | 3.6 × 10¹⁴ | **Inviable** |
| 20 | 1.2 × 10¹⁷ | **Inviable** |

**Limitaciones de Neo4j Aura Free Tier:**
- Memoria RAM limitada (~256 MB - 1 GB).
- Timeout de consulta configurable pero limitado.
- No se puede ajustar `dbms.transaction.timeout` a valores muy altos.
- Las consultas de 12+ ciudades probablemente excedan los límites de memoria y tiempo.

**Conclusión:** El enfoque de fuerza bruta en Cypher puro es viable hasta **8-10 ciudades**. A partir de 12 ciudades, el crecimiento factorial hace que sea computacionalmente inviable sin algoritmos de poda (branch-and-bound) o heurísticas, los cuales no se pueden implementar fácilmente en Cypher puro.

## Datos

Las 20 ciudades colombianas y sus distancias se encuentran en `../shared/ciudades.json`.

Subconjuntos utilizados:
- **4**: Bogotá, Medellín, Cali, Barranquilla
- **6**: + Cartagena, Bucaramanga
- **8**: + Pereira, Manizales
- **10**: + Santa Marta, Cúcuta
- **12**: + Ibagué, Villavicencio
- **14**: + Pasto, Neiva
- **16**: + Armenia, Montería
- **18**: + Tunja, Popayán
- **20**: + Sincelejo, Valledupar
