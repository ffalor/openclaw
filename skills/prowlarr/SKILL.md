---
name: prowlarr
description: Centralized Prowlarr indexer management — list, test, search indexers and sync them to Sonarr/Radarr.
metadata:
  openclaw:
    requires:
      bins: ["bash", "curl", "jq"]
      env: ["CLAWARR_HOST", "PROWLARR_KEY"]
---

# Prowlarr

Centralized indexer management via Prowlarr. Add indexers once here and sync them
to Sonarr, Radarr, Lidarr, and Readarr. See `references/companion-services.md`
for sync-target setup and FlareSolverr bypass, and `references/api-endpoints.md`
for the raw API.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Required | Purpose |
|----------|----------|---------|
| `CLAWARR_HOST` | Yes | Host IP/hostname of the Prowlarr instance (port 9696) |
| `PROWLARR_KEY` | Yes | Prowlarr API key (Settings → General → Security → API Key) |

```bash
export CLAWARR_HOST=192.168.1.100
export PROWLARR_KEY=abc123...
```

Find the key via `curl -s http://HOST:9696/initialize.json | jq -r '.apiKey'`,
from `/config/config.xml` inside the container, or the Prowlarr web UI.

## Scripts

### Full management (`prowlarr.sh`)

```bash
scripts/prowlarr.sh indexers              # List all indexers
scripts/prowlarr.sh test [id]             # Test indexer(s)
scripts/prowlarr.sh stats                 # Indexer & app sync statistics
scripts/prowlarr.sh search <query> [type] # Search across all indexers (type: movie|tv|audio|book)
scripts/prowlarr.sh apps                  # List sync targets (Sonarr/Radarr/etc)
scripts/prowlarr.sh add-app <type> <url> <key>  # Add app sync target
scripts/prowlarr.sh sync                  # Trigger sync to all apps
scripts/prowlarr.sh status                # Health check
scripts/prowlarr.sh logs [count]          # Recent logs
```

### Indexer status (`indexers.sh`)

```bash
scripts/indexers.sh list      # List configured indexers with status
scripts/indexers.sh test [id] # Test indexer connectivity (all or specific ID)
scripts/indexers.sh stats     # Indexer performance statistics
```

## Common Workflows

```bash
# List and test all indexers
scripts/prowlarr.sh indexers
scripts/prowlarr.sh test

# Search across all indexers
scripts/prowlarr.sh search "Dune" movie

# Add Sonarr/Radarr as sync targets
scripts/prowlarr.sh add-app sonarr http://host:8989 <sonarr_key>
scripts/prowlarr.sh add-app radarr http://host:7878 <radarr_key>

# Trigger indexer sync to all apps
scripts/prowlarr.sh sync
```

Search categories: Movies `2000`, TV `5000`, Audio `3000`, Books `7000`.
Indexers behind Cloudflare protection need FlareSolverr (port 8191) configured
as a proxy in Prowlarr (see `references/companion-services.md`).

## Example Prompts

- "Show all my indexers and test them"
- "Search across all indexers for Breaking Bad"
- "Sync Prowlarr indexers to Sonarr and Radarr"
- "Add Sonarr as a sync target in Prowlarr"

## Troubleshooting

Connectivity checklist:

1. Host reachable: `curl -s http://$CLAWARR_HOST:9696/api/v1/system/status -H "X-Api-Key: $PROWLARR_KEY"`
2. `CLAWARR_HOST` is set and points at the Prowlarr machine (no scheme, no port).
3. `PROWLARR_KEY` matches Settings → General → Security → API Key (regenerate if unsure).
4. Port `9696` is open on the host firewall and the container is running (`docker logs prowlarr`).
5. Container logs show no errors: `docker logs prowlarr --tail 50`

## References

- `references/api-endpoints.md` — Prowlarr API v1 reference
- `references/companion-services.md` — Sync targets, search categories, FlareSolverr setup
