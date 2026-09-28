---
name: recyclarr
description: Sync TRaSH Guides quality profiles to Sonarr and Radarr via recyclarr.sh.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["RECYCLARR_SSH"]}}}
---

# Recyclarr

TRaSH Guides quality-profile sync for Sonarr and Radarr. Keeps quality profiles optimized without manual tuning.

## Requires

| Variable | Purpose | Default |
|---|---|---|
| `RECYCLARR_SSH` | SSH host for the Docker host running recyclarr | — |
| `CLAWARR_HOST` | Service host (used by some status paths) | — |
| `RECYCLARR_DOCKER_CMD` | Docker binary override | `docker` |
| `RECYCLARR_CONTAINER` | Container name override | `recyclarr` |
| `DOCKER_CONFIG_BASE` | Docker config root for `recyclarr.yml` lookup (optional) | `/volume1/docker` |

Needs `ssh` and `docker` (local or remote) to reach the container; without `RECYCLARR_SSH` the script targets the local Docker daemon. See `references/companion-services.md` (Recyclarr section) for `recyclarr.yml` setup.

## Commands (`scripts/recyclarr.sh`)

```bash
recyclarr.sh status               # Check status & config
recyclarr.sh sync [instance]      # Sync profiles (all or specific: sonarr/radarr)
recyclarr.sh diff [instance]      # Preview changes without applying
recyclarr.sh profiles             # List available TRaSH profiles
recyclarr.sh qualities [app]      # List quality definitions
recyclarr.sh config               # Show current config
recyclarr.sh create-config        # Generate config template
recyclarr.sh logs [count]         # View recent logs
```

## Example prompts

- "Preview recyclarr changes before syncing"
- "Sync TRaSH quality profiles to Sonarr"
- "List available recyclarr quality profiles"
- "Show recyclarr's recent logs"

## Connectivity checklist

1. `RECYCLARR_SSH` reaches the Docker host (or local Docker daemon running)
2. Container `recyclarr` exists (or `RECYCLARR_CONTAINER` override matches)
3. `recyclarr.yml` present (`DOCKER_CONFIG_BASE/recyclarr/` when remote)
4. Sonarr/Radarr URLs and API keys set in `recyclarr.yml`
5. `recyclarr.sh status` reports the container running

## Destructive actions

`recyclarr.sh sync` overwrites Sonarr/Radarr quality profiles and custom formats with TRaSH Guides values (and downloads them from `raw.githubusercontent.com`). Preview first and sync only on explicit user request.
