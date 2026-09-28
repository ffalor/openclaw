---
name: clawarr-core
description: "Bootstrap a self-hosted media stack: guided setup, API key discovery, service health checks, troubleshooting, and dashboard generation."
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST"]}}}
---

# ClawARR Core

Bootstrap skill for a self-hosted *arr media stack. Handles guided setup and API key discovery, service health checks, troubleshooting, and dashboard generation. Deeper library analytics, content management, and tracker integrations live in companion skills.

## Requires

| Variable | Required | Purpose |
|----------|----------|---------|
| `CLAWARR_HOST` | Yes | LAN host or hostname of the *arr services |
| `SONARR_KEY` | No (unset-ok) | Sonarr API key |
| `RADARR_KEY` | No (unset-ok) | Radarr API key |
| `LIDARR_KEY` | No (unset-ok) | Lidarr API key |
| `READARR_KEY` | No (unset-ok) | Readarr API key |
| `PROWLARR_KEY` | No (unset-ok) | Prowlarr API key |
| `BAZARR_KEY` | No (unset-ok) | Bazarr API key |
| `OVERSEERR_KEY` | No (unset-ok) | Overseerr API key |
| `PLEX_TOKEN` | No (unset-ok) | Plex authentication token |
| `TAUTULLI_KEY` | No (unset-ok) | Tautulli API key |
| `SABNZBD_KEY` | No (unset-ok) | SABnzbd API key |
| `NOTIFIARR_KEY` | No (unset-ok) | Notifiarr API key |
| `SABNZBD_PORT` | No (unset-ok) | SABnzbd HTTP port (default `8081`) |
| `TAUTULLI_PORT` | No (unset-ok) | Tautulli HTTP port (default `8181`) |
| `PLEX_HOST` | No (unset-ok) | Plex server host (defaults to `CLAWARR_HOST`) |
| `PLEX_SCHEME` | No (unset-ok) | Plex URL scheme, `http` or `https` (default `http`) |
| `PLEX_PORT` | No (unset-ok) | Plex port (default `32400`) |
| `CLAWARR_SCHEME` | No (unset-ok) | Scheme for Sonarr/Radarr/Readarr/Prowlarr/Overseerr/SABnzbd/Tautulli (default `http`) |
| `SONARR_PORT` | No (unset-ok) | Sonarr HTTP port (default `8989`) |
| `RADARR_PORT` | No (unset-ok) | Radarr HTTP port (default `7878`) |
| `READARR_PORT` | No (unset-ok) | Readarr HTTP port (default `8787`) |
| `PROWLARR_PORT` | No (unset-ok) | Prowlarr HTTP port (default `9696`) |
| `OVERSEERR_PORT` | No (unset-ok) | Overseerr HTTP port (default `5055`) |

All service keys are optional — the skill degrades gracefully when a key is absent (unconfigured services are skipped, not errors).

Optional helpers: `bc` and `sed` are used for math and text processing in `dashboard.sh`; everything else works without them.

## Quick Start

First-time setup (recommended):

```bash
scripts/setup.sh <host-ip-or-hostname>
```

Discovers services, grabs API keys, verifies connections, and outputs your config.

Common operations:

```bash
scripts/status.sh              # Health check all services
scripts/discover.sh            # Rescan host for *arr services
scripts/diagnose.sh            # Automated troubleshooting
scripts/dashboard.sh           # Generate HTML dashboard
```

## Core Operations

- **`setup.sh <host>`** — Guided setup wizard with auto-discovery. Discovers services on the host, fetches API keys, verifies connections, and prints the export block for your shell.
- **`discover.sh`** — Scan `CLAWARR_HOST` for *arr services and report which ports respond.
- **`status.sh`** — Health check all configured services (skips services with no key set).
- **`diagnose.sh`** — Automated troubleshooting: checks container health, connectivity, paths, permissions, disk space, and queue state.

## Dashboard Generation

Generate a self-contained HTML dashboard:

```bash
scripts/dashboard.sh [output_file]
```

Creates a dark-themed dashboard with system health, download activity, library statistics, recent activity, viewing analytics, and disk usage. Output defaults to `clawarr-dashboard.html` (open in any browser). See `references/dashboard-templates.md` for the HTML/CSS templates and `ui/index.html` for the companion web UI.

## Standard Ports

- Sonarr: 8989
- Radarr: 7878
- Lidarr: 8686
- Readarr: 8787
- Prowlarr: 9696
- Bazarr: 6767
- Overseerr: 5055
- Plex: 32400
- Tautulli: 8181
- SABnzbd: 8081
- Notifiarr: 5454
- Maintainerr: 6246
- FlareSolverr: 8191
- Homarr: 7575

## API Key Discovery

### Method 1: /initialize.json (easiest)

Most *arr apps expose the API key at a public endpoint:

```bash
curl -s http://HOST:7878/initialize.json | jq -r '.apiKey'
```

For older versions (v3):

```bash
curl -s http://HOST:7878/initialize.js | grep -o "apiKey: '[^']*'" | cut -d"'" -f2
```

### Method 2: Config files

Docker/Unraid/Synology: `/config/config.xml` (inside the container):

```bash
grep '<ApiKey>' /path/to/config.xml | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/'
```

### Method 3: Web UI

Settings → General → Security → API Key.

### Plex token

From the Plex Web UI: open any media item → "Get Info" → "View XML"; the URL contains `X-Plex-Token=...`. Or authenticate directly:

```bash
curl -u "username:password" -X POST \
  'https://plex.tv/users/sign_in.json' \
  -H "X-Plex-Client-Identifier: <unique-id>"
```

### Tautulli API key

Settings → Web Interface → API → API Key.

### SABnzbd API key

Config → General → Security → API Key.

## Troubleshooting

Start with the automated diagnosis:

```bash
scripts/diagnose.sh
```

Common causes for stuck imports: stale Docker mounts (restart containers), download-client/*arr path mapping mismatches (Settings → Download Clients → Remote Path Mappings), permissions (*arr app can't read the download directory), and category mismatches. See `references/common-issues.md` for the full guide.

## Reference Documentation

- **`references/setup-guide.md`** — Platform-specific installation (Docker, Unraid, Synology, native).
- **`references/api-endpoints.md`** — Authentication, common request patterns, Homarr notes, error responses.
- **`references/common-issues.md`** — Troubleshooting guide with solutions.
- **`references/dashboard-templates.md`** — HTML/CSS templates for dashboards.
- **`references/prompts.md`** — Suggested natural-language prompts.

`references/prompts.md` and `references/setup-guide.md` are verbatim upstream and mention service scripts (`library.sh`, `analytics.sh`, `downloads.sh`, `requests.sh`, `manage.sh`, `queue.sh`, `search.sh`, `subtitles.sh`, `indexers.sh`) that are **not** in this skill — they live in the matching service skill (sonarr, radarr, plex/tautulli, sabnzbd, overseerr, bazarr, prowlarr). This skill only ships `setup.sh`, `discover.sh`, `status.sh`, `diagnose.sh`, and `dashboard.sh`.

## Security & compatibility notes

- All API calls target the user-provided `CLAWARR_HOST` (typically LAN/NAS); keys come from env vars, nothing is embedded or sent to third parties.
- Scripts are Bash 3.2 compatible (macOS default bash) and need only `bash`, `curl`, `jq`.

## Example Prompts

- "Set up my media stack on 192.168.1.100"
- "Are all my *arr services healthy?"
- "Diagnose why my downloads aren't importing"
- "Generate a dashboard of my media stack"
