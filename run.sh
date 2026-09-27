#!/usr/bin/env bash
# Start Ollaya Web UI on :11524 (IPG, bare metal).
set -euo pipefail
WEBUI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$WEBUI_DIR"
if [ ! -x .venv/bin/python ]; then
  echo "==> creating venv"
  python3 -m venv .venv
  .venv/bin/pip install -r requirements.txt
fi
mkdir -p data config
pkill -f "[o]llaya-webui.*main.py" 2>/dev/null || true
sleep 1
echo "==> starting ollaya-webui on :11524"
nohup .venv/bin/python src/main.py > data/webui.log 2>&1 &
sleep 3
curl -s http://127.0.0.1:11524/api/health | head -c 600; echo ""
echo "==> Ready. UI: http://<IPG-IP>:11524"
