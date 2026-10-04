---
name: readarr
description: Manage your Readarr ebook library — search authors and books, add titles, monitor queue via API.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Readarr

Manage your Readarr ebook/audiobook library with `scripts/library.sh` (stats, quality, missing, recent, disk) plus direct API calls for author/book management. Reference docs are verbatim extracts from the upstream `clawarr-suite` bundle.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `READARR_URL` | Readarr base URL, e.g. `https://readarr.example.ts.net` or `http://192.168.1.100:8787` |
| `READARR_API_KEY` | API key (Settings → General → Security → API Key) |
| `CLAWARR_HOST` | Optional fallback when `READARR_URL` is unset: `http://$CLAWARR_HOST:8787` (`CLAWARR_SCHEME`, `READARR_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh readarr <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$READARR_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

A missing sibling (`SONARR_*`, `RADARR_*`, `LIDARR_*`) only disables that app — Readarr functionality is unaffected.

Readarr API: `$READARR_URL/api/v1`, auth header `X-Api-Key: $READARR_API_KEY`. Full endpoint list: `references/api-endpoints.md`.

**Calling the API yourself:** always use `$READARR_URL` with `$READARR_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

## Library analytics (`scripts/library.sh`)

```bash
scripts/library.sh stats readarr       # author/book counts
```

Only `stats` has a Readarr branch in the upstream script; every other `library.sh` subcommand is Radarr/Sonarr(/Lidarr)-only and prints an empty report for `readarr`. For missing, recent, unmonitored, quality, or disk data use the API workflows below (`GET /wanted/missing`, `GET /book`, `GET /author`, `GET /rootfolder`; see `references/api-endpoints.md`).

## API Workflows

### Search authors

```bash
curl -s -H "X-Api-Key: $READARR_API_KEY" \
  "$READARR_URL/api/v1/author/lookup?term=brandon%20sanderson" | jq '.[] | {authorName, id, genres}'
```

### Add an author

Look up first, then fetch quality profiles and root folders, then POST:

```bash
curl -s -H "X-Api-Key: $READARR_API_KEY" \
  "$READARR_URL/api/v1/qualityprofile" | jq '.[] | {id, name}'
curl -s -H "X-Api-Key: $READARR_API_KEY" \
  "$READARR_URL/api/v1/rootfolder" | jq '.[] | {id, path}'

curl -s -X POST -H "X-Api-Key: $READARR_API_KEY" -H "Content-Type: application/json" \
  "$READARR_URL/api/v1/author" \
  -d '{"authorName": "<name>", "qualityProfileId": 1, "rootFolderPath": "/books", "monitored": true,
       "addOptions": {"searchForMissingBooks": true}}'
```

### Search books

```bash
curl -s -H "X-Api-Key: $READARR_API_KEY" \
  "$READARR_URL/api/v1/book/lookup?term=mistborn" | jq '.[] | {title, authorTitle, ratings}'
```

### List library and queue

```bash
curl -s -H "X-Api-Key: $READARR_API_KEY" \
  "$READARR_URL/api/v1/author" | jq '.[] | {authorName, monitored, ratings}'
curl -s -H "X-Api-Key: $READARR_API_KEY" \
  "$READARR_URL/api/v1/queue" | jq '.'
```

Removal (`DELETE /author/{id}`) is destructive: run only on explicit user request, and confirm what will be removed first.

## Troubleshooting

See `references/common-issues.md` (Import Issues + Path Mapping verbatim upstream, plus a condensed permission checklist) for "No files eligible for import" fixes, remote path mappings, and permission checks.

## Example Prompts

- "Search Readarr for Brandon Sanderson"
- "Add this author to Readarr with default quality"
- "What's in my Readarr download queue?"
- "List my Readarr authors"
