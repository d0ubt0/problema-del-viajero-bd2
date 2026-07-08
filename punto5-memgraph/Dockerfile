FROM memgraph/memgraph:latest

COPY setup.cypher /docker-entrypoint-initdb.d/setup.cypher
COPY tsp_mage.py /usr/lib/memgraph/query_modules/tsp_mage.py

EXPOSE 7687
