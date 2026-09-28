# Readarr API Endpoints

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

## Readarr (API v1)

Base URL: `http://host:8787/api/v1`

### Authors
- `GET /author` - All authors
- `GET /author/{id}` - Single author
- `GET /author/lookup?term=<query>` - Search authors
- `POST /author` - Add author
- `DELETE /author/{id}` - Delete author

### Books
- `GET /book` - All books
- `GET /book/{id}` - Single book
- `GET /book/lookup?term=<query>` - Search books
- `POST /book` - Add book

### Queue
- `GET /queue` - Download queue
- `DELETE /queue/{id}` - Remove from queue
