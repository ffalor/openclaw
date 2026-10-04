---
name: sonarr
description: Manage your Sonarr TV library — search and add series, monitor queue, inspect stats and missing episodes.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Sonarr

Manage your Sonarr TV-series library: search and add shows, track the download queue, and inspect library health. Scripts are adapted from the upstream `clawarr-suite` bundle (per-service URLs, OpenClaw secret-store support).

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `SONARR_URL` | Sonarr base URL, e.g. `https://sonarr.example.ts.net` or `http://192.168.1.100:8989` |
| `SONARR_API_KEY` | API key (Settings → General → Security → API Key) |
| `CLAWARR_HOST` | Optional fallback when `SONARR_URL` is unset: `http://$CLAWARR_HOST:8989` (`CLAWARR_SCHEME`, `SONARR_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh sonarr <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$SONARR_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Optional text/math helpers (`sed`, `bc`) are used by `library.sh` where available. A missing sibling (`RADARR_*`, `LIDARR_*`) only disables that app's section in shared scripts — Sonarr functionality is unaffected.

Sonarr API: `$SONARR_URL/api/v3`, auth header `X-Api-Key: $SONARR_API_KEY`. Full endpoint list: `references/api-endpoints.md`.

**Calling the API yourself:** always use `$SONARR_URL` with `$SONARR_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

## Scripts

Scripts are adapted from upstream `clawarr-suite`; keep shared copies across skills identical.

### `scripts/search.sh` — Find series

```bash
scripts/search.sh "<query>" series
scripts/search.sh "foundation" series
```

Looks up `GET /series/lookup?term=` and prints title, year, TVDB ID, season count.

### `scripts/manage.sh` — Add and manage series

```bash
scripts/manage.sh add-series "<title>" [quality_profile_id] [root_folder_path]
scripts/manage.sh wanted sonarr        # missing/unfulfilled episodes
scripts/manage.sh calendar sonarr [days]  # upcoming airings (default: 7)
scripts/manage.sh history sonarr [count]  # recent grab/import history
scripts/manage.sh rename sonarr <id>      # trigger rename scan
scripts/manage.sh refresh sonarr [id]     # refresh metadata (all or one ID)
```

`add-series` searches first, then prompts for quality profile and root folder when omitted.

### `scripts/manage.sh remove` — Explicit-only destructive action

```bash
scripts/manage.sh remove sonarr <id>
```

**Destructive-action note:** `remove` is never triggered automatically. It prompts `Remove <title>? (yes/no)` and requires typing `yes`. It calls `DELETE /series/{id}?deleteFiles=false`, so the library entry is removed but media files on disk are kept. Run it only on explicit user request.

### `scripts/library.sh` — Library exploration (app = `sonarr`)

```bash
scripts/library.sh stats sonarr
scripts/library.sh quality sonarr      # quality-profile breakdown
scripts/library.sh missing sonarr      # monitored episodes with no file
scripts/library.sh unmonitored sonarr
scripts/library.sh recent sonarr [days]  # recently added (default: 7)
scripts/library.sh genres sonarr
scripts/library.sh years sonarr
scripts/library.sh studios sonarr      # network breakdown
scripts/library.sh nofiles sonarr      # monitored but no files
scripts/library.sh disk sonarr         # disk usage by root folder
```

### `scripts/queue.sh` — Download queue

```bash
scripts/queue.sh
```

Prints the Sonarr (and Radarr, when configured) queue with status, remaining size, and ETA. With only `SONARR_API_KEY` set, just the Sonarr section renders.

## Troubleshooting

See `references/common-issues.md` (Import Issues + Path Mapping verbatim upstream, plus a condensed permission checklist) for "No files eligible for import" fixes, remote path mappings, and permission checks.

## Example Prompts

- "Search Sonarr for Foundation and add it"
- "What's missing from my Sonarr library?"
- "Show my Sonarr download queue"
- "What episodes are airing in the next 7 days?"
- "Show Sonarr library stats and disk usage"
