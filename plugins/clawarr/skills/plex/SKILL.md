---
name: plex
description: Plex library stats and recently-added reporting via analytics.sh with PLEX_TOKEN auth.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Plex

Direct Plex Media Server library reporting. Uses `scripts/analytics.sh` (adapted from the upstream `clawarr-suite` bundle (per-service URLs, OpenClaw secret-store support), shared with the tautulli skill — same file, this skill documents the Plex-backed commands).

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `PLEX_URL` | Plex base URL, e.g. `https://plex.example.ts.net` or `http://192.168.1.100:32400` |
| `PLEX_TOKEN` | Plex auth token (`X-Plex-Token`) |
| `CLAWARR_HOST` / `PLEX_HOST` | Optional fallback when `PLEX_URL` is unset: `${PLEX_SCHEME:-http}://${PLEX_HOST:-$CLAWARR_HOST}:${PLEX_PORT:-32400}` |

Configure both with the `clawarr-core` skill: `scripts/setup.sh plex <url>`. Over HTTPS the token is a protected OpenClaw store secret and `$PLEX_TOKEN` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Get a token from the Plex Web UI: open any media item → "Get Info" → "View XML" → the URL contains `X-Plex-Token=...`.

**Calling the API yourself:** always use `$PLEX_URL` with `$PLEX_TOKEN`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

## Commands (`scripts/analytics.sh`)

Plex-backed commands documented here:

```bash
analytics.sh library-stats     # Plex library section statistics (needs PLEX_TOKEN)
analytics.sh recent-added [n]  # Recently added to Plex (default: 10)
```

Other commands in the script (`activity`, `history`, `most-watched`, `popular-genres`, `peak-hours`, `user-stats`, `play-totals`) are Tautulli-backed and documented in the tautulli skill. Optional tools `bc`/`sed` are used by some script paths.

Full endpoint list: `references/api-endpoints.md` (Authentication + Plex sections, prepended).

## Example prompts

- "Show my Plex library stats"
- "What was recently added to Plex?"
- "List my Plex library sections with item counts"
- "Show the 20 most recently added Plex items"

## Connectivity checklist

1. `PLEX_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Plex instance; run `scripts/setup.sh plex <url>` from the clawarr-core skill to (re)configure it.
2. `PLEX_TOKEN` is set and valid (check `/identity` with `X-Plex-Token`)
3. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
4. Port 32400 reachable (or `PLEX_PORT` override matches)
5. `jq` installed for JSON parsing
6. `GET /library/sections` returns your libraries
