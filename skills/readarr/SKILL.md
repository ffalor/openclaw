---
name: readarr
description: Manage your Readarr ebook library — search authors and books, add titles, monitor queue via API.
metadata:
  {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "READARR_KEY"]}}}
---

# Readarr

Manage your Readarr ebook/audiobook library directly through its REST API. No scripts ship with this skill — upstream provides no Readarr scripts — so all workflows below use `curl` against the API. Reference docs are verbatim extracts from the upstream `clawarr-suite` bundle.

## Prerequisites

| Requirement | Value |
|-------------|-------|
| Binaries | `bash`, `curl`, `jq` |
| `CLAWARR_HOST` | Host or IP running Readarr (e.g. `192.168.1.100`) |
| `READARR_KEY` | Readarr API key (Settings → General → Security → API Key) |

```bash
export CLAWARR_HOST=192.168.1.100
export READARR_KEY=jkl012...
```

A missing sibling key (`SONARR_KEY`, `RADARR_KEY`, `LIDARR_KEY`) only disables that app — Readarr functionality is unaffected.

Readarr API: `http://$CLAWARR_HOST:8787/api/v1`, auth header `X-Api-Key: $READARR_KEY`. Full endpoint list: `references/api-endpoints.md`.

## API Workflows

### Search authors

```bash
curl -s -H "X-Api-Key: $READARR_KEY" \
  "http://$CLAWARR_HOST:8787/api/v1/author/lookup?term=brandon%20sanderson" | jq '.[] | {authorName, id, genres}'
```

### Add an author

Look up first, then fetch quality profiles and root folders, then POST:

```bash
curl -s -H "X-Api-Key: $READARR_KEY" \
  "http://$CLAWARR_HOST:8787/api/v1/qualityprofile" | jq '.[] | {id, name}'
curl -s -H "X-Api-Key: $READARR_KEY" \
  "http://$CLAWARR_HOST:8787/api/v1/rootfolder" | jq '.[] | {id, path}'

curl -s -X POST -H "X-Api-Key: $READARR_KEY" -H "Content-Type: application/json" \
  "http://$CLAWARR_HOST:8787/api/v1/author" \
  -d '{"authorName": "<name>", "qualityProfileId": 1, "rootFolderPath": "/books", "monitored": true,
       "addOptions": {"searchForMissingBooks": true}}'
```

### Search books

```bash
curl -s -H "X-Api-Key: $READARR_KEY" \
  "http://$CLAWARR_HOST:8787/api/v1/book/lookup?term=mistborn" | jq '.[] | {title, authorTitle, ratings}'
```

### List library and queue

```bash
curl -s -H "X-Api-Key: $READARR_KEY" \
  "http://$CLAWARR_HOST:8787/api/v1/author" | jq '.[] | {authorName, monitored, ratings}'
curl -s -H "X-Api-Key: $READARR_KEY" \
  "http://$CLAWARR_HOST:8787/api/v1/queue" | jq '.'
```

Removal (`DELETE /author/{id}`) is destructive: run only on explicit user request, and confirm what will be removed first.

## Troubleshooting

See `references/common-issues.md` (Import Issues + Path Mapping verbatim upstream, plus a condensed permission checklist) for "No files eligible for import" fixes, remote path mappings, and permission checks.

## Example Prompts

- "Search Readarr for Brandon Sanderson"
- "Add this author to Readarr with default quality"
- "What's in my Readarr download queue?"
- "List my Readarr authors"
