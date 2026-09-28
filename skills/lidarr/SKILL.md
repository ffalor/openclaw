---
name: lidarr
description: Manage your Lidarr music library — search artists, inspect stats and missing albums.
metadata:
  {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "LIDARR_KEY"]}}}
---

# Lidarr

Manage your Lidarr music library: search for artists and inspect library health. Scripts are verbatim copies from the upstream `clawarr-suite` bundle.

## Prerequisites

| Requirement | Value |
|-------------|-------|
| Binaries | `bash`, `curl`, `jq` |
| `CLAWARR_HOST` | Host or IP running Lidarr (e.g. `192.168.1.100`) |
| `LIDARR_KEY` | Lidarr API key (Settings → General → Security → API Key) |

Optional text/math helpers (`sed`, `bc`) are used by `library.sh` where available. A missing sibling key (`SONARR_KEY`, `RADARR_KEY`) only disables that app's section in shared scripts — Lidarr functionality is unaffected.

```bash
export CLAWARR_HOST=192.168.1.100
export LIDARR_KEY=ghi789...
```

Lidarr API: `http://$CLAWARR_HOST:8686/api/v1`, auth header `X-Api-Key: $LIDARR_KEY`. Full endpoint list: `references/api-endpoints.md`.

## Scripts

All scripts are verbatim upstream copies — do not diverge; fix upstream instead.

### `scripts/search.sh` — Find music

```bash
scripts/search.sh "<query>" music
scripts/search.sh "pink floyd" music
```

Looks up `GET /search?term=` on Lidarr and prints artist, album title, album type, and release year.

### `scripts/library.sh` — Library exploration (app = `lidarr`)

```bash
scripts/library.sh stats lidarr
scripts/library.sh quality lidarr      # quality-profile breakdown
scripts/library.sh missing lidarr      # monitored albums with no files
scripts/library.sh unmonitored lidarr
scripts/library.sh recent lidarr [days]  # recently added (default: 7)
scripts/library.sh genres lidarr
scripts/library.sh years lidarr
scripts/library.sh nofiles lidarr      # monitored but no files
scripts/library.sh disk lidarr         # disk usage by root folder
```

Note: there is no `manage.sh` for Lidarr in this skill — add artists directly via `POST /artist` (see `references/api-endpoints.md`), and remove entries only on explicit user request.

## Troubleshooting

See `references/common-issues.md` (Import Issues + Path Mapping verbatim upstream, plus a condensed permission checklist) for "No files eligible for import" fixes, remote path mappings, and permission checks.

## Example Prompts

- "Search Lidarr for Pink Floyd"
- "What's missing from my music library?"
- "Show Lidarr library stats"
- "Which albums are monitored but have no files?"
