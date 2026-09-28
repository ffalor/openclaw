---
name: radarr
description: Manage your Radarr movie library — search and add films, monitor queue, inspect stats and missing movies.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "RADARR_KEY"]}}}
---

# Radarr

Manage your Radarr movie library: search and add films, track the download queue, and inspect library health. Scripts are verbatim copies from the upstream `clawarr-suite` bundle.

## Prerequisites

| Requirement | Value |
|-------------|-------|
| Binaries | `bash`, `curl`, `jq` |
| `CLAWARR_HOST` | Host or IP running Radarr (e.g. `192.168.1.100`) |
| `RADARR_KEY` | Radarr API key (Settings → General → Security → API Key) |

Optional text/math helpers (`sed`, `bc`) are used by `library.sh` where available. A missing sibling key (`SONARR_KEY`, `LIDARR_KEY`) only disables that app's section in shared scripts — Radarr functionality is unaffected.

```bash
export CLAWARR_HOST=192.168.1.100
export RADARR_KEY=def456...
```

Radarr API: `http://$CLAWARR_HOST:7878/api/v3`, auth header `X-Api-Key: $RADARR_KEY`. Full endpoint list: `references/api-endpoints.md`.

## Scripts

All scripts are verbatim upstream copies — do not diverge; fix upstream instead.

### `scripts/search.sh` — Find movies

```bash
scripts/search.sh "<query>" movie
scripts/search.sh "dune" movie
```

Looks up `GET /movie/lookup?term=` and prints title, year, TMDB ID, IMDb rating.

### `scripts/manage.sh` — Add and manage movies

```bash
scripts/manage.sh add-movie "<title>" [quality_profile_id] [root_folder_path]
scripts/manage.sh wanted radarr        # missing/unfulfilled movies
scripts/manage.sh calendar radarr [days]  # upcoming releases (default: 7)
scripts/manage.sh history radarr [count]  # recent grab/import history
scripts/manage.sh rename radarr <id>      # trigger rename scan
scripts/manage.sh refresh radarr [id]     # refresh metadata (all or one ID)
```

`add-movie` searches first, then prompts for quality profile and root folder when omitted.

### `scripts/manage.sh remove` — Explicit-only destructive action

```bash
scripts/manage.sh remove radarr <id>
```

**Destructive-action note:** `remove` is never triggered automatically. It prompts `Remove <title>? (yes/no)` and requires typing `yes`. It calls `DELETE /movie/{id}?deleteFiles=false`, so the library entry is removed but media files on disk are kept. Run it only on explicit user request.

### `scripts/library.sh` — Library exploration (app = `radarr`)

```bash
scripts/library.sh stats radarr
scripts/library.sh quality radarr      # quality-profile breakdown
scripts/library.sh missing radarr      # monitored movies with no file
scripts/library.sh unmonitored radarr
scripts/library.sh recent radarr [days]  # recently added (default: 7)
scripts/library.sh genres radarr
scripts/library.sh years radarr
scripts/library.sh studios radarr      # studio breakdown
scripts/library.sh nofiles radarr      # monitored but no files
scripts/library.sh disk radarr         # disk usage by root folder
```

### `scripts/queue.sh` — Download queue

```bash
scripts/queue.sh
```

Prints the Radarr (and Sonarr, when configured) queue with status, remaining size, and ETA. With only `RADARR_KEY` set, just the Radarr section renders.

## Troubleshooting

See `references/common-issues.md` (Import Issues + Path Mapping verbatim upstream, plus a condensed permission checklist) for "No files eligible for import" fixes, remote path mappings, and permission checks.

## Example Prompts

- "Search Radarr for Dune Part Two and add it"
- "What's missing from my movie library?"
- "Show my Radarr download queue"
- "Which movies are monitored but have no files?"
- "Show Radarr library stats and disk usage"
