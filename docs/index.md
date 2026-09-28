---
layout: home
title: OWI — Ollaya Web Interface
---

Web UI + HTTP API in front of the local **[Ollaya](https://ollaya.dev)** server
(`POST /api/decide`, `GET /api/tags`, `GET /api/ps`, `/v1/*`, …)
and its **MCP server** (`ollaya mcp --http`).

![OWI — Decide tab with live metrics, model policy and answers](screenshot.png)

## What it does

- **Decide playground** — pick a model, a built-in preset
  (`triage`, `email`, `guard`, `moderation`, `router`, `agent`) or your own
  questions; answers with probabilities, load/eval timings, routing info.
- **Model manager** — list local + loaded models, pull / delete / copy /
  create (Modelfile-style), load / unload, default-model keep-alive policy.
- **MCP control** — start/stop `ollaya mcp --http`, probe health, call tools,
  read resources, client config snippets.
- **Users & security** — session login for the UI, bearer API keys for
  scripts, `admin` / `user` roles; per-user history and metrics scoping.
- **Performance & log** — totals, p50/p95, per-model/per-preset/per-day,
  health history, click-to-reload request log.
- **Full API** — everything the UI does is a `GET/POST /api/*` call.

## Contents

- [Install — pick one path](#install--pick-one-path)
  - [A1) Bare metal](#a1-bare-metal)
  - [A2) Docker](#a2-docker)
- [Quick API taste](#quick-api-taste)

## Install — pick one path

Requirements: [Ollaya](https://ollaya.dev/docs/quickstart) serving
(default `http://127.0.0.1:11435`), plus Python 3.10+ (A1)
**or** Docker (A2) — not both on the same host.

### A1) Bare metal

```bash
git clone https://github.com/YOKurnaz/owi.git
cd owi
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
bash run.sh
# UI: http://<HOST-IP>:11524
```

First login is `admin / admin` — change it immediately in the **User** tab.
Or run as a service: see the
[README](https://github.com/YOKurnaz/owi#option-a--bare-metal-venv--systemd).

### A2) Docker

```bash
git clone https://github.com/YOKurnaz/owi.git
cd owi
docker build -t ollaya-webui:latest .
mkdir -p data config
docker compose up -d --build
# UI: http://<HOST-IP>:11524 (first login: admin / admin)
```

Step-by-step (plain `docker run`, volumes, `host.docker.internal`,
MCP notes) in the [README](https://github.com/YOKurnaz/owi#docker-build-the-image-yourself-step-by-step).

## Quick API taste

```bash
B=http://<HOST-IP>:11524
curl -s -c jar -X POST $B/api/auth/login \
  -H 'Content-Type: application/json' -d '{"username":"admin","password":"..."}'
curl -s -b jar -X POST $B/api/keys -d '{"name":"n8n"}'   # key shown ONCE
KEY=owi_...
curl -s $B/api/decide -H "Authorization: Bearer $KEY" \
  -H 'Content-Type: application/json' -d '{
    "model": "laya", "preset": "triage",
    "state": {"message": "You charged me twice, refund NOW!"}
  }' | python3 -m json.tool
```

Full guide in the [README](https://github.com/YOKurnaz/owi#readme) —
[source code](https://github.com/YOKurnaz/owi), feedback via GitHub issues.
