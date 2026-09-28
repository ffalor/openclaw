---
name: tautulli
description: Plex viewing analytics (activity, history, top content, user stats) via analytics.sh and Tautulli API.
metadata:
  {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "TAUTULLI_KEY"]}}}
---

# Tautulli

Plex viewing analytics via the Tautulli API. Uses `scripts/analytics.sh` (verbatim upstream copy, shared with the plex skill — same file, this skill documents the Tautulli-backed commands).

## Requires

| Variable | Purpose | Default |
|---|---|---|
| `CLAWARR_HOST` | Tautulli server host | — |
| `TAUTULLI_KEY` | Tautulli API key (`?apikey=`) | — |
| `TAUTULLI_PORT` | Tautulli HTTP port | `8181` |
| `DOCKER_CONFIG_BASE` | Docker config root (optional, unused here) | `/volume1/docker` |

Find the API key in Tautulli: Settings → Web Interface → API → API Key. Optional tools `bc`/`sed` are used by some script paths.

## Commands (`scripts/analytics.sh`)

Tautulli-backed commands documented here:

```bash
analytics.sh activity              # Currently watching / active streams
analytics.sh history [count]       # Watch history (default: 20)
analytics.sh most-watched [period] # Most watched content (week/month/year, default: month)
analytics.sh popular-genres         # Most common genres in latest 100 history records
analytics.sh peak-hours            # Peak watching hours breakdown
analytics.sh user-stats [user]     # User activity summary (default: all)
analytics.sh play-totals           # Total play count and duration
```

The `library-stats` and `recent-added` commands hit Plex directly and are documented in the plex skill. Full endpoint list: `references/api-endpoints.md` (Authentication + Tautulli sections, prepended).

## Example prompts

- "Who is watching Plex right now?"
- "Show the most-watched shows this month"
- "When are our peak Plex watching hours?"
- "Show watch stats for user Alex"

## Connectivity checklist

1. `CLAWARR_HOST` points at the Tautulli server host
2. `TAUTULLI_KEY` is set (verify with `?apikey=<key>&cmd=status`)
3. Port 8181 reachable (or `TAUTULLI_PORT` override matches)
4. `jq` installed for JSON parsing
5. Tautulli is linked to a running Plex server
