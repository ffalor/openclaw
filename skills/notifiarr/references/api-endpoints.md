# Notifiarr API Endpoints

Endpoints used by `scripts/notifiarr.sh` (verified from script source; the shared
API reference has no Notifiarr section). All endpoints are JSON.

## Authentication

Notifiarr accepts the API key in a header (key optional for local status checks —
the script falls back to unauthenticated calls when `NOTIFIARR_KEY` is unset):

```
Header: x-api-key: <api-key>
```

Base URL: `http://host:5454/api` (port overridable via `NOTIFIARR_PORT`).
Web UI root: `http://host:5454` (no `/api` prefix).

## Status

- `GET /version` - Version info (`{"version": "..."}`)
- `GET /config` - Full configuration, including per-service URLs
  (`sonarr[0].url`, `radarr[0].url`, `lidarr`, `readarr`, `prowlarr`, `plex.url`)
- Plain `GET /` on the web UI root - Reachability check (no auth needed)

## Notifications

- `GET /triggers` - Notification trigger configuration
- `POST /notification/test` - Send a test notification
  - Body `{"channel": "<name>"}` for a specific channel, or `{}` for all channels

## Services

- `GET /services` - Connected services with enabled flags
  (`{ "<key>": {"enabled": true, "name": "..."} }`)

## Logs

- `GET /logs?count=20` - Recent notification log
  (entries carry `timestamp`/`time` and `event`/`message` fields)
