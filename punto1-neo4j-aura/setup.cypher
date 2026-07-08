// ============================================
// SETUP: Crear grafo completo de 26 ciudades
// Ejecutar en Neo4j Browser o Cypher Shell
// ============================================

// Limpiar datos existentes
MATCH (n) DETACH DELETE n;

// Crear índices para búsqueda eficiente
CREATE INDEX ciudad_id IF NOT EXISTS FOR (c:Ciudad) ON (c.id);
CREATE INDEX ciudad_nombre IF NOT EXISTS FOR (c:Ciudad) ON (c.nombre);

// ---- Crear nodos Ciudad ----
MERGE (:Ciudad {id: 0, nombre: 'Bogotá'});
MERGE (:Ciudad {id: 1, nombre: 'Medellín'});
MERGE (:Ciudad {id: 2, nombre: 'Cali'});
MERGE (:Ciudad {id: 3, nombre: 'Barranquilla'});
MERGE (:Ciudad {id: 4, nombre: 'Cartagena'});
MERGE (:Ciudad {id: 5, nombre: 'Bucaramanga'});
MERGE (:Ciudad {id: 6, nombre: 'Pereira'});
MERGE (:Ciudad {id: 7, nombre: 'Manizales'});
MERGE (:Ciudad {id: 8, nombre: 'Santa Marta'});
MERGE (:Ciudad {id: 9, nombre: 'Cúcuta'});
MERGE (:Ciudad {id: 10, nombre: 'Ibagué'});
MERGE (:Ciudad {id: 11, nombre: 'Villavicencio'});
MERGE (:Ciudad {id: 12, nombre: 'Pasto'});
MERGE (:Ciudad {id: 13, nombre: 'Neiva'});
MERGE (:Ciudad {id: 14, nombre: 'Armenia'});
MERGE (:Ciudad {id: 15, nombre: 'Montería'});
MERGE (:Ciudad {id: 16, nombre: 'Tunja'});
MERGE (:Ciudad {id: 17, nombre: 'Popayán'});
MERGE (:Ciudad {id: 18, nombre: 'Sincelejo'});
MERGE (:Ciudad {id: 19, nombre: 'Valledupar'});
MERGE (:Ciudad {id: 20, nombre: 'Riohacha'});
MERGE (:Ciudad {id: 21, nombre: 'Arauca'});
MERGE (:Ciudad {id: 22, nombre: 'Yopal'});
MERGE (:Ciudad {id: 23, nombre: 'Florencia'});
MERGE (:Ciudad {id: 24, nombre: 'Quibdó'});
MERGE (:Ciudad {id: 25, nombre: 'Girardot'});

