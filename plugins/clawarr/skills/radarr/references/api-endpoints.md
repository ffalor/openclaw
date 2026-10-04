# Radarr API Endpoints

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

**Tautulli/Seerr:**
```
Query param: ?apikey=<key>
Or Header: X-Api-Key: <key>
```

## Radarr (API v3)

Base URL: `http://host:7878/api/v3`

### System
- `GET /system/status` - System information
- `GET /health` - Health checks

### Movies
- `GET /movie` - All movies
- `GET /movie/{id}` - Single movie
- `GET /movie/lookup?term=<query>` - Search for movies
- `GET /movie/lookup/tmdb?tmdbId=<id>` - Lookup by TMDB ID
- `POST /movie` - Add movie
- `PUT /movie/{id}` - Update movie
- `DELETE /movie/{id}` - Delete movie

### Queue
- `GET /queue` - Download queue
- `DELETE /queue/{id}?removeFromClient=true` - Remove from queue

### History
- `GET /history?pageSize=20&sortKey=date&sortDirection=descending` - History
- `GET /history/movie?movieId={id}` - Movie history

### Quality Profiles
- `GET /qualityprofile` - All quality profiles

### Root Folders
- `GET /rootfolder` - All root folders

### Download Clients
- `GET /downloadclient` - All download clients
- `POST /downloadclient/test` - Test connection

### Commands
- `POST /command`
  - `{"name": "MoviesSearch", "movieIds": [1,2,3]}`
  - `{"name": "MissingMoviesSearch"}`
  - `{"name": "RssSync"}`
  - `{"name": "RefreshMovie", "movieId": 1}`
