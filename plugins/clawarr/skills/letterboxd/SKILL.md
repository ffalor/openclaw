---
name: letterboxd
description: "Bridge Letterboxd diary via CSV export/import, convert Trakt history to Letterboxd format, and read public profiles."
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Letterboxd

Letterboxd integration centered on its CSV diary format: export Plex/Radarr watch history as Letterboxd-compatible CSV, convert Trakt history JSON to CSV, import Letterboxd diary exports locally, and read public profiles and diaries.

## Requires

This skill needs no environment variables — the CSV path works entirely without API access.

| Variable | Required | Purpose |
|----------|----------|---------|
| `LETTERBOXD_API_KEY` | No (unset-ok) | Letterboxd API key — only useful with approved API access; all script commands work without it |
| `TAUTULLI_URL` | No (unset-ok) | Tautulli base URL (e.g., `http://host:8181` or `https://...`) — enables `export` from Plex watch history |
| `TAUTULLI_API_KEY` | No (unset-ok) | Tautulli API key — enables `export` from Plex watch history |
| `RADARR_URL` | No (unset-ok) | Radarr base URL (e.g., `http://host:7878` or `https://...`) — alternative `export` source |
| `RADARR_API_KEY` | No (unset-ok) | Radarr API key — alternative `export` source (movies with files) |
| `CLAWARR_HOST` | No (unset-ok) | Optional fallback LAN host — builds `http://$CLAWARR_HOST:8181` for Tautulli or `http://$CLAWARR_HOST:7878` for Radarr when their `_URL` is unset |

Optional helpers: `sed` is used for CSV field cleanup; everything else works without it.

## CSV Format

Letterboxd diary CSV header:

```
Date,Letterboxd URI,Name,Year,Directors,Rating,Rewatch,Tags,Watched Date
```

Rating scale is 0.5 to 5 stars in 0.5 increments. Import finished CSVs at `https://letterboxd.com/import/`.

## Export & Import

```bash
scripts/letterboxd.sh export [file]              # Export Plex/Radarr history as Letterboxd CSV
scripts/letterboxd.sh export-from-trakt in.json [out.csv]  # Convert Trakt history JSON to CSV
scripts/letterboxd.sh import diary.csv           # Import Letterboxd diary to local tracking
```

`export` prefers Tautulli watch history (`TAUTULLI_API_KEY` + `TAUTULLI_URL`, or `CLAWARR_HOST` as fallback) and falls back to the Radarr library (`RADARR_API_KEY` + `RADARR_URL`, or `CLAWARR_HOST` as fallback); it exits with a clear error when neither is configured. `export-from-trakt` converts movie entries from `trakt.sh sync-history export` output. `import` parses a Letterboxd diary CSV into a local JSON database at `~/.config/clawarr/letterboxd_import.json`.

## Public Profiles & Diaries

The official Letterboxd API requires approved application access. Until then the script reads public pages (`https://letterboxd.com/{username}/`, `.../films/diary/`), which is fragile and subject to change — prefer the official API once approved:

```bash
scripts/letterboxd.sh profile username   # Scrape public profile stats
scripts/letterboxd.sh diary username [year]  # View public diary entries
```

## TV Time

TV Time offers no public API. Export watched episodes as CSV from `https://www.tvtime.com/export` (show name, episode, date watched) and track them alongside Letterboxd data.

## Reference Documentation

- **`references/tracker-apis.md`** — Letterboxd CSV format and rating scale, TV Time export notes, error handling (status codes, retry strategy), and best practices (token management, ID caching, sync state, rate limits).

## Example Prompts

- "Export my Plex movie history as a Letterboxd CSV"
- "Convert my Trakt history to Letterboxd format"
- "Import my Letterboxd diary export"
- "Show the public diary of user cinemaphile for 2024"
