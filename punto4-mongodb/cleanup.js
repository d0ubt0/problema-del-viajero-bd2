db = db.getSiblingDB('tsp_colombia');

db.ciudades.drop();
db.rutas.drop();
db.distancias.drop();

print("Todas las colecciones han sido eliminadas.");
