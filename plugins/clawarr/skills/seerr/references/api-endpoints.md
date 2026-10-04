# Seerr API Endpoints

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

## Seerr (API v1)

Base URL: `http://host:5055/api/v1`

### System
- `GET /status` - System status
- `GET /settings/public` - Public settings

### Requests
- `GET /request` - All requests
- `GET /request/{id}` - Single request
- `POST /request` - Create request
- `POST /request/{id}/approve` - Approve request
- `POST /request/{id}/decline` - Decline request
- `DELETE /request/{id}` - Delete request

### Search
- `GET /search?query=<term>` - Multi-search (movies + TV)
- `GET /search/movie?query=<term>` - Movie search
- `GET /search/tv?query=<term>` - TV search

### Media
- `GET /media` - All media
- `GET /media/{id}` - Single media item

### Users
- `GET /user` - All users
- `GET /user/me` - Current user


## Advanced Seerr Endpoints

### Issue Tracking
- `GET /issue` - All issues
- `POST /issue` - Create issue
- `POST /issue/<id>/comment` - Add comment
- `PUT /issue/<id>/resolved` - Mark resolved

### Webhooks
- `GET /settings/notifications/webhook` - Webhook settings
- `POST /settings/notifications/webhook/test` - Test webhook

### Collections
- `GET /collection/<id>` - Collection details
- `POST /collection/<id>/request` - Request entire collection


