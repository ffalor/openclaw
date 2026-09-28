# Companion Services Reference (Unpackerr)

_Extracted verbatim from the clawarr-suite source skill._

## Unpackerr — Archive Extraction

### What It Does
Monitors Sonarr/Radarr/Lidarr download queues and automatically extracts compressed archives (.rar, .zip, etc.) so the *arr apps can import them.

### Configuration (Environment Variables)
```bash
# Sonarr integration
UN_SONARR_0_URL=http://host:8989
UN_SONARR_0_API_KEY=sonarr-key
UN_SONARR_0_PATHS_0=/downloads/tv

# Radarr integration
UN_RADARR_0_URL=http://host:7878
UN_RADARR_0_API_KEY=radarr-key
UN_RADARR_0_PATHS_0=/downloads/movies

# Optional: Lidarr
UN_LIDARR_0_URL=http://host:8686
UN_LIDARR_0_API_KEY=lidarr-key
```

### How It Works
1. Monitors *arr app queues via API
2. When a download completes with archives, extracts them
3. Notifies the *arr app to retry import
4. Cleans up extracted files after successful import

No manual intervention needed. Fully automated.
