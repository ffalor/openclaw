---
name: trakt
description: "Sync Trakt.tv watch history, scrobble playback, manage watchlists and ratings, bridge Plex history, and automate Traktarr lists."
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["TRAKT_CLIENT_ID", "TRAKT_CLIENT_SECRET"]}}}
---

# Trakt

Trakt.tv integration for watch-history tracking, scrobbling, watchlists, collections, ratings, discovery, Plex sync, and Traktarr/Retraktarr list automation.

## Requires

| Variable | Required | Purpose |
|----------|----------|---------|
| `TRAKT_CLIENT_ID` | Yes | Trakt OAuth app client ID (register at `https://trakt.tv/oauth/applications/new`) |
| `TRAKT_CLIENT_SECRET` | Yes | Trakt OAuth app client secret |
| `PLEX_TOKEN` | No (unset-ok) | Plex authentication token — only needed for `sync-plex` |
| `TAUTULLI_URL` | No (unset-ok) | Tautulli base URL (e.g., `http://host:8181` or `https://...`) — only needed for `sync-plex` |
| `TAUTULLI_API_KEY` | No (unset-ok) | Tautulli API key — only needed for `sync-plex` |
| `RADARR_URL` | No (unset-ok) | Radarr base URL (e.g., `http://host:7878` or `https://...`) — used by Traktarr/Retraktarr |
| `RADARR_API_KEY` | No (unset-ok) | Radarr API key — used by Traktarr/Retraktarr |
| `SONARR_URL` | No (unset-ok) | Sonarr base URL (e.g., `http://host:8989` or `https://...`) — used by Traktarr/Retraktarr |
| `SONARR_API_KEY` | No (unset-ok) | Sonarr API key — used by Traktarr/Retraktarr |
| `CLAWARR_HOST` | No (unset-ok) | Optional fallback LAN host — builds `http://$CLAWARR_HOST:8181` for Tautulli, `http://$CLAWARR_HOST:7878` for Radarr, and `http://$CLAWARR_HOST:8989` for Sonarr when their `_URL` is unset |

OAuth tokens are saved to `~/.config/clawarr/trakt_tokens.json` with `600` permissions (user read/write only) and refreshed automatically.

Optional helpers: `bc` and `sed` are used for math and text processing in some output formatting; everything else works without them.

## Authentication

Device-code OAuth flow (no browser callback needed):

```bash
scripts/trakt.sh auth          # Start device-code flow, prompts for user_code verification
scripts/trakt.sh auth-status   # Check authentication state
```

Tokens are stored with `created_at`/`expires_at` timestamps and auto-refreshed before expiry.

## Watching & History

```bash
scripts/trakt.sh watching                    # Currently watching
scripts/trakt.sh history [movies|shows|episodes|all] [limit]
scripts/trakt.sh sync-history export file.json
scripts/trakt.sh sync-history import file.json
```

## Scrobbling & Check-in

```bash
scripts/trakt.sh scrobble start movie 12345
scripts/trakt.sh scrobble pause movie 12345 50
scripts/trakt.sh scrobble stop movie 12345 100
scripts/trakt.sh checkin movie "Inception"
```

Scrobble body: `{"movie": {"ids": {"trakt": 123}}, "progress": 75}`. Supported ID types: `trakt`, `imdb` (`tt#######`), `tmdb`, `slug`.

## Lists, Collections & Ratings

```bash
scripts/trakt.sh watchlist [movies|shows|all]
scripts/trakt.sh watchlist-add movie "Dune Part Two"
scripts/trakt.sh collection [movies|shows|all]
scripts/trakt.sh collection-add movie 12345
scripts/trakt.sh lists                 # Custom lists
scripts/trakt.sh list-items my-favorites
scripts/trakt.sh ratings [movies|shows|all] [min_rating]
scripts/trakt.sh rate movie "Inception" 10
```

## Discovery & Search

```bash
scripts/trakt.sh recommendations movies
scripts/trakt.sh trending shows
scripts/trakt.sh popular movies
scripts/trakt.sh calendar all 7        # Next 7 days
scripts/trakt.sh search "Breaking Bad" show
scripts/trakt.sh profile [username]    # Show profile (default: me)
scripts/trakt.sh stats [username]      # Detailed statistics
```

## Plex Sync

Sync Plex watch history (via Tautulli) to Trakt. This is the primary consumer of the Plex + Tautulli mapping strategy:

```bash
scripts/trakt.sh sync-plex
```

Requires `TAUTULLI_API_KEY` + `TAUTULLI_URL` (or `CLAWARR_HOST` as fallback). Movies are matched by title + year; episodes by show title + season/episode number. Large libraries are synced with bulk `/sync/history` calls and matched IDs are cached locally. See `references/tracker-apis.md` for the Tautulli history endpoint, mapping strategy, and rate-limiting best practices.

## Traktarr & Retraktarr

**Traktarr** (Trakt → Radarr/Sonarr) auto-adds content from Trakt lists for download. **Retraktarr** (Radarr/Sonarr → Trakt) syncs the library back to Trakt as public/private lists:

```bash
scripts/trakt.sh traktarr-status       # Check if installed
scripts/trakt.sh traktarr-config       # Configure Traktarr
scripts/trakt.sh traktarr-add movies trending 10
scripts/trakt.sh traktarr-add shows anticipated 5
scripts/trakt.sh retraktarr-status     # Check if installed
scripts/trakt.sh retraktarr-config     # Configure Retraktarr
scripts/trakt.sh retraktarr-sync all   # Sync movies and shows
```

See `references/traktarr-retraktarr.md` for complete setup, config reference, cron scheduling, common patterns, and troubleshooting.

## Unified Multi-Tracker Interface

`scripts/trackers.sh` provides a unified wrapper (`setup`, `status`, `sync`, `export`, `import`, `compare`, `profile`). It calls the sibling `scripts/trakt.sh`, `scripts/simkl.sh`, and `scripts/letterboxd.sh` (verbatim copies of the simkl/letterboxd skills' scripts, bundled so cross-tracker commands work). Simkl commands still need `SIMKL_CLIENT_ID`/`SIMKL_CLIENT_SECRET` set.

```bash
scripts/trackers.sh setup              # Interactive setup wizard (includes Traktarr/Retraktarr options)
scripts/trackers.sh status             # Show configured trackers
scripts/trackers.sh sync plex trakt    # Sync Plex → Trakt
scripts/trackers.sh export trakt json  # Export watch history
scripts/trackers.sh compare trakt simkl  # Requires SIMKL_* keys
```

## Reference Documentation

- **`references/tracker-apis.md`** — Trakt.tv API v2 reference (OAuth device-code flow, endpoints, headers, ID types), Plex + Tautulli integration (history endpoint, mapping strategy, rate limiting), error handling, and best practices.
- **`references/traktarr-retraktarr.md`** — Traktarr & Retraktarr installation, configuration, cron automation, common patterns, troubleshooting, and best practices.

## Example Prompts

- "Show my Trakt watch history for movies"
- "Scrobble Dune Part Two as finished on Trakt"
- "Sync my Plex watch history to Trakt"
- "Add 10 trending movies from Trakt to Radarr via Traktarr"
