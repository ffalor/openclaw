---
name: bazarr
description: Manage Bazarr subtitles — find missing subtitles, browse history, and trigger searches.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST", "BAZARR_KEY"]}}}
---

# Bazarr

Subtitle management via Bazarr. Find episodes and movies missing subtitles,
browse recent subtitle downloads, trigger manual searches, and list configured
languages. See `references/api-endpoints.md` for the raw API.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Required | Purpose |
|----------|----------|---------|
| `CLAWARR_HOST` | Yes | Host IP/hostname of the Bazarr instance (port 6767) |
| `BAZARR_KEY` | Yes | Bazarr API key (Settings → General → API Key) |

```bash
export CLAWARR_HOST=192.168.1.100
export BAZARR_KEY=pqr678...
```

## Scripts

### Subtitle management (`subtitles.sh`)

```bash
scripts/subtitles.sh wanted              # Missing subtitles (episodes + movies)
scripts/subtitles.sh history [count]     # Recent subtitle downloads (default: 20)
scripts/subtitles.sh search <type> <id>  # Manual subtitle search (type: series|movie)
scripts/subtitles.sh languages           # Configured languages
```

## Common Workflows

```bash
# What's missing subtitles?
scripts/subtitles.sh wanted

# Trigger a manual search
scripts/subtitles.sh search series 456
scripts/subtitles.sh search movie 789

# Recent downloads and configured languages
scripts/subtitles.sh history 20
scripts/subtitles.sh languages
```

## Example Prompts

- "What subtitles are missing?"
- "Show recent subtitle downloads"
- "Search for subtitles for series ID 456"
- "What languages are configured for subtitles?"

## Troubleshooting

Connectivity checklist:

1. Host reachable: `curl -s http://$CLAWARR_HOST:6767/api/system/status -H "X-API-Key: $BAZARR_KEY"`
2. `CLAWARR_HOST` is set and points at the Bazarr machine (no scheme, no port).
3. `BAZARR_KEY` matches Settings → General in the Bazarr web UI.
4. Port `6767` is open on the host firewall and the container is running (`docker logs bazarr`).
5. Container logs show no errors: `docker logs bazarr --tail 50`

## References

- `references/api-endpoints.md` — Bazarr API v1 reference (episodes, movies, providers)
