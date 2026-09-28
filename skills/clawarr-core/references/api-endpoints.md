# API Endpoints Reference

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

## Common Patterns

### Search and Add Workflow

1. **Search:**
   ```bash
   GET /movie/lookup?term=dune
   ```

2. **Get quality profiles and root folders:**
   ```bash
   GET /qualityprofile
   GET /rootfolder
   ```

3. **Add with search:**
   ```bash
   POST /movie
   {
     "title": "Dune",
     "tmdbId": 438631,
     "qualityProfileId": 1,
     "rootFolderPath": "/movies",
     "monitored": true,
     "addOptions": {
       "searchForMovie": true
     }
   }
   ```

### Queue Management

1. **Get queue:**
   ```bash
   GET /queue
   ```

2. **Remove stuck item:**
   ```bash
   DELETE /queue/{id}?removeFromClient=true&blocklist=false
   ```

### Health Monitoring

```bash
# Check all services
GET /health  # Returns array of issues

# Empty array = healthy
# Non-empty = issues to address
```

## Homarr

Note: Homarr is primarily a frontend dashboard aggregator. It does not expose a comprehensive REST API for querying data. Instead, it integrates with *arr apps and other services using their APIs.

For Homarr automation:
- Use individual service APIs (Radarr, Sonarr, etc.)
- Homarr stores config in SQLite database
- Direct database access possible but not recommended
- Future versions may expose REST API

## Error Responses

All APIs return similar error formats:

```json
{
  "error": "Error message",
  "message": "Detailed error description"
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad request (validation error)
- `401` - Unauthorized (invalid API key)
- `404` - Not found
- `500` - Internal server error
