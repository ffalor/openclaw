# API Endpoints Reference (Tautulli)

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

**Tautulli/Overseerr:**
```
Query param: ?apikey=<key>
Or Header: X-Api-Key: <key>
```

## Tautulli (API v2)

Base URL: `http://host:8181/api/v2`

All requests: `?apikey=<key>&cmd=<command>`

### Common Commands
- `cmd=status` - Server status
- `cmd=get_activity` - Current activity
- `cmd=get_history&length=10` - Watch history
- `cmd=get_home_stats` - Homepage statistics
- `cmd=get_library_names` - Library sections
- `cmd=get_library_media_info&section_id=1` - Library contents
- `cmd=get_recently_added&count=10` - Recently added
- `cmd=get_user_names` - All users
- `cmd=get_user_watch_time_stats&user_id=1` - User stats

## Advanced Tautulli Endpoints

### Watch Statistics
- `cmd=get_user_watch_time_stats&user_id=<id>&query_days=<days>` - User watch time
- `cmd=get_plays_by_date&time_range=<days>` - Plays by date
- `cmd=get_plays_by_hour_of_day&time_range=<days>` - Hourly breakdown
- `cmd=get_plays_by_dayofweek&time_range=<days>` - Day of week breakdown

### Library Operations
- `cmd=get_library&section_id=<id>` - Library details
- `cmd=get_library_media_info&section_id=<id>&length=<count>` - Media in library
- `cmd=refresh_libraries_list` - Refresh library cache
- `cmd=get_sync_item&sync_id=<id>` - Synced item details

### User Management
- `cmd=get_user&user_id=<id>` - User details
- `cmd=get_user_player_stats&user_id=<id>` - Player statistics
- `cmd=get_user_ips&user_id=<id>` - User IP history

### Notifications
- `cmd=notify&notifier_id=<id>&subject=<text>&body=<text>` - Send notification
- `cmd=get_notifier_config&notifier_id=<id>` - Notifier settings
