# Lidarr API Endpoints

Extracted verbatim from the upstream clawarr-suite reference.

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

## Lidarr (API v1)

Base URL: `http://host:8686/api/v1`

### Artists
- `GET /artist` - All artists
- `GET /artist/{id}` - Single artist
- `GET /search?term=<query>` - Search
- `POST /artist` - Add artist
- `DELETE /artist/{id}` - Delete artist

### Albums
- `GET /album` - All albums
- `GET /album/{id}` - Single album
- `GET /album?artistId={id}` - Albums by artist

### Queue
- `GET /queue` - Download queue
- `DELETE /queue/{id}` - Remove from queue

### Quality Profiles
- `GET /qualityprofile` - All quality profiles

### Root Folders
- `GET /rootfolder` - All root folders
