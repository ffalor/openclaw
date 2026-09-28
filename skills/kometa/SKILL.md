---
name: kometa
description: Plex collection, overlay, and metadata automation via kometa.sh and Kometa defaults.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["KOMETA_SSH"]}}}
---

# Kometa

Plex collection, poster-overlay, and metadata automation (formerly Plex Meta Manager). Builds genre/IMDb/TMDb/Trakt collections and applies badges (resolution, audio codec, ratings) from `config.yml` defaults.

## Requires

| Variable | Purpose | Default |
|---|---|---|
| `KOMETA_SSH` | SSH host for the Docker host running Kometa | — |
| `PLEX_TOKEN` | Plex token (optional; needed for some Plex lookups) | — |
| `CLAWARR_HOST` | Service host (used by some status paths) | — |
| `KOMETA_DOCKER_CMD` / `KOMETA_CONTAINER` | Docker binary / container overrides | `docker` / `kometa` |
| `DOCKER_CONFIG_BASE` | Docker config root for `kometa/config.yml` lookup (optional) | `/volume1/docker` |

Needs `docker` and `ssh` (local or remote) as optional tools to reach the container; without `KOMETA_SSH` the script targets the local Docker daemon. `PLEX_TOKEN` is optional — set it when commands need direct Plex API access. See `references/companion-services.md` (Kometa section) for `config.yml` setup and available collection/overlay defaults.

## Commands (`scripts/kometa.sh`)

```bash
kometa.sh status                  # Check container status
kometa.sh run [library]           # Run Kometa (all or specific library)
kometa.sh collections             # Show Plex collections
kometa.sh overlays                # Check overlay config
kometa.sh config                  # Show Kometa config
kometa.sh templates               # List available default collections/overlays
kometa.sh logs [count]            # View recent logs
```

## Example prompts

- "Run Kometa for the Movies library"
- "Show my Plex collections managed by Kometa"
- "What overlay defaults are available?"
- "Check Kometa's last run status"

## Connectivity checklist

1. `KOMETA_SSH` reaches the Docker host (or local Docker daemon running)
2. Container `kometa` exists (or `KOMETA_CONTAINER` override matches)
3. `config.yml` present (`DOCKER_CONFIG_BASE/kometa/` when remote)
4. Plex URL and token set in `config.yml` (plus `PLEX_TOKEN` here if needed)
5. `kometa.sh status` reports the container and last run

## Destructive actions

`kometa.sh run` rewrites Plex collections, overlays, and metadata. Run it only on explicit user request.
