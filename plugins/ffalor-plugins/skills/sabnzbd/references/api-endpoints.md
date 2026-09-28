# SABnzbd API Endpoints

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

## SABnzbd (API)

Base URL: `http://host:8081/api`

All requests: `?apikey=<key>&mode=<mode>&output=json`

### Common Modes
- `mode=queue` - Download queue
- `mode=history&limit=<count>` - Download history
- `mode=pause` - Pause downloads
- `mode=resume` - Resume downloads
- `mode=speedlimit&value=<kbps>` - Set speed limit
- `mode=status` - Server status
- `mode=get_cats` - Categories
- `mode=version` - Version info

### Queue Response
```json
{
  "queue": {
    "status": "Downloading",
    "speed": "10.2 MB/s",
    "kbpersec": "10445.23",
    "size": "15.2 GB",
    "sizeleft": "5.3 GB",
    "timeleft": "0:08:42",
    "paused": false,
    "slots": [
      {
        "nzo_id": "SABnzbd_nzo_abc123",
        "filename": "Movie.Name.2024.1080p.mkv",
        "mb": "5234.2",
        "size": "10.2 GB",
        "percentage": "51",
        "timeleft": "0:08:42",
        "cat": "movies",
        "priority": "Normal"
      }
    ]
  }
}
```


