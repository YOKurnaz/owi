# OWI — Ollaya Web Interface

Web UI + HTTP API in front of the local **[Ollaya](https://ollaya.dev)** server
(`POST /api/decide`, `GET /api/tags`, `GET /api/ps`, `/v1/*`, …)
and its **MCP server** (`ollaya mcp --http`).

![OWI — Decide tab with live metrics, model policy and answers](docs/screenshot.png)

## Features

- **Decide playground** — pick a model, a built-in preset
  (`triage`, `email`, `guard`, `moderation`, `router`, `agent`) or your own
  questions; answers with probabilities, load/eval timings, routing info.
- **Model manager** — list local + loaded models, pull / delete / copy /
  create (Modelfile-style), load / unload, default-model keep-alive policy
  (default stays loaded, others unload; max-N-loaded enforcement, GPU-OOM
  CPU fallback).
- **MCP control** — start/stop `ollaya mcp --http`, probe health, call tools
  (`decide`, `list_models`, `show_model`, `pull_model`), read resources
  (`ollaya://models`, `ollaya://presets/*`), client config snippets.
- **Users & security** — session login for the UI, bearer API keys for
  scripts, `admin` / `user` roles. Admins manage users; users manage their
  own profile + keys. History and metrics are scoped per user.
- **Performance & log** — totals, p50/p95, per-model/per-preset/per-day,
  Ollaya + MCP health history, click-to-reload sqlite request log.
- **Full API** — everything the UI does is a `GET/POST /api/*` call
  (route map at `GET /api`, curl examples in the UI's API tab).

## Requirements

- [Ollaya](https://ollaya.dev/docs/quickstart) installed and serving
  (default `http://127.0.0.1:11435` — `ollaya serve`, or it starts on demand).
- Python 3.10+.

## Install & run (bare metal)

```bash
git clone https://github.com/YOKurnaz/owi.git
cd owi
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
bash run.sh
# UI: http://<HOST-IP>:11524
```

`run.sh` creates the venv on first run, restarts any running instance,
and prints a health check. Or start manually:

```bash
mkdir -p data config
nohup .venv/bin/python src/main.py > data/webui.log 2>&1 &
```

First login is `admin / admin` — change it immediately in the **User** tab.

### Run as a service (systemd user unit, no root)

```bash
mkdir -p ~/.config/systemd/user
cp systemd/ollaya-webui.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now ollaya-webui
journalctl --user -u ollaya-webui -f
# UI: http://<HOST-IP>:11524
```

See [`systemd/README.md`](systemd/README.md) for details
(`KillMode=process` keeps a managed MCP child alive across restarts).

### Docker (prepared, not the default yet)

`Dockerfile` + `compose.yaml` are ready for the later move
(webui + Ollaya in one image/stack):

```bash
docker compose up -d --build
# UI: http://<HOST-IP>:11524
```

## Configuration

Lowest priority first — UI settings (sqlite) win over env, env over the
yaml file, yaml over built-ins:

| Setting | Env | YAML key | Default |
|---|---|---|---|
| Ollaya URL | `OLLAYA_BASE_URL` | `ollaya_base_url` | `http://127.0.0.1:11435` |
| Ollaya API key | `OLLAYA_API_KEY` | — (UI only) | unset |
| MCP address | `OLLAYA_MCP_ADDR` | `mcp_addr` | `127.0.0.1:11436` |
| Default model | `OWI_DEFAULT_MODEL` | `default_model` | `laya:latest` |
| Max loaded | `OWI_MAX_LOADED_MODELS` | `max_loaded_models` | `2` |
| Listen port | `OWI_PORT` | — | `11524` |
| Config path | `OWI_CONFIG` | — | `config/ollaya-webui.yaml` |
| DB path | `OWI_DB` | — | `data/owi.db` |

Edit `config/ollaya-webui.yaml`, or change Ollaya URL / MCP address /
API key directly in the UI header (saved to sqlite, no restart).

## Auth quick reference

```bash
B=http://<HOST-IP>:11524

# UI login (session cookie)
curl -s -c jar -X POST $B/api/auth/login \
  -H 'Content-Type: application/json' -d '{"username":"admin","password":"..."}'
curl -s -b jar $B/api/auth/me | python3 -m json.tool

# API key for scripts (shown ONCE)
curl -s -b jar -X POST $B/api/keys \
  -H 'Content-Type: application/json' -d '{"name":"n8n"}'
KEY=owi_...
curl -s $B/api/decide -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' -d '{
    "model": "laya", "preset": "triage",
    "state": {"message": "You charged me twice, refund NOW!"}
  }' | python3 -m json.tool

# admin: users
curl -s -b jar $B/api/users | python3 -m json.tool
curl -s -b jar -X POST $B/api/users \
  -d '{"username":"ops","password":"...","role":"user"}'
```

## API quick reference

```bash
B=http://<HOST-IP>:11524
curl -s -b jar $B/api/health | python3 -m json.tool
curl -s -b jar $B/api/models | python3 -m json.tool
curl -s -b jar $B/api/policy | python3 -m json.tool
curl -s -b jar -X POST $B/api/mcp/start | python3 -m json.tool
curl -s -b jar $B/api/metrics | python3 -m json.tool
```

Full endpoint list with curl examples is in the UI (§ API) and at
`GET /api` (machine-readable route map, needs login).

## Layout

```
owi/
  requirements.txt
  run.sh                    # venv + start on :11524
  src/main.py               # FastAPI backend
  src/static/               # single-page UI (+ login page)
  systemd/                  # example systemd user unit
  config/ollaya-webui.yaml  # fallback config (UI settings win)
  data/                     # sqlite db (owi.db), mcp.log, webui.log (gitignored)
  docs/                     # this site (GitHub Pages)
  Dockerfile / compose.yaml # prepared for the later docker move
```
