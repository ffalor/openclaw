# API Endpoints Reference (Plex)

_Extracted verbatim from the clawarr-suite source skill._

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

## Plex Media Server

Base URL: `http://host:32400`

### System
- `GET /identity` - Server identity
- `GET /` - Server capabilities

### Library
- `GET /library/sections` - All library sections
- `GET /library/sections/{id}/all` - All items in section
- `GET /library/sections/{id}/refresh` - Refresh library section
- `GET /library/recentlyAdded` - Recently added items

### Metadata
- `GET /library/metadata/{id}` - Item metadata
- `GET /library/metadata/{id}/children` - Children (seasons/episodes)

### Playback
- `GET /status/sessions` - Current playback sessions

## Advanced Plex Endpoints

### Playback Control
- `POST /player/playback/playMedia?...` - Start playback
- `POST /player/playback/pause` - Pause
- `POST /player/playback/play` - Resume
- `POST /player/playback/stop` - Stop
- `POST /player/playback/skipNext` - Next track
- `POST /player/playback/skipPrevious` - Previous track

### Search
- `GET /hubs/search?query=<term>` - Universal search
- `GET /library/sections/<id>/search?title=<term>` - Library search

### Playlists
- `GET /playlists` - All playlists
- `GET /playlists/<id>/items` - Playlist items
- `POST /playlists` - Create playlist
- `PUT /playlists/<id>/items` - Add to playlist

### Users
- `GET /accounts` - Managed users (home users)
- `GET /myplex/account` - Current account info
