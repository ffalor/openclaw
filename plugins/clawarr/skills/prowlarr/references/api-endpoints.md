# Prowlarr API Endpoints

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

**Tautulli/Seerr:**
```
Query param: ?apikey=<key>
Or Header: X-Api-Key: <key>
```

## Prowlarr (API v1)

Base URL: `http://host:9696/api/v1`

### Indexers
- `GET /indexer` - All indexers
- `GET /indexer/{id}` - Single indexer
- `POST /indexer` - Add indexer
- `PUT /indexer/{id}` - Update indexer
- `DELETE /indexer/{id}` - Delete indexer
- `POST /indexer/test` - Test indexer
- `POST /indexer/testall` - Test all indexers

### Applications
- `GET /applications` - All applications (Sonarr/Radarr/etc)
- `POST /applications` - Add application

### Search
- `GET /search?query=<term>&indexerIds=<id>` - Search indexers

### System
- `GET /system/status` - System information
- `GET /health` - Health checks


