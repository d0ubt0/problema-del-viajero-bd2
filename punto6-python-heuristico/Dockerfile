FROM python:3.11-slim

WORKDIR /app

COPY punto6-python-heuristico/tsp_heuristico.py .
COPY shared/ciudades.json /app/shared/ciudades.json

CMD ["python", "tsp_heuristico.py"]
