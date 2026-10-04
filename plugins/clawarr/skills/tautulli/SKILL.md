---
name: tautulli
description: Plex viewing analytics (activity, history, top content, user stats) via analytics.sh and Tautulli API.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Tautulli

Plex viewing analytics via the Tautulli API. Uses `scripts/analytics.sh` (adapted from the upstream `clawarr-suite` bundle (per-service URLs, OpenClaw secret-store support), shared with the plex skill — same file, this skill documents the Tautulli-backed commands).

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `TAUTULLI_URL` | Tautulli base URL, e.g. `https://tautulli.example.ts.net` or `http://192.168.1.100:8181` |
| `TAUTULLI_API_KEY` | API key (Settings → Web Interface → API → API Key) |
| `CLAWARR_HOST` | Optional fallback when `TAUTULLI_URL` is unset: `http://$CLAWARR_HOST:8181` (`CLAWARR_SCHEME`, `TAUTULLI_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh tautulli <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$TAUTULLI_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Plex-backed commands also read `PLEX_URL` / `PLEX_TOKEN` (see the plex skill). Optional tools `bc`/`sed` are used by some script paths.

Tautulli API: `$TAUTULLI_URL/api/v2?apikey=$TAUTULLI_API_KEY&cmd=…` (key in the query string; the egress proxy substitutes it there too).

**Calling the API yourself:** always use `$TAUTULLI_URL` with `$TAUTULLI_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

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

1. `TAUTULLI_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Tautulli instance; run `scripts/setup.sh tautulli <url>` from the clawarr-core skill to (re)configure it.
2. `TAUTULLI_API_KEY` is set (verify with `?apikey=<key>&cmd=status`)
3. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
4. Port 8181 reachable (or `TAUTULLI_PORT` override matches)
5. `jq` installed for JSON parsing
6. Tautulli is linked to a running Plex server
