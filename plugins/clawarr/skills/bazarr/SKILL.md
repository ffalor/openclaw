---
name: bazarr
description: Manage Bazarr subtitles — find missing subtitles, browse history, and trigger searches.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Bazarr

Subtitle management via Bazarr. Find episodes and movies missing subtitles,
browse recent subtitle downloads, trigger manual searches, and list configured
languages. See `references/api-endpoints.md` for the raw API.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `BAZARR_URL` | Bazarr base URL, e.g. `https://bazarr.example.ts.net` or `http://192.168.1.100:6767` |
| `BAZARR_API_KEY` | API key (Settings → General → API Key) |
| `CLAWARR_HOST` | Optional fallback when `BAZARR_URL` is unset: `http://$CLAWARR_HOST:6767` (`CLAWARR_SCHEME`, `BAZARR_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh bazarr <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$BAZARR_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Bazarr API: `$BAZARR_URL/api`, auth header `X-API-Key: $BAZARR_API_KEY`.

**Calling the API yourself:** always use `$BAZARR_URL` with `$BAZARR_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

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

1. Host reachable: `curl -s $BAZARR_URL/api/system/status -H "X-API-Key: $BAZARR_API_KEY"`
2. `BAZARR_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Bazarr instance; run `scripts/setup.sh bazarr <url>` from the clawarr-core skill to (re)configure it.
3. `BAZARR_API_KEY` matches Settings → General in the Bazarr web UI.
4. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
5. Port `6767` is open on the host firewall and the container is running (`docker logs bazarr`).
6. Container logs show no errors: `docker logs bazarr --tail 50`

## References

- `references/api-endpoints.md` — Bazarr API v1 reference (episodes, movies, providers)
