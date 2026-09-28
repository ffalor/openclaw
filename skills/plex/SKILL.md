---
name: plex
description: Plex library stats and recently-added reporting via analytics.sh with PLEX_TOKEN auth.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "PLEX_TOKEN"]}}}
---

# Plex

Direct Plex Media Server library reporting. Uses `scripts/analytics.sh` (verbatim upstream copy, shared with the tautulli skill — same file, this skill documents the Plex-backed commands).

## Requires

| Variable | Purpose | Default |
|---|---|---|
| `CLAWARR_HOST` | Plex server host (also `PLEX_HOST` override) | — |
| `PLEX_TOKEN` | Plex auth token (`X-Plex-Token`) | — |
| `PLEX_SCHEME` | URL scheme (`http` or `https`) | `http` |
| `PLEX_PORT` | Plex port | `32400` |
| `DOCKER_CONFIG_BASE` | Docker config root (optional, unused here) | `/volume1/docker` |

Get a token from the Plex Web UI: open any media item → "Get Info" → "View XML" → the URL contains `X-Plex-Token=...`. Or authenticate via `POST https://plex.tv/users/sign_in.json` with basic auth and an `X-Plex-Client-Identifier` header.

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

1. `CLAWARR_HOST` points at the Plex server host
2. `PLEX_TOKEN` is set and valid (check `/identity` with `X-Plex-Token`)
3. Port 32400 reachable (or `PLEX_PORT` override matches)
4. `jq` installed for JSON parsing
5. `GET /library/sections` returns your libraries
