# Sonarr API Endpoints

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

## Sonarr (API v3)

Base URL: `http://host:8989/api/v3`

### System
- `GET /system/status` - System information
- `GET /health` - Health checks
- `GET /log/file` - Log file contents

### Series
- `GET /series` - All series
- `GET /series/{id}` - Single series
- `GET /series/lookup?term=<query>` - Search for series
- `POST /series` - Add series
- `PUT /series/{id}` - Update series
- `DELETE /series/{id}` - Delete series

### Episodes
- `GET /episode` - All episodes
- `GET /episode/{id}` - Single episode
- `GET /episode?seriesId={id}` - Episodes for series

### Queue
- `GET /queue` - Download queue
- `GET /queue/{id}` - Queue item details
- `DELETE /queue/{id}?removeFromClient=true` - Remove from queue

### History
- `GET /history?pageSize=20&sortKey=date&sortDirection=descending` - History
- `GET /history/series?seriesId={id}` - Series history

### Quality Profiles
- `GET /qualityprofile` - All quality profiles
- `GET /qualityprofile/{id}` - Single profile

### Root Folders
- `GET /rootfolder` - All root folders
- `POST /rootfolder` - Add root folder

### Download Clients
- `GET /downloadclient` - All download clients
- `GET /downloadclient/{id}` - Single client
- `POST /downloadclient/test` - Test connection

### Indexers
- `GET /indexer` - All indexers
- `POST /indexer/test` - Test indexer

### Commands
- `POST /command` - Execute command
  - `{"name": "SeriesSearch", "seriesId": 1}`
  - `{"name": "EpisodeSearch", "episodeIds": [1,2,3]}`
  - `{"name": "MissingEpisodeSearch"}`
  - `{"name": "RssSync"}`
