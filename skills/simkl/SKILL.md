---
name: simkl
description: "Track movies, shows, and anime on Simkl: OAuth auth, watch history, watchlists, stats, and Plex sync."
metadata:
  {
    "openclaw":
      {
        "requires":
          {
            "bins": ["bash", "curl", "jq"],
            "env": ["SIMKL_CLIENT_ID", "SIMKL_CLIENT_SECRET"]
          }
      }
  }
---

# Simkl

Simkl integration for watch-history tracking across movies, shows, and anime: OAuth authentication, profile and stats, watch history, watchlists, and Plex sync.

## Requires

| Variable | Required | Purpose |
|----------|----------|---------|
| `SIMKL_CLIENT_ID` | Yes | Simkl OAuth app client ID (register at `https://simkl.com/settings/developer`) |
| `SIMKL_CLIENT_SECRET` | Yes | Simkl OAuth app client secret |
| `TAUTULLI_KEY` | No (unset-ok) | Tautulli API key — only needed for `sync` |
| `CLAWARR_HOST` | No (unset-ok) | LAN host of Tautulli — only needed for `sync` |

OAuth tokens are saved to `~/.config/clawarr/simkl_tokens.json` with `600` permissions (user read/write only).

Optional helpers: `bc` and `sed` are used for math and text processing in some output formatting; everything else works without them.

## Authentication

Authorization-code OAuth flow:

```bash
scripts/simkl.sh auth          # Start OAuth flow
```

The script prints an authorization URL. Visit it, approve the app, and exchange the returned code for an access token. Search endpoints need only the client ID; user endpoints need the token. Requests send `Authorization: Bearer {access_token}` plus `simkl-api-key: {client_id}`.

## History & Watchlist

```bash
scripts/simkl.sh profile               # Show profile (authenticated user settings)
scripts/simkl.sh stats                 # Viewing statistics
scripts/simkl.sh history [all|movies|shows|anime]
scripts/simkl.sh watchlist [all|movies|shows]
```

History reads from `/sync/all-items/{movies,shows,anime}/watched`; watchlists from `/sync/watchlist/{movies,shows}`.

## Sync

```bash
scripts/simkl.sh sync                  # Sync with Plex (via Tautulli)
```

Requires `TAUTULLI_KEY` + `CLAWARR_HOST`. Fetches recent Plex watch history from Tautulli and reports watched movies and shows. Full ID-matched write-back to Simkl (`POST /sync/history`, `POST /sync/watched`) is not yet implemented in the script — it lists what would sync.

## Reference Documentation

- **`references/tracker-apis.md`** — Simkl API reference (authorization-code flow, endpoints, headers), error handling (status codes, retry strategy), and best practices (token management, ID caching, sync state, rate limits).

## Example Prompts

- "Show my Simkl watch history for anime"
- "What's on my Simkl watchlist?"
- "Authenticate Simkl on this machine"
- "Sync my Plex history with Simkl"
