---
name: prowlarr
description: Centralized Prowlarr indexer management — list, test, search indexers and sync them to Sonarr/Radarr.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Prowlarr

Centralized indexer management via Prowlarr. Add indexers once here and sync them
to Sonarr, Radarr, Lidarr, and Readarr. See `references/companion-services.md`
for sync-target setup and FlareSolverr bypass, and `references/api-endpoints.md`
for the raw API.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `PROWLARR_URL` | Prowlarr base URL, e.g. `https://prowlarr.example.ts.net` or `http://192.168.1.100:9696` |
| `PROWLARR_API_KEY` | API key (Settings → General → Security → API Key) |
| `CLAWARR_HOST` | Optional fallback when `PROWLARR_URL` is unset: `http://$CLAWARR_HOST:9696` (`CLAWARR_SCHEME`, `PROWLARR_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh prowlarr <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$PROWLARR_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Prowlarr API: `$PROWLARR_URL/api/v1`, auth header `X-Api-Key: $PROWLARR_API_KEY`.

**Calling the API yourself:** always use `$PROWLARR_URL` with `$PROWLARR_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

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

Indexer success-rate stats use `bc`; install it if those lines error.

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

1. Host reachable: `curl -s $PROWLARR_URL/api/v1/system/status -H "X-Api-Key: $PROWLARR_API_KEY"`
2. `PROWLARR_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Prowlarr instance; run `scripts/setup.sh prowlarr <url>` from the clawarr-core skill to (re)configure it.
3. `PROWLARR_API_KEY` matches Settings → General → Security → API Key (regenerate if unsure).
4. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
5. Port `9696` is open on the host firewall and the container is running (`docker logs prowlarr`).
6. Container logs show no errors: `docker logs prowlarr --tail 50`

## References

- `references/api-endpoints.md` — Prowlarr API v1 reference
- `references/companion-services.md` — Sync targets, search categories, FlareSolverr setup

## Destructive actions

Adding apps or triggering an indexer sync pushes indexer config into Sonarr/Radarr. Act only on explicit user request.