// ---- Crear relaciones RUTA (grafo completo, ambas direcciones) ----
// Bogotá <-> Medellín: 411 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 1})
MERGE (a)-[:RUTA {distancia: 411}]->(b)
MERGE (b)-[:RUTA {distancia: 411}]->(a);
// Bogotá <-> Cali: 486 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 2})
MERGE (a)-[:RUTA {distancia: 486}]->(b)
MERGE (b)-[:RUTA {distancia: 486}]->(a);
// Bogotá <-> Barranquilla: 984 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 3})
MERGE (a)-[:RUTA {distancia: 984}]->(b)
MERGE (b)-[:RUTA {distancia: 984}]->(a);
// Bogotá <-> Cartagena: 1061 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 4})
MERGE (a)-[:RUTA {distancia: 1061}]->(b)
MERGE (b)-[:RUTA {distancia: 1061}]->(a);
// Bogotá <-> Bucaramanga: 397 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 5})
MERGE (a)-[:RUTA {distancia: 397}]->(b)
MERGE (b)-[:RUTA {distancia: 397}]->(a);
// Bogotá <-> Pereira: 335 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 6})
MERGE (a)-[:RUTA {distancia: 335}]->(b)
MERGE (b)-[:RUTA {distancia: 335}]->(a);
// Bogotá <-> Manizales: 297 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 297}]->(b)
MERGE (b)-[:RUTA {distancia: 297}]->(a);
// Bogotá <-> Santa Marta: 930 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 930}]->(b)
MERGE (b)-[:RUTA {distancia: 930}]->(a);
// Bogotá <-> Cúcuta: 470 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 470}]->(b)
MERGE (b)-[:RUTA {distancia: 470}]->(a);
// Bogotá <-> Ibagué: 209 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 209}]->(b)
MERGE (b)-[:RUTA {distancia: 209}]->(a);
// Bogotá <-> Villavicencio: 128 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 128}]->(b)
MERGE (b)-[:RUTA {distancia: 128}]->(a);
// Bogotá <-> Pasto: 798 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 798}]->(b)
MERGE (b)-[:RUTA {distancia: 798}]->(a);
// Bogotá <-> Neiva: 295 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 295}]->(b)
MERGE (b)-[:RUTA {distancia: 295}]->(a);
// Bogotá <-> Armenia: 292 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 292}]->(b)
MERGE (b)-[:RUTA {distancia: 292}]->(a);
// Bogotá <-> Montería: 686 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 686}]->(b)
MERGE (b)-[:RUTA {distancia: 686}]->(a);
// Bogotá <-> Tunja: 145 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 145}]->(b)
MERGE (b)-[:RUTA {distancia: 145}]->(a);
// Bogotá <-> Popayán: 608 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 608}]->(b)
MERGE (b)-[:RUTA {distancia: 608}]->(a);
// Bogotá <-> Sincelejo: 741 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 741}]->(b)
MERGE (b)-[:RUTA {distancia: 741}]->(a);
// Bogotá <-> Valledupar: 837 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 837}]->(b)
MERGE (b)-[:RUTA {distancia: 837}]->(a);
// Bogotá <-> Riohacha: 771 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 771}]->(b)
MERGE (b)-[:RUTA {distancia: 771}]->(a);
// Bogotá <-> Arauca: 452 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 452}]->(b)
MERGE (b)-[:RUTA {distancia: 452}]->(a);
// Bogotá <-> Yopal: 198 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 198}]->(b)
MERGE (b)-[:RUTA {distancia: 198}]->(a);
// Bogotá <-> Florencia: 384 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 384}]->(b)
MERGE (b)-[:RUTA {distancia: 384}]->(a);
// Bogotá <-> Quibdó: 307 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 307}]->(b)
MERGE (b)-[:RUTA {distancia: 307}]->(a);
// Bogotá <-> Girardot: 93 km
MATCH (a:Ciudad {id: 0}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 93}]->(b)
MERGE (b)-[:RUTA {distancia: 93}]->(a);
// Medellín <-> Cali: 421 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 2})
MERGE (a)-[:RUTA {distancia: 421}]->(b)
MERGE (b)-[:RUTA {distancia: 421}]->(a);
// Medellín <-> Barranquilla: 702 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 3})
MERGE (a)-[:RUTA {distancia: 702}]->(b)
MERGE (b)-[:RUTA {distancia: 702}]->(a);
// Medellín <-> Cartagena: 741 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 4})
MERGE (a)-[:RUTA {distancia: 741}]->(b)
MERGE (b)-[:RUTA {distancia: 741}]->(a);
// Medellín <-> Bucaramanga: 599 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 5})
MERGE (a)-[:RUTA {distancia: 599}]->(b)
MERGE (b)-[:RUTA {distancia: 599}]->(a);
// Medellín <-> Pereira: 218 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 6})
MERGE (a)-[:RUTA {distancia: 218}]->(b)
MERGE (b)-[:RUTA {distancia: 218}]->(a);
// Medellín <-> Manizales: 260 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 260}]->(b)
MERGE (b)-[:RUTA {distancia: 260}]->(a);
// Medellín <-> Santa Marta: 756 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 756}]->(b)
MERGE (b)-[:RUTA {distancia: 756}]->(a);
// Medellín <-> Cúcuta: 580 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 580}]->(b)
MERGE (b)-[:RUTA {distancia: 580}]->(a);
// Medellín <-> Ibagué: 307 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 307}]->(b)
MERGE (b)-[:RUTA {distancia: 307}]->(a);
// Medellín <-> Villavicencio: 398 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 398}]->(b)
MERGE (b)-[:RUTA {distancia: 398}]->(a);
// Medellín <-> Pasto: 838 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 838}]->(b)
MERGE (b)-[:RUTA {distancia: 838}]->(a);
// Medellín <-> Neiva: 614 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 614}]->(b)
MERGE (b)-[:RUTA {distancia: 614}]->(a);
// Medellín <-> Armenia: 218 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 218}]->(b)
MERGE (b)-[:RUTA {distancia: 218}]->(a);
// Medellín <-> Montería: 413 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 413}]->(b)
MERGE (b)-[:RUTA {distancia: 413}]->(a);
// Medellín <-> Tunja: 509 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 509}]->(b)
MERGE (b)-[:RUTA {distancia: 509}]->(a);
// Medellín <-> Popayán: 573 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 573}]->(b)
MERGE (b)-[:RUTA {distancia: 573}]->(a);
// Medellín <-> Sincelejo: 538 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 538}]->(b)
MERGE (b)-[:RUTA {distancia: 538}]->(a);
// Medellín <-> Valledupar: 735 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 735}]->(b)
MERGE (b)-[:RUTA {distancia: 735}]->(a);
// Medellín <-> Riohacha: 658 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 658}]->(b)
MERGE (b)-[:RUTA {distancia: 658}]->(a);
// Medellín <-> Arauca: 541 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 541}]->(b)
MERGE (b)-[:RUTA {distancia: 541}]->(a);
// Medellín <-> Yopal: 366 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 366}]->(b)
MERGE (b)-[:RUTA {distancia: 366}]->(a);
// Medellín <-> Florencia: 515 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 515}]->(b)
MERGE (b)-[:RUTA {distancia: 515}]->(a);
// Medellín <-> Quibdó: 134 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 134}]->(b)
MERGE (b)-[:RUTA {distancia: 134}]->(a);
// Medellín <-> Girardot: 232 km
MATCH (a:Ciudad {id: 1}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 232}]->(b)
MERGE (b)-[:RUTA {distancia: 232}]->(a);
// Cali <-> Barranquilla: 1098 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 3})
MERGE (a)-[:RUTA {distancia: 1098}]->(b)
MERGE (b)-[:RUTA {distancia: 1098}]->(a);
// Cali <-> Cartagena: 1145 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 4})
MERGE (a)-[:RUTA {distancia: 1145}]->(b)
MERGE (b)-[:RUTA {distancia: 1145}]->(a);
// Cali <-> Bucaramanga: 893 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 5})
MERGE (a)-[:RUTA {distancia: 893}]->(b)
MERGE (b)-[:RUTA {distancia: 893}]->(a);
// Cali <-> Pereira: 249 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 6})
MERGE (a)-[:RUTA {distancia: 249}]->(b)
MERGE (b)-[:RUTA {distancia: 249}]->(a);
// Cali <-> Manizales: 291 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 291}]->(b)
MERGE (b)-[:RUTA {distancia: 291}]->(a);
// Cali <-> Santa Marta: 1152 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 1152}]->(b)
MERGE (b)-[:RUTA {distancia: 1152}]->(a);
// Cali <-> Cúcuta: 876 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 876}]->(b)
MERGE (b)-[:RUTA {distancia: 876}]->(a);
// Cali <-> Ibagué: 312 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 312}]->(b)
MERGE (b)-[:RUTA {distancia: 312}]->(a);
// Cali <-> Villavicencio: 507 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 507}]->(b)
MERGE (b)-[:RUTA {distancia: 507}]->(a);
// Cali <-> Pasto: 515 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 515}]->(b)
MERGE (b)-[:RUTA {distancia: 515}]->(a);
// Cali <-> Neiva: 415 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 415}]->(b)
MERGE (b)-[:RUTA {distancia: 415}]->(a);
// Cali <-> Armenia: 230 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 230}]->(b)
MERGE (b)-[:RUTA {distancia: 230}]->(a);
// Cali <-> Montería: 740 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 740}]->(b)
MERGE (b)-[:RUTA {distancia: 740}]->(a);
// Cali <-> Tunja: 624 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 624}]->(b)
MERGE (b)-[:RUTA {distancia: 624}]->(a);
// Cali <-> Popayán: 141 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 141}]->(b)
MERGE (b)-[:RUTA {distancia: 141}]->(a);
// Cali <-> Sincelejo: 879 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 879}]->(b)
MERGE (b)-[:RUTA {distancia: 879}]->(a);
// Cali <-> Valledupar: 1089 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 1089}]->(b)
MERGE (b)-[:RUTA {distancia: 1089}]->(a);
// Cali <-> Riohacha: 984 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 984}]->(b)
MERGE (b)-[:RUTA {distancia: 984}]->(a);
// Cali <-> Arauca: 756 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 756}]->(b)
MERGE (b)-[:RUTA {distancia: 756}]->(a);
// Cali <-> Yopal: 504 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 504}]->(b)
MERGE (b)-[:RUTA {distancia: 504}]->(a);
// Cali <-> Florencia: 229 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 229}]->(b)
MERGE (b)-[:RUTA {distancia: 229}]->(a);
// Cali <-> Quibdó: 250 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 250}]->(b)
MERGE (b)-[:RUTA {distancia: 250}]->(a);
// Cali <-> Girardot: 214 km
MATCH (a:Ciudad {id: 2}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 214}]->(b)
MERGE (b)-[:RUTA {distancia: 214}]->(a);
// Barranquilla <-> Cartagena: 102 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 4})
MERGE (a)-[:RUTA {distancia: 102}]->(b)
MERGE (b)-[:RUTA {distancia: 102}]->(a);
// Barranquilla <-> Bucaramanga: 695 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 5})
MERGE (a)-[:RUTA {distancia: 695}]->(b)
MERGE (b)-[:RUTA {distancia: 695}]->(a);
// Barranquilla <-> Pereira: 775 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 6})
MERGE (a)-[:RUTA {distancia: 775}]->(b)
MERGE (b)-[:RUTA {distancia: 775}]->(a);
// Barranquilla <-> Manizales: 817 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 817}]->(b)
MERGE (b)-[:RUTA {distancia: 817}]->(a);
// Barranquilla <-> Santa Marta: 172 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 172}]->(b)
MERGE (b)-[:RUTA {distancia: 172}]->(a);
// Barranquilla <-> Cúcuta: 644 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 644}]->(b)
MERGE (b)-[:RUTA {distancia: 644}]->(a);
// Barranquilla <-> Ibagué: 876 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 876}]->(b)
MERGE (b)-[:RUTA {distancia: 876}]->(a);
// Barranquilla <-> Villavicencio: 1012 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 1012}]->(b)
MERGE (b)-[:RUTA {distancia: 1012}]->(a);
// Barranquilla <-> Pasto: 1613 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 1613}]->(b)
MERGE (b)-[:RUTA {distancia: 1613}]->(a);
// Barranquilla <-> Neiva: 1164 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 1164}]->(b)
MERGE (b)-[:RUTA {distancia: 1164}]->(a);
// Barranquilla <-> Armenia: 756 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 756}]->(b)
MERGE (b)-[:RUTA {distancia: 756}]->(a);
// Barranquilla <-> Montería: 301 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 301}]->(b)
MERGE (b)-[:RUTA {distancia: 301}]->(a);
// Barranquilla <-> Tunja: 854 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 854}]->(b)
MERGE (b)-[:RUTA {distancia: 854}]->(a);
// Barranquilla <-> Popayán: 1234 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 1234}]->(b)
MERGE (b)-[:RUTA {distancia: 1234}]->(a);
// Barranquilla <-> Sincelejo: 248 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 248}]->(b)
MERGE (b)-[:RUTA {distancia: 248}]->(a);
// Barranquilla <-> Valledupar: 282 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 282}]->(b)
MERGE (b)-[:RUTA {distancia: 282}]->(a);
// Barranquilla <-> Riohacha: 216 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 216}]->(b)
MERGE (b)-[:RUTA {distancia: 216}]->(a);
// Barranquilla <-> Arauca: 619 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 619}]->(b)
MERGE (b)-[:RUTA {distancia: 619}]->(a);
// Barranquilla <-> Yopal: 679 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 679}]->(b)
MERGE (b)-[:RUTA {distancia: 679}]->(a);
// Barranquilla <-> Florencia: 1043 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 1043}]->(b)
MERGE (b)-[:RUTA {distancia: 1043}]->(a);
// Barranquilla <-> Quibdó: 621 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 621}]->(b)
MERGE (b)-[:RUTA {distancia: 621}]->(a);
// Barranquilla <-> Girardot: 740 km
MATCH (a:Ciudad {id: 3}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 740}]->(b)
MERGE (b)-[:RUTA {distancia: 740}]->(a);
// Cartagena <-> Bucaramanga: 669 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 5})
MERGE (a)-[:RUTA {distancia: 669}]->(b)
MERGE (b)-[:RUTA {distancia: 669}]->(a);
// Cartagena <-> Pereira: 814 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 6})
MERGE (a)-[:RUTA {distancia: 814}]->(b)
MERGE (b)-[:RUTA {distancia: 814}]->(a);
// Cartagena <-> Manizales: 856 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 856}]->(b)
MERGE (b)-[:RUTA {distancia: 856}]->(a);
// Cartagena <-> Santa Marta: 224 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 224}]->(b)
MERGE (b)-[:RUTA {distancia: 224}]->(a);
// Cartagena <-> Cúcuta: 622 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 622}]->(b)
MERGE (b)-[:RUTA {distancia: 622}]->(a);
// Cartagena <-> Ibagué: 915 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 915}]->(b)
MERGE (b)-[:RUTA {distancia: 915}]->(a);
// Cartagena <-> Villavicencio: 1051 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 1051}]->(b)
MERGE (b)-[:RUTA {distancia: 1051}]->(a);
// Cartagena <-> Pasto: 1652 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 1652}]->(b)
MERGE (b)-[:RUTA {distancia: 1652}]->(a);
// Cartagena <-> Neiva: 1203 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 1203}]->(b)
MERGE (b)-[:RUTA {distancia: 1203}]->(a);
// Cartagena <-> Armenia: 795 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 795}]->(b)
MERGE (b)-[:RUTA {distancia: 795}]->(a);
// Cartagena <-> Montería: 261 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 261}]->(b)
MERGE (b)-[:RUTA {distancia: 261}]->(a);
// Cartagena <-> Tunja: 828 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 828}]->(b)
MERGE (b)-[:RUTA {distancia: 828}]->(a);
// Cartagena <-> Popayán: 1273 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 1273}]->(b)
MERGE (b)-[:RUTA {distancia: 1273}]->(a);
// Cartagena <-> Sincelejo: 208 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 208}]->(b)
MERGE (b)-[:RUTA {distancia: 208}]->(a);
// Cartagena <-> Valledupar: 341 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 341}]->(b)
MERGE (b)-[:RUTA {distancia: 341}]->(a);
// Cartagena <-> Riohacha: 312 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 312}]->(b)
MERGE (b)-[:RUTA {distancia: 312}]->(a);
// Cartagena <-> Arauca: 639 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 639}]->(b)
MERGE (b)-[:RUTA {distancia: 639}]->(a);
// Cartagena <-> Yopal: 658 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 658}]->(b)
MERGE (b)-[:RUTA {distancia: 658}]->(a);
// Cartagena <-> Florencia: 976 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 976}]->(b)
MERGE (b)-[:RUTA {distancia: 976}]->(a);
// Cartagena <-> Quibdó: 537 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 537}]->(b)
MERGE (b)-[:RUTA {distancia: 537}]->(a);
// Cartagena <-> Girardot: 681 km
MATCH (a:Ciudad {id: 4}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 681}]->(b)
MERGE (b)-[:RUTA {distancia: 681}]->(a);
// Bucaramanga <-> Pereira: 600 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 6})
MERGE (a)-[:RUTA {distancia: 600}]->(b)
MERGE (b)-[:RUTA {distancia: 600}]->(a);
// Bucaramanga <-> Manizales: 562 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 562}]->(b)
MERGE (b)-[:RUTA {distancia: 562}]->(a);
// Bucaramanga <-> Santa Marta: 580 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 580}]->(b)
MERGE (b)-[:RUTA {distancia: 580}]->(a);
// Bucaramanga <-> Cúcuta: 195 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 195}]->(b)
MERGE (b)-[:RUTA {distancia: 195}]->(a);
// Bucaramanga <-> Ibagué: 365 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 365}]->(b)
MERGE (b)-[:RUTA {distancia: 365}]->(a);
// Bucaramanga <-> Villavicencio: 430 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 430}]->(b)
MERGE (b)-[:RUTA {distancia: 430}]->(a);
// Bucaramanga <-> Pasto: 1092 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 1092}]->(b)
MERGE (b)-[:RUTA {distancia: 1092}]->(a);
// Bucaramanga <-> Neiva: 660 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 660}]->(b)
MERGE (b)-[:RUTA {distancia: 660}]->(a);
// Bucaramanga <-> Armenia: 581 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 581}]->(b)
MERGE (b)-[:RUTA {distancia: 581}]->(a);
// Bucaramanga <-> Montería: 510 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 510}]->(b)
MERGE (b)-[:RUTA {distancia: 510}]->(a);
// Bucaramanga <-> Tunja: 252 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 252}]->(b)
MERGE (b)-[:RUTA {distancia: 252}]->(a);
// Bucaramanga <-> Popayán: 867 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 867}]->(b)
MERGE (b)-[:RUTA {distancia: 867}]->(a);
// Bucaramanga <-> Sincelejo: 430 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 430}]->(b)
MERGE (b)-[:RUTA {distancia: 430}]->(a);
// Bucaramanga <-> Valledupar: 433 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 433}]->(b)
MERGE (b)-[:RUTA {distancia: 433}]->(a);
// Bucaramanga <-> Riohacha: 492 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 492}]->(b)
MERGE (b)-[:RUTA {distancia: 492}]->(a);
// Bucaramanga <-> Arauca: 261 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 261}]->(b)
MERGE (b)-[:RUTA {distancia: 261}]->(a);
// Bucaramanga <-> Yopal: 214 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 214}]->(b)
MERGE (b)-[:RUTA {distancia: 214}]->(a);
// Bucaramanga <-> Florencia: 672 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 672}]->(b)
MERGE (b)-[:RUTA {distancia: 672}]->(a);
// Bucaramanga <-> Quibdó: 422 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 422}]->(b)
MERGE (b)-[:RUTA {distancia: 422}]->(a);
// Bucaramanga <-> Girardot: 365 km
MATCH (a:Ciudad {id: 5}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 365}]->(b)
MERGE (b)-[:RUTA {distancia: 365}]->(a);
// Pereira <-> Manizales: 72 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 7})
MERGE (a)-[:RUTA {distancia: 72}]->(b)
MERGE (b)-[:RUTA {distancia: 72}]->(a);
// Pereira <-> Santa Marta: 810 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 810}]->(b)
MERGE (b)-[:RUTA {distancia: 810}]->(a);
// Pereira <-> Cúcuta: 561 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 561}]->(b)
MERGE (b)-[:RUTA {distancia: 561}]->(a);
// Pereira <-> Ibagué: 113 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 113}]->(b)
MERGE (b)-[:RUTA {distancia: 113}]->(a);
// Pereira <-> Villavicencio: 380 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 380}]->(b)
MERGE (b)-[:RUTA {distancia: 380}]->(a);
// Pereira <-> Pasto: 670 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 670}]->(b)
MERGE (b)-[:RUTA {distancia: 670}]->(a);
// Pereira <-> Neiva: 446 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 446}]->(b)
MERGE (b)-[:RUTA {distancia: 446}]->(a);
// Pereira <-> Armenia: 50 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 50}]->(b)
MERGE (b)-[:RUTA {distancia: 50}]->(a);
// Pereira <-> Montería: 486 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 486}]->(b)
MERGE (b)-[:RUTA {distancia: 486}]->(a);
// Pereira <-> Tunja: 450 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 450}]->(b)
MERGE (b)-[:RUTA {distancia: 450}]->(a);
// Pereira <-> Popayán: 405 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 405}]->(b)
MERGE (b)-[:RUTA {distancia: 405}]->(a);
// Pereira <-> Sincelejo: 611 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 611}]->(b)
MERGE (b)-[:RUTA {distancia: 611}]->(a);
// Pereira <-> Valledupar: 789 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 789}]->(b)
MERGE (b)-[:RUTA {distancia: 789}]->(a);
// Pereira <-> Riohacha: 809 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 809}]->(b)
MERGE (b)-[:RUTA {distancia: 809}]->(a);
// Pereira <-> Arauca: 602 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 602}]->(b)
MERGE (b)-[:RUTA {distancia: 602}]->(a);
// Pereira <-> Yopal: 370 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 370}]->(b)
MERGE (b)-[:RUTA {distancia: 370}]->(a);
// Pereira <-> Florencia: 356 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 356}]->(b)
MERGE (b)-[:RUTA {distancia: 356}]->(a);
// Pereira <-> Quibdó: 145 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 145}]->(b)
MERGE (b)-[:RUTA {distancia: 145}]->(a);
// Pereira <-> Girardot: 114 km
MATCH (a:Ciudad {id: 6}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 114}]->(b)
MERGE (b)-[:RUTA {distancia: 114}]->(a);
// Manizales <-> Santa Marta: 852 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 8})
MERGE (a)-[:RUTA {distancia: 852}]->(b)
MERGE (b)-[:RUTA {distancia: 852}]->(a);
// Manizales <-> Cúcuta: 523 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 523}]->(b)
MERGE (b)-[:RUTA {distancia: 523}]->(a);
// Manizales <-> Ibagué: 143 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 143}]->(b)
MERGE (b)-[:RUTA {distancia: 143}]->(a);
// Manizales <-> Villavicencio: 342 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 342}]->(b)
MERGE (b)-[:RUTA {distancia: 342}]->(a);
// Manizales <-> Pasto: 712 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 712}]->(b)
MERGE (b)-[:RUTA {distancia: 712}]->(a);
// Manizales <-> Neiva: 488 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 488}]->(b)
MERGE (b)-[:RUTA {distancia: 488}]->(a);
// Manizales <-> Armenia: 72 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 72}]->(b)
MERGE (b)-[:RUTA {distancia: 72}]->(a);
// Manizales <-> Montería: 528 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 528}]->(b)
MERGE (b)-[:RUTA {distancia: 528}]->(a);
// Manizales <-> Tunja: 412 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 412}]->(b)
MERGE (b)-[:RUTA {distancia: 412}]->(a);
// Manizales <-> Popayán: 447 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 447}]->(b)
MERGE (b)-[:RUTA {distancia: 447}]->(a);
// Manizales <-> Sincelejo: 653 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 653}]->(b)
MERGE (b)-[:RUTA {distancia: 653}]->(a);
// Manizales <-> Valledupar: 831 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 831}]->(b)
MERGE (b)-[:RUTA {distancia: 831}]->(a);
// Manizales <-> Riohacha: 775 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 775}]->(b)
MERGE (b)-[:RUTA {distancia: 775}]->(a);
// Manizales <-> Arauca: 572 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 572}]->(b)
MERGE (b)-[:RUTA {distancia: 572}]->(a);
// Manizales <-> Yopal: 347 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 347}]->(b)
MERGE (b)-[:RUTA {distancia: 347}]->(a);
// Manizales <-> Florencia: 384 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 384}]->(b)
MERGE (b)-[:RUTA {distancia: 384}]->(a);
// Manizales <-> Quibdó: 144 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 144}]->(b)
MERGE (b)-[:RUTA {distancia: 144}]->(a);
// Manizales <-> Girardot: 116 km
MATCH (a:Ciudad {id: 7}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 116}]->(b)
MERGE (b)-[:RUTA {distancia: 116}]->(a);
// Santa Marta <-> Cúcuta: 490 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 9})
MERGE (a)-[:RUTA {distancia: 490}]->(b)
MERGE (b)-[:RUTA {distancia: 490}]->(a);
// Santa Marta <-> Ibagué: 822 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 822}]->(b)
MERGE (b)-[:RUTA {distancia: 822}]->(a);
// Santa Marta <-> Villavicencio: 958 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 958}]->(b)
MERGE (b)-[:RUTA {distancia: 958}]->(a);
// Santa Marta <-> Pasto: 1559 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 1559}]->(b)
MERGE (b)-[:RUTA {distancia: 1559}]->(a);
// Santa Marta <-> Neiva: 1110 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 1110}]->(b)
MERGE (b)-[:RUTA {distancia: 1110}]->(a);
// Santa Marta <-> Armenia: 802 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 802}]->(b)
MERGE (b)-[:RUTA {distancia: 802}]->(a);
// Santa Marta <-> Montería: 355 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 355}]->(b)
MERGE (b)-[:RUTA {distancia: 355}]->(a);
// Santa Marta <-> Tunja: 780 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 780}]->(b)
MERGE (b)-[:RUTA {distancia: 780}]->(a);
// Santa Marta <-> Popayán: 1180 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 1180}]->(b)
MERGE (b)-[:RUTA {distancia: 1180}]->(a);
// Santa Marta <-> Sincelejo: 294 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 294}]->(b)
MERGE (b)-[:RUTA {distancia: 294}]->(a);
// Santa Marta <-> Valledupar: 268 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 268}]->(b)
MERGE (b)-[:RUTA {distancia: 268}]->(a);
// Santa Marta <-> Riohacha: 145 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 145}]->(b)
MERGE (b)-[:RUTA {distancia: 145}]->(a);
// Santa Marta <-> Arauca: 597 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 597}]->(b)
MERGE (b)-[:RUTA {distancia: 597}]->(a);
// Santa Marta <-> Yopal: 686 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 686}]->(b)
MERGE (b)-[:RUTA {distancia: 686}]->(a);
// Santa Marta <-> Florencia: 1082 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 1082}]->(b)
MERGE (b)-[:RUTA {distancia: 1082}]->(a);
// Santa Marta <-> Quibdó: 673 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 673}]->(b)
MERGE (b)-[:RUTA {distancia: 673}]->(a);
// Santa Marta <-> Girardot: 774 km
MATCH (a:Ciudad {id: 8}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 774}]->(b)
MERGE (b)-[:RUTA {distancia: 774}]->(a);
// Cúcuta <-> Ibagué: 440 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 10})
MERGE (a)-[:RUTA {distancia: 440}]->(b)
MERGE (b)-[:RUTA {distancia: 440}]->(a);
// Cúcuta <-> Villavicencio: 505 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 505}]->(b)
MERGE (b)-[:RUTA {distancia: 505}]->(a);
// Cúcuta <-> Pasto: 1065 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 1065}]->(b)
MERGE (b)-[:RUTA {distancia: 1065}]->(a);
// Cúcuta <-> Neiva: 735 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 735}]->(b)
MERGE (b)-[:RUTA {distancia: 735}]->(a);
// Cúcuta <-> Armenia: 542 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 542}]->(b)
MERGE (b)-[:RUTA {distancia: 542}]->(a);
// Cúcuta <-> Montería: 543 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 543}]->(b)
MERGE (b)-[:RUTA {distancia: 543}]->(a);
// Cúcuta <-> Tunja: 327 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 327}]->(b)
MERGE (b)-[:RUTA {distancia: 327}]->(a);
// Cúcuta <-> Popayán: 840 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 840}]->(b)
MERGE (b)-[:RUTA {distancia: 840}]->(a);
// Cúcuta <-> Sincelejo: 463 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 463}]->(b)
MERGE (b)-[:RUTA {distancia: 463}]->(a);
// Cúcuta <-> Valledupar: 238 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 238}]->(b)
MERGE (b)-[:RUTA {distancia: 238}]->(a);
// Cúcuta <-> Riohacha: 408 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 408}]->(b)
MERGE (b)-[:RUTA {distancia: 408}]->(a);
// Cúcuta <-> Arauca: 213 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 213}]->(b)
MERGE (b)-[:RUTA {distancia: 213}]->(a);
// Cúcuta <-> Yopal: 284 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 284}]->(b)
MERGE (b)-[:RUTA {distancia: 284}]->(a);
// Cúcuta <-> Florencia: 778 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 778}]->(b)
MERGE (b)-[:RUTA {distancia: 778}]->(a);
// Cúcuta <-> Quibdó: 519 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 519}]->(b)
MERGE (b)-[:RUTA {distancia: 519}]->(a);
// Cúcuta <-> Girardot: 473 km
MATCH (a:Ciudad {id: 9}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 473}]->(b)
MERGE (b)-[:RUTA {distancia: 473}]->(a);
// Ibagué <-> Villavicencio: 237 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 11})
MERGE (a)-[:RUTA {distancia: 237}]->(b)
MERGE (b)-[:RUTA {distancia: 237}]->(a);
// Ibagué <-> Pasto: 590 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 590}]->(b)
MERGE (b)-[:RUTA {distancia: 590}]->(a);
// Ibagué <-> Neiva: 209 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 209}]->(b)
MERGE (b)-[:RUTA {distancia: 209}]->(a);
// Ibagué <-> Armenia: 94 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 94}]->(b)
MERGE (b)-[:RUTA {distancia: 94}]->(a);
// Ibagué <-> Montería: 586 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 586}]->(b)
MERGE (b)-[:RUTA {distancia: 586}]->(a);
// Ibagué <-> Tunja: 310 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 310}]->(b)
MERGE (b)-[:RUTA {distancia: 310}]->(a);
// Ibagué <-> Popayán: 430 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 430}]->(b)
MERGE (b)-[:RUTA {distancia: 430}]->(a);
// Ibagué <-> Sincelejo: 711 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 711}]->(b)
MERGE (b)-[:RUTA {distancia: 711}]->(a);
// Ibagué <-> Valledupar: 813 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 813}]->(b)
MERGE (b)-[:RUTA {distancia: 813}]->(a);
// Ibagué <-> Riohacha: 830 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 830}]->(b)
MERGE (b)-[:RUTA {distancia: 830}]->(a);
// Ibagué <-> Arauca: 576 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 576}]->(b)
MERGE (b)-[:RUTA {distancia: 576}]->(a);
// Ibagué <-> Yopal: 330 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 330}]->(b)
MERGE (b)-[:RUTA {distancia: 330}]->(a);
// Ibagué <-> Florencia: 317 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 317}]->(b)
MERGE (b)-[:RUTA {distancia: 317}]->(a);
// Ibagué <-> Quibdó: 211 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 211}]->(b)
MERGE (b)-[:RUTA {distancia: 211}]->(a);
// Ibagué <-> Girardot: 50 km
MATCH (a:Ciudad {id: 10}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 50}]->(b)
MERGE (b)-[:RUTA {distancia: 50}]->(a);
// Villavicencio <-> Pasto: 826 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 12})
MERGE (a)-[:RUTA {distancia: 826}]->(b)
MERGE (b)-[:RUTA {distancia: 826}]->(a);
// Villavicencio <-> Neiva: 380 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 380}]->(b)
MERGE (b)-[:RUTA {distancia: 380}]->(a);
// Villavicencio <-> Armenia: 374 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 374}]->(b)
MERGE (b)-[:RUTA {distancia: 374}]->(a);
// Villavicencio <-> Montería: 714 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 714}]->(b)
MERGE (b)-[:RUTA {distancia: 714}]->(a);
// Villavicencio <-> Tunja: 223 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 223}]->(b)
MERGE (b)-[:RUTA {distancia: 223}]->(a);
// Villavicencio <-> Popayán: 636 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 636}]->(b)
MERGE (b)-[:RUTA {distancia: 636}]->(a);
// Villavicencio <-> Sincelejo: 769 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 769}]->(b)
MERGE (b)-[:RUTA {distancia: 769}]->(a);
// Villavicencio <-> Valledupar: 865 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 865}]->(b)
MERGE (b)-[:RUTA {distancia: 865}]->(a);
// Villavicencio <-> Riohacha: 827 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 827}]->(b)
MERGE (b)-[:RUTA {distancia: 827}]->(a);
// Villavicencio <-> Arauca: 456 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 456}]->(b)
MERGE (b)-[:RUTA {distancia: 456}]->(a);
// Villavicencio <-> Yopal: 190 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 190}]->(b)
MERGE (b)-[:RUTA {distancia: 190}]->(a);
// Villavicencio <-> Florencia: 357 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 357}]->(b)
MERGE (b)-[:RUTA {distancia: 357}]->(a);
// Villavicencio <-> Quibdó: 378 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 378}]->(b)
MERGE (b)-[:RUTA {distancia: 378}]->(a);
// Villavicencio <-> Girardot: 132 km
MATCH (a:Ciudad {id: 11}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 132}]->(b)
MERGE (b)-[:RUTA {distancia: 132}]->(a);
// Pasto <-> Neiva: 685 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 13})
MERGE (a)-[:RUTA {distancia: 685}]->(b)
MERGE (b)-[:RUTA {distancia: 685}]->(a);
// Pasto <-> Armenia: 651 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 651}]->(b)
MERGE (b)-[:RUTA {distancia: 651}]->(a);
// Pasto <-> Montería: 1255 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 1255}]->(b)
MERGE (b)-[:RUTA {distancia: 1255}]->(a);
// Pasto <-> Tunja: 933 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 933}]->(b)
MERGE (b)-[:RUTA {distancia: 933}]->(a);
// Pasto <-> Popayán: 374 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 374}]->(b)
MERGE (b)-[:RUTA {distancia: 374}]->(a);
// Pasto <-> Sincelejo: 1394 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 1394}]->(b)
MERGE (b)-[:RUTA {distancia: 1394}]->(a);
// Pasto <-> Valledupar: 1604 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 1604}]->(b)
MERGE (b)-[:RUTA {distancia: 1604}]->(a);
// Pasto <-> Riohacha: 1246 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 1246}]->(b)
MERGE (b)-[:RUTA {distancia: 1246}]->(a);
// Pasto <-> Arauca: 974 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 974}]->(b)
MERGE (b)-[:RUTA {distancia: 974}]->(a);
// Pasto <-> Yopal: 710 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 710}]->(b)
MERGE (b)-[:RUTA {distancia: 710}]->(a);
// Pasto <-> Florencia: 191 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 191}]->(b)
MERGE (b)-[:RUTA {distancia: 191}]->(a);
// Pasto <-> Quibdó: 503 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 503}]->(b)
MERGE (b)-[:RUTA {distancia: 503}]->(a);
// Pasto <-> Girardot: 440 km
MATCH (a:Ciudad {id: 12}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 440}]->(b)
MERGE (b)-[:RUTA {distancia: 440}]->(a);
// Neiva <-> Armenia: 427 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 14})
MERGE (a)-[:RUTA {distancia: 427}]->(b)
MERGE (b)-[:RUTA {distancia: 427}]->(a);
// Neiva <-> Montería: 874 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 874}]->(b)
MERGE (b)-[:RUTA {distancia: 874}]->(a);
// Neiva <-> Tunja: 458 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 458}]->(b)
MERGE (b)-[:RUTA {distancia: 458}]->(a);
// Neiva <-> Popayán: 520 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 520}]->(b)
MERGE (b)-[:RUTA {distancia: 520}]->(a);
// Neiva <-> Sincelejo: 1000 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 1000}]->(b)
MERGE (b)-[:RUTA {distancia: 1000}]->(a);
// Neiva <-> Valledupar: 1101 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 1101}]->(b)
MERGE (b)-[:RUTA {distancia: 1101}]->(a);
// Neiva <-> Riohacha: 993 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 993}]->(b)
MERGE (b)-[:RUTA {distancia: 993}]->(a);
// Neiva <-> Arauca: 682 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 682}]->(b)
MERGE (b)-[:RUTA {distancia: 682}]->(a);
// Neiva <-> Yopal: 417 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 417}]->(b)
MERGE (b)-[:RUTA {distancia: 417}]->(a);
// Neiva <-> Florencia: 150 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 150}]->(b)
MERGE (b)-[:RUTA {distancia: 150}]->(a);
// Neiva <-> Quibdó: 343 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 343}]->(b)
MERGE (b)-[:RUTA {distancia: 343}]->(a);
// Neiva <-> Girardot: 162 km
MATCH (a:Ciudad {id: 13}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 162}]->(b)
MERGE (b)-[:RUTA {distancia: 162}]->(a);
// Armenia <-> Montería: 528 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 15})
MERGE (a)-[:RUTA {distancia: 528}]->(b)
MERGE (b)-[:RUTA {distancia: 528}]->(a);
// Armenia <-> Tunja: 431 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 431}]->(b)
MERGE (b)-[:RUTA {distancia: 431}]->(a);
// Armenia <-> Popayán: 386 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 386}]->(b)
MERGE (b)-[:RUTA {distancia: 386}]->(a);
// Armenia <-> Sincelejo: 592 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 592}]->(b)
MERGE (b)-[:RUTA {distancia: 592}]->(a);
// Armenia <-> Valledupar: 770 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 770}]->(b)
MERGE (b)-[:RUTA {distancia: 770}]->(a);
// Armenia <-> Riohacha: 837 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 837}]->(b)
MERGE (b)-[:RUTA {distancia: 837}]->(a);
// Armenia <-> Arauca: 614 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 614}]->(b)
MERGE (b)-[:RUTA {distancia: 614}]->(a);
// Armenia <-> Yopal: 375 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 375}]->(b)
MERGE (b)-[:RUTA {distancia: 375}]->(a);
// Armenia <-> Florencia: 325 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 325}]->(b)
MERGE (b)-[:RUTA {distancia: 325}]->(a);
// Armenia <-> Quibdó: 168 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 168}]->(b)
MERGE (b)-[:RUTA {distancia: 168}]->(a);
// Armenia <-> Girardot: 101 km
MATCH (a:Ciudad {id: 14}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 101}]->(b)
MERGE (b)-[:RUTA {distancia: 101}]->(a);
// Montería <-> Tunja: 645 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 16})
MERGE (a)-[:RUTA {distancia: 645}]->(b)
MERGE (b)-[:RUTA {distancia: 645}]->(a);
// Montería <-> Popayán: 876 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 876}]->(b)
MERGE (b)-[:RUTA {distancia: 876}]->(a);
// Montería <-> Sincelejo: 130 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 130}]->(b)
MERGE (b)-[:RUTA {distancia: 130}]->(a);
// Montería <-> Valledupar: 416 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 416}]->(b)
MERGE (b)-[:RUTA {distancia: 416}]->(a);
// Montería <-> Riohacha: 450 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 450}]->(b)
MERGE (b)-[:RUTA {distancia: 450}]->(a);
// Montería <-> Arauca: 594 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 594}]->(b)
MERGE (b)-[:RUTA {distancia: 594}]->(a);
// Montería <-> Yopal: 541 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 541}]->(b)
MERGE (b)-[:RUTA {distancia: 541}]->(a);
// Montería <-> Florencia: 795 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 795}]->(b)
MERGE (b)-[:RUTA {distancia: 795}]->(a);
// Montería <-> Quibdó: 351 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 351}]->(b)
MERGE (b)-[:RUTA {distancia: 351}]->(a);
// Montería <-> Girardot: 509 km
MATCH (a:Ciudad {id: 15}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 509}]->(b)
MERGE (b)-[:RUTA {distancia: 509}]->(a);
// Tunja <-> Popayán: 743 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 17})
MERGE (a)-[:RUTA {distancia: 743}]->(b)
MERGE (b)-[:RUTA {distancia: 743}]->(a);
// Tunja <-> Sincelejo: 595 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 595}]->(b)
MERGE (b)-[:RUTA {distancia: 595}]->(a);
// Tunja <-> Valledupar: 671 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 671}]->(b)
MERGE (b)-[:RUTA {distancia: 671}]->(a);
// Tunja <-> Riohacha: 670 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 670}]->(b)
MERGE (b)-[:RUTA {distancia: 670}]->(a);
// Tunja <-> Arauca: 336 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 336}]->(b)
MERGE (b)-[:RUTA {distancia: 336}]->(a);
// Tunja <-> Yopal: 110 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 110}]->(b)
MERGE (b)-[:RUTA {distancia: 110}]->(a);
// Tunja <-> Florencia: 502 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 502}]->(b)
MERGE (b)-[:RUTA {distancia: 502}]->(a);
// Tunja <-> Quibdó: 365 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 365}]->(b)
MERGE (b)-[:RUTA {distancia: 365}]->(a);
// Tunja <-> Girardot: 210 km
MATCH (a:Ciudad {id: 16}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 210}]->(b)
MERGE (b)-[:RUTA {distancia: 210}]->(a);
// Popayán <-> Sincelejo: 1015 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 18})
MERGE (a)-[:RUTA {distancia: 1015}]->(b)
MERGE (b)-[:RUTA {distancia: 1015}]->(a);
// Popayán <-> Valledupar: 1225 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 1225}]->(b)
MERGE (b)-[:RUTA {distancia: 1225}]->(a);
// Popayán <-> Riohacha: 1091 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 1091}]->(b)
MERGE (b)-[:RUTA {distancia: 1091}]->(a);
// Popayán <-> Arauca: 828 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 828}]->(b)
MERGE (b)-[:RUTA {distancia: 828}]->(a);
// Popayán <-> Yopal: 567 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 567}]->(b)
MERGE (b)-[:RUTA {distancia: 567}]->(a);
// Popayán <-> Florencia: 144 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 144}]->(b)
MERGE (b)-[:RUTA {distancia: 144}]->(a);
// Popayán <-> Quibdó: 362 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 362}]->(b)
MERGE (b)-[:RUTA {distancia: 362}]->(a);
// Popayán <-> Girardot: 288 km
MATCH (a:Ciudad {id: 17}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 288}]->(b)
MERGE (b)-[:RUTA {distancia: 288}]->(a);
// Sincelejo <-> Valledupar: 469 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 19})
MERGE (a)-[:RUTA {distancia: 469}]->(b)
MERGE (b)-[:RUTA {distancia: 469}]->(a);
// Sincelejo <-> Riohacha: 369 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 369}]->(b)
MERGE (b)-[:RUTA {distancia: 369}]->(a);
// Sincelejo <-> Arauca: 567 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 567}]->(b)
MERGE (b)-[:RUTA {distancia: 567}]->(a);
// Sincelejo <-> Yopal: 551 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 551}]->(b)
MERGE (b)-[:RUTA {distancia: 551}]->(a);
// Sincelejo <-> Florencia: 855 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 855}]->(b)
MERGE (b)-[:RUTA {distancia: 855}]->(a);
// Sincelejo <-> Quibdó: 425 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 425}]->(b)
MERGE (b)-[:RUTA {distancia: 425}]->(a);
// Sincelejo <-> Girardot: 560 km
MATCH (a:Ciudad {id: 18}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 560}]->(b)
MERGE (b)-[:RUTA {distancia: 560}]->(a);
// Valledupar <-> Riohacha: 124 km
MATCH (a:Ciudad {id: 19}), (b:Ciudad {id: 20})
MERGE (a)-[:RUTA {distancia: 124}]->(b)
MERGE (b)-[:RUTA {distancia: 124}]->(a);
// Valledupar <-> Arauca: 466 km
MATCH (a:Ciudad {id: 19}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 466}]->(b)
MERGE (b)-[:RUTA {distancia: 466}]->(a);
// Valledupar <-> Yopal: 579 km
MATCH (a:Ciudad {id: 19}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 579}]->(b)
MERGE (b)-[:RUTA {distancia: 579}]->(a);
// Valledupar <-> Florencia: 1019 km
MATCH (a:Ciudad {id: 19}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 1019}]->(b)
MERGE (b)-[:RUTA {distancia: 1019}]->(a);
// Valledupar <-> Quibdó: 651 km
MATCH (a:Ciudad {id: 19}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 651}]->(b)
MERGE (b)-[:RUTA {distancia: 651}]->(a);
// Valledupar <-> Girardot: 707 km
MATCH (a:Ciudad {id: 19}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 707}]->(b)
MERGE (b)-[:RUTA {distancia: 707}]->(a);
// Riohacha <-> Arauca: 549 km
MATCH (a:Ciudad {id: 20}), (b:Ciudad {id: 21})
MERGE (a)-[:RUTA {distancia: 549}]->(b)
MERGE (b)-[:RUTA {distancia: 549}]->(a);
// Riohacha <-> Yopal: 692 km
MATCH (a:Ciudad {id: 20}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 692}]->(b)
MERGE (b)-[:RUTA {distancia: 692}]->(a);
// Riohacha <-> Florencia: 1144 km
MATCH (a:Ciudad {id: 20}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 1144}]->(b)
MERGE (b)-[:RUTA {distancia: 1144}]->(a);
// Riohacha <-> Quibdó: 770 km
MATCH (a:Ciudad {id: 20}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 770}]->(b)
MERGE (b)-[:RUTA {distancia: 770}]->(a);
// Riohacha <-> Girardot: 832 km
MATCH (a:Ciudad {id: 20}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 832}]->(b)
MERGE (b)-[:RUTA {distancia: 832}]->(a);
// Arauca <-> Yopal: 265 km
MATCH (a:Ciudad {id: 21}), (b:Ciudad {id: 22})
MERGE (a)-[:RUTA {distancia: 265}]->(b)
MERGE (b)-[:RUTA {distancia: 265}]->(a);
// Arauca <-> Florencia: 812 km
MATCH (a:Ciudad {id: 21}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 812}]->(b)
MERGE (b)-[:RUTA {distancia: 812}]->(a);
// Arauca <-> Quibdó: 670 km
MATCH (a:Ciudad {id: 21}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 670}]->(b)
MERGE (b)-[:RUTA {distancia: 670}]->(a);
// Arauca <-> Girardot: 544 km
MATCH (a:Ciudad {id: 21}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 544}]->(b)
MERGE (b)-[:RUTA {distancia: 544}]->(a);
// Yopal <-> Florencia: 546 km
MATCH (a:Ciudad {id: 22}), (b:Ciudad {id: 23})
MERGE (a)-[:RUTA {distancia: 546}]->(b)
MERGE (b)-[:RUTA {distancia: 546}]->(a);
// Yopal <-> Quibdó: 473 km
MATCH (a:Ciudad {id: 22}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 473}]->(b)
MERGE (b)-[:RUTA {distancia: 473}]->(a);
// Yopal <-> Girardot: 290 km
MATCH (a:Ciudad {id: 22}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 290}]->(b)
MERGE (b)-[:RUTA {distancia: 290}]->(a);
// Florencia <-> Quibdó: 468 km
MATCH (a:Ciudad {id: 23}), (b:Ciudad {id: 24})
MERGE (a)-[:RUTA {distancia: 468}]->(b)
MERGE (b)-[:RUTA {distancia: 468}]->(a);
// Florencia <-> Girardot: 312 km
MATCH (a:Ciudad {id: 23}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 312}]->(b)
MERGE (b)-[:RUTA {distancia: 312}]->(a);
// Quibdó <-> Girardot: 257 km
MATCH (a:Ciudad {id: 24}), (b:Ciudad {id: 25})
MERGE (a)-[:RUTA {distancia: 257}]->(b)
MERGE (b)-[:RUTA {distancia: 257}]->(a);

// Verificar: contar nodos y relaciones
MATCH (c:Ciudad) RETURN count(c) AS ciudades;
MATCH ()-[r:RUTA]->() RETURN count(r) AS rutas;
