# Prepared for the later docker move. NOT used yet — the UI runs bare-metal on IPG.
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ /app/
EXPOSE 11524
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:11524/api/health', timeout=4)" || exit 1
CMD ["uvicorn","main:app","--host","0.0.0.0","--port","11524"]
