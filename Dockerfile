# OWI image: FastAPI backend + static UI on :11524.
# Talks to Ollaya on the host (OLLAYA_BASE_URL) — Ollaya itself is NOT in this image.
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ /app/
EXPOSE 11524
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:11524/login', timeout=4)" || exit 1
CMD ["uvicorn","main:app","--host","0.0.0.0","--port","11524"]
