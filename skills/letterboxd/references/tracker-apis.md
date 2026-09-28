# Letterboxd API Reference

## Letterboxd API


**Base URL:** `https://api.letterboxd.com/api/v0`
**Authentication:** OAuth 2.0 (requires API application approval)
**Status:** Requires approved API access

### CSV Import/Export Format

Letterboxd supports CSV import/export for diary entries:

**CSV Header:**
```
Date,Letterboxd URI,Name,Year,Directors,Rating,Rewatch,Tags,Watched Date
```

**Example Row:**
```
2024-01-15,,Inception,2010,Christopher Nolan,5,No,mind-bending,2024-01-15
```

**Rating Scale:** 0.5 to 5 stars (in 0.5 increments)

### Public Profile Scraping

Public profiles are accessible at:
- `https://letterboxd.com/{username}/`
- `https://letterboxd.com/{username}/films/diary/`

Note: Web scraping is fragile and subject to change. Official API preferred.

## TV Time


**Status:** No public API available

### Export Format

TV Time provides CSV export at:
- `https://www.tvtime.com/export`

Export contains:
- Show name
- Episode watched
- Date watched

## Error Handling


### Common HTTP Status Codes

- **200** - Success
- **201** - Created
- **204** - Success (no content)
- **400** - Bad request (invalid data)
- **401** - Unauthorized (invalid/expired token)
- **404** - Not found
- **409** - Conflict (already exists)
- **420** - Account limit exceeded
- **422** - Validation error
- **429** - Rate limit exceeded
- **500** - Server error
- **502** - Bad gateway
- **503** - Service unavailable

### Retry Strategy

1. **401 Unauthorized** - Refresh token, retry once
2. **429 Rate Limit** - Wait and exponentially backoff
3. **5xx Server Error** - Retry with backoff (max 3 attempts)
4. **Other errors** - Report and skip item

## Best Practices


### Token Management

- Store tokens in `~/.config/clawarr/` with 600 permissions
- Auto-refresh tokens before expiry
- Include created_at and expires_at timestamps

### ID Caching

For sync operations, maintain a local cache:
```json
{
  "inception_2010": {
    "trakt": 16662,
    "simkl": 5,
    "tmdb": 27205,
    "imdb": "tt1375666"
  }
}
```

### Sync State

Track last sync time to avoid re-syncing:
```json
{
  "last_sync": {
    "plex_to_trakt": 1704470400,
    "trakt_to_letterboxd": 1704380400
  }
}
```

### Rate Limit Compliance

- Respect `X-RateLimit-*` headers
- Implement exponential backoff
- Use bulk endpoints for large operations
- Cache results where possible
