# Simkl API Reference

## Simkl API


**Base URL:** `https://api.simkl.com`
**Authentication:** OAuth 2.0 (authorization code flow)
**Rate Limits:** Varies by endpoint

### Authentication Flow

1. **Generate Authorization URL**
   - User visits: `https://simkl.com/oauth/authorize?response_type=code&client_id=...&redirect_uri=...`

2. **Exchange Code for Token**
   - POST `/oauth/token`
   - Body: `{"code": "...", "client_id": "...", "client_secret": "...", "grant_type": "authorization_code"}`

### Common Endpoints

**User:**
- GET `/users/settings` - Current user settings

**History:**
- GET `/sync/all-items/movies/watched` - Watched movies
- GET `/sync/all-items/shows/watched` - Watched shows
- GET `/sync/all-items/anime/watched` - Watched anime

**Watchlist:**
- GET `/sync/watchlist/movies` - Movie watchlist
- GET `/sync/watchlist/shows` - Show watchlist

**Sync:**
- POST `/sync/history` - Add watch history
- POST `/sync/watched` - Mark as watched

### Headers Required

```
Content-Type: application/json
Authorization: Bearer {access_token}
simkl-api-key: {client_id}
```

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
