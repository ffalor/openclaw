---
name: unpackerr
description: Monitor Unpackerr archive extraction for *arr download queues via unpackerr.sh.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["UNPACKERR_SSH"]}}}
---

# Unpackerr

Archive-extraction monitoring for Sonarr/Radarr/Lidarr download queues. Unpackerr watches *arr queues, extracts completed archives (.rar, .zip), and notifies the *arr app to retry import — fully automated, this skill observes it.

## Requires

| Variable | Purpose | Default |
|---|---|---|
| `UNPACKERR_SSH` | SSH host for the Docker host running unpackerr | — |
| `UNPACKERR_DOCKER_CMD` | Docker binary override | `docker` |
| `UNPACKERR_CONTAINER` | Container name override | `unpackerr` |
| `DOCKER_CONFIG_BASE` | Docker config root (optional, unused here) | `/volume1/docker` |

Needs `ssh` and `docker` (local or remote) to reach the container; without `UNPACKERR_SSH` the script targets the local Docker daemon. The container itself is configured via `UN_SONARR_*` / `UN_RADARR_*` env vars — see `references/companion-services.md` (Unpackerr section).

## Commands (`scripts/unpackerr.sh`)

```bash
unpackerr.sh status               # Check status & config
unpackerr.sh activity             # Recent extraction activity
unpackerr.sh errors               # Recent errors/warnings
unpackerr.sh config               # Show configuration
unpackerr.sh logs [count]         # View recent logs
unpackerr.sh restart              # Restart container
```

## Example prompts

- "Is Unpackerr running and extracting?"
- "Show recent Unpackerr extraction activity"
- "Any Unpackerr errors in the last hour?"
- "Restart the Unpackerr container"

## Connectivity checklist

1. `UNPACKERR_SSH` reaches the Docker host (or local Docker daemon running)
2. Container `unpackerr` exists (or `UNPACKERR_CONTAINER` override matches)
3. `UN_SONARR_*` / `UN_RADARR_*` env vars set on the container
4. Download paths in container config match the *arr apps
5. `unpackerr.sh status` reports the container running

## Destructive actions

`unpackerr.sh restart` restarts the container. Run it only on explicit user request.
