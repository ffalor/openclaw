---
name: clawarr-core
description: "Bootstrap a self-hosted media stack: guided setup, API key discovery, service health checks, troubleshooting, and dashboard generation."
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# ClawARR Core

Bootstrap skill for a self-hosted *arr media stack. Handles guided setup and API key discovery, service health checks, troubleshooting, and dashboard generation. Deeper library analytics, content management, and tracker integrations live in companion skills.

## Configuration

Each service has a base URL and a key:

| Variable | Purpose |
|----------|---------|
| `<SERVICE>_URL` | Base URL, e.g. `SONARR_URL=https://sonarr.example.ts.net` or `http://192.168.1.100:8989` |
| `<SERVICE>_API_KEY` | API key (`SONARR_API_KEY`, `RADARR_API_KEY`, `LIDARR_API_KEY`, `READARR_API_KEY`, `PROWLARR_API_KEY`, `BAZARR_API_KEY`, `SEERR_API_KEY`, `TAUTULLI_API_KEY`, `SABNZBD_API_KEY`, `NOTIFIARR_API_KEY`) |
| `PLEX_URL` / `PLEX_TOKEN` | Plex base URL and token |
| `CLAWARR_HOST` | Optional fallback for any service without a `<SERVICE>_URL`: `${CLAWARR_SCHEME:-http}://$CLAWARR_HOST:<port>`, with `<SERVICE>_PORT` overriding the standard port |

Every key is optional — scripts skip services that have no key or URL.

`dashboard.sh` also needs `bc` (it is not gated on it, so the skill loads without `bc`, but the dashboard fails if it is missing); everything else works without it.

### Setup (run by the agent on the OpenClaw Gateway host)

Configure one service at a time with its URL. The URL scheme decides where the key goes:

```bash
scripts/setup.sh --list
scripts/setup.sh sonarr https://sonarr.example.ts.net
scripts/setup.sh radarr http://192.168.1.100:7878
```

- **`https://` → OpenClaw secret store.** The key is stored as a protected secret bound to the URL's host. Commands then see only an `oc-sent-…` sentinel in `$SONARR_API_KEY`, and the Gateway's secret egress proxy swaps in the real key at HTTPS egress to that host. Requires `secrets.egressProxy.enabled: true` (setup checks).
  - If setup can read the key itself (*arr `/initialize.json`), it pipes it straight into `openclaw secrets store set` — it is never printed.
  - Otherwise it exits **3** and prints a `SECRETS_REQUEST {…}` line. Call the `secrets` tool with `action: "request"` and that `name`, `allowedHosts` and `reason`; the user types the key into a masked prompt. Never ask for the key in chat.
- **`http://` → plaintext in `~/.openclaw/.env`** (`$OPENCLAW_STATE_DIR/.env`). OpenClaw's egress proxy refuses plain HTTP, so store secrets cannot work there. If the key can't be auto-detected, setup exits **4**: ask the user to add the printed line to that file themselves, run `setup.sh` in a terminal, or serve the app over HTTPS.
- `<SERVICE>_URL` always goes in `~/.openclaw/.env`, which the Gateway reads at start: have the user restart it (`openclaw gateway restart`) after setup. Store changes reach new agent runs, not the current one. Verify in a new run with `scripts/status.sh`.
- One key name lives in exactly one place. Setup removes a plaintext `.env` copy when it stores a secret, and warns when an http setup finds a store entry of the same name.

### Calling services

Use `$<SERVICE>_URL` with `$<SERVICE>_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print a key: an `oc-sent-…` value only works through the egress proxy, over HTTPS, to its allowed host. A 401 means the key or its host binding is wrong — rerun `setup.sh`, don't try other variables.

## Quick Start

```bash
scripts/setup.sh sonarr <url>  # once per service
scripts/status.sh              # Health check all services
scripts/discover.sh <host>     # Scan a host for services on standard http ports
scripts/diagnose.sh            # Automated troubleshooting
scripts/dashboard.sh           # Generate HTML dashboard
```

## Core Operations

- **`setup.sh <service> <url>`** — Configure one service: reachability, key auto-detection, key storage (secret store for https, `~/.openclaw/.env` for http) and verification.
- **`discover.sh <host>`** — Scan a host for *arr services on their standard HTTP ports and report which respond.
- **`status.sh`** — Health check all configured services (skips services with no key or URL; reports `HTTP 401 (API key rejected)` vs `unreachable`).
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
- Seerr: 5055
- Plex: 32400
- Tautulli: 8181
- SABnzbd: 8081
- Notifiarr: 5454
- Maintainerr: 6246
- FlareSolverr: 8191
- Homarr: 7575

## API Key Discovery

For reference only. `setup.sh` already does Method 1 without printing the key. Agents must not run these by hand: their output would put the key into the chat transcript. Use `setup.sh`, or the `secrets` tool for keys it can't detect.

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

`references/prompts.md` and `references/setup-guide.md` are verbatim upstream and mention service scripts (`library.sh`, `analytics.sh`, `downloads.sh`, `requests.sh`, `manage.sh`, `queue.sh`, `search.sh`, `subtitles.sh`, `indexers.sh`) that are **not** in this skill — they live in the matching service skill (sonarr, radarr, plex/tautulli, sabnzbd, seerr, bazarr, prowlarr). This skill only ships `setup.sh`, `discover.sh`, `status.sh`, `diagnose.sh`, and `dashboard.sh`.

## Security & compatibility notes

- All API calls target the configured `<SERVICE>_URL`s (or `CLAWARR_HOST`); keys come from the OpenClaw secret store (https) or `~/.openclaw/.env` (http), nothing is embedded or sent to third parties.
- Scripts are Bash 3.2 compatible (macOS default bash) and need only `bash`, `curl`, `jq`.

## Example Prompts

- "Set up my media stack on 192.168.1.100"
- "Are all my *arr services healthy?"
- "Diagnose why my downloads aren't importing"
- "Generate a dashboard of my media stack"
