# Bazarr API Endpoints

Complete API reference for all *arr services. All endpoints use JSON for request/response bodies.

## Authentication

All requests require authentication:

**Sonarr/Radarr/Lidarr/Readarr/Prowlarr/Bazarr:**
```
Header: X-Api-Key: <api-key>
```

**Plex:**
```
Header: X-Plex-Token: <token>
```

**Tautulli/Overseerr:**
```
Query param: ?apikey=<key>
Or Header: X-Api-Key: <key>
```

## Bazarr (API v1)

Base URL: `http://host:6767/api`

### System
- `GET /system/status` - System status
- `GET /system/health` - Health checks

### Episodes
- `GET /episodes` - All episodes
- `GET /episodes/wanted` - Episodes missing subtitles
- `POST /episodes/search` - Search subtitles for episode

### Movies
- `GET /movies` - All movies
- `GET /movies/wanted` - Movies missing subtitles
- `POST /movies/search` - Search subtitles for movie

### Providers
- `GET /providers` - All subtitle providers
- `POST /providers/test` - Test provider


