# Ollaya Web UI (OWI)

Web UI + HTTP API in front of the local **Ollaya** server
(`POST /api/decide`, `GET /api/tags`, `GET /api/ps`, `/v1/*`, …)
and its **MCP server** (`ollaya mcp --http`).

- UI: `http://<IPG-IP>:11524` — decide playground, model manager,
  MCP start/stop + test calls, performance, request log, API docs.
- API (same port): everything the UI does is a `GET/POST /api/*`
  call, so scripts and agents can drive it too.

## Run (IPG, bare metal for now)

```bash
cd ~/Programs/ollaya/webui
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
nohup .venv/bin/python src/main.py > data/webui.log 2>&1 &
# or: bash run.sh
# UI: http://<IPG-IP>:11524
```

`run.sh` does the same (creates venv on first run, restarts the server).
`ollaya-webui.service` is a systemd **user** unit for the same command.

## Later: docker

`Dockerfile` + `compose.yaml` are prepared for the move
(webui + ollaya in one image / stack). Not used yet — the UI currently
runs on the host and talks to Ollaya at `127.0.0.1:11435`.

## Layout

```
webui/
  requirements.txt
  run.sh                    # venv + start on :11524
  ollaya-webui.service      # systemd user unit (optional)
  Dockerfile / compose.yaml # prepared for the later docker move
  config/ollaya-webui.yaml  # fallback config (UI settings win)
  data/                     # sqlite db (owi.db), mcp.log, webui.log
  src/main.py               # FastAPI backend
  src/static/               # single-page UI
```

## API quick reference

```bash
B=http://<IPG-IP>:11524
curl -s $B/api/health | python3 -m json.tool
curl -s $B/api/models | python3 -m json.tool
curl -s -X POST $B/api/decide -H 'Content-Type: application/json' -d '{
  "model": "laya", "preset": "triage",
  "state": {"message": "You charged me twice, refund NOW!"}
}' | python3 -m json.tool
curl -s -X POST $B/api/mcp/start | python3 -m json.tool
curl -s $B/api/metrics | python3 -m json.tool
```

Full endpoint list with curl examples is in the UI (§ API) and at
`GET /api` (machine-readable route map).
