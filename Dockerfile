# syntax=docker/dockerfile:1
FROM python:3.15-slim

LABEL org.opencontainers.image.title="borne-simulator" \
      org.opencontainers.image.description="Simulateur de bornes de port de plaisance + portail client (MQTT, SQLite)"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DATA_DIR=/data \
    WEB_PORT=8080

WORKDIR /app

# Dépendances d'abord : cette couche reste en cache tant que requirements.txt ne change pas.
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY main.py ./
COPY domaine ./domaine
COPY business ./business
COPY infrastructure ./infrastructure
COPY presentation ./presentation
COPY config ./config

RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app \
    && mkdir /data && chown 10001:10001 /data
USER 10001:10001
VOLUME ["/data"]
EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=4s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request as u; u.urlopen('http://127.0.0.1:8080/api/ready', timeout=3)"

CMD ["python", "main.py"]
