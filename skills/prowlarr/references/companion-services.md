# Prowlarr Companion Services

Guide for *arr stack companion services: Prowlarr, Recyclarr, FlareSolverr, Unpackerr, Notifiarr, Maintainerr, and Kometa.


## Prowlarr — Indexer Management

### What It Does
Centralized indexer management. Add indexers once in Prowlarr, and they automatically sync to Sonarr, Radarr, Lidarr, and Readarr.

### Key API Endpoints
```
GET  /api/v1/indexer              # List indexers
POST /api/v1/indexer/test         # Test indexer
GET  /api/v1/applications         # List sync targets
POST /api/v1/applications         # Add sync target
POST /api/v1/applications/action/sync  # Trigger sync
GET  /api/v1/search?query=...     # Search across indexers
GET  /api/v1/health               # Health check
GET  /api/v1/system/status        # System info
GET  /api/v1/log                  # Logs
```

### Adding Sync Targets
After installing Prowlarr, add each *arr app as a sync target:
```json
{
  "name": "Sonarr",
  "implementation": "Sonarr",
  "configContract": "SonarrSettings",
  "syncLevel": "fullSync",
  "fields": [
    {"name": "prowlarrUrl", "value": "http://host:9696"},
    {"name": "baseUrl", "value": "http://host:8989"},
    {"name": "apiKey", "value": "sonarr-api-key"}
  ]
}
```

### Search Categories
- Movies: 2000
- TV: 5000
- Audio: 3000
- Books: 7000

---
## FlareSolverr — Cloudflare Bypass

### What It Does
Proxy that solves Cloudflare challenges. Some indexers use Cloudflare protection that blocks automated access. FlareSolverr sits between Prowlarr and these indexers.

### Setup
1. Run FlareSolverr container (port 8191)
2. In Prowlarr: Settings → Indexers → Add → FlareSolverr
3. Set URL: `http://host:8191`
4. Tag indexers that need Cloudflare bypass

### API
```
POST /v1 {"cmd": "request.get", "url": "..."}
GET  /health
```

No configuration needed beyond running the container. It auto-handles challenges.

---
