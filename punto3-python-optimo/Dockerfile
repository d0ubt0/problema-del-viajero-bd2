FROM python:3.11-slim

WORKDIR /app

COPY shared/ciudades.json /app/shared/ciudades.json
COPY punto3-python-optimo/tsp_optimo.py /app/tsp_optimo.py

CMD ["python", "tsp_optimo.py", "/app/shared/ciudades.json"]
