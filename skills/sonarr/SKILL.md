---
name: sonarr
description: Manage your Sonarr TV library — search and add series, monitor queue, inspect stats and missing episodes.
metadata:
  {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "SONARR_KEY"]}}}
---

# Sonarr

Manage your Sonarr TV-series library: search and add shows, track the download queue, and inspect library health. Scripts are verbatim copies from the upstream `clawarr-suite` bundle.

## Prerequisites

| Requirement | Value |
|-------------|-------|
| Binaries | `bash`, `curl`, `jq` |
| `CLAWARR_HOST` | Host or IP running Sonarr (e.g. `192.168.1.100`) |
| `SONARR_KEY` | Sonarr API key (Settings → General → Security → API Key) |

Optional text/math helpers (`sed`, `bc`) are used by `library.sh` where available. A missing sibling key (`RADARR_KEY`, `LIDARR_KEY`) only disables that app's section in shared scripts — Sonarr functionality is unaffected.

```bash
export CLAWARR_HOST=192.168.1.100
export SONARR_KEY=abc123...
```

Sonarr API: `http://$CLAWARR_HOST:8989/api/v3`, auth header `X-Api-Key: $SONARR_KEY`. Full endpoint list: `references/api-endpoints.md`.

## Scripts

All scripts are verbatim upstream copies — do not diverge; fix upstream instead.

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

Prints the Sonarr (and Radarr, when configured) queue with status, remaining size, and ETA. With only `SONARR_KEY` set, just the Sonarr section renders.

## Troubleshooting

See `references/common-issues.md` (Import Issues + Path Mapping verbatim upstream, plus a condensed permission checklist) for "No files eligible for import" fixes, remote path mappings, and permission checks.

## Example Prompts

- "Search Sonarr for Foundation and add it"
- "What's missing from my Sonarr library?"
- "Show my Sonarr download queue"
- "What episodes are airing in the next 7 days?"
- "Show Sonarr library stats and disk usage"
