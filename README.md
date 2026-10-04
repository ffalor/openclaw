# ffalor/openclaw

Personal [OpenClaw](https://openclaw.ai) plugin marketplace. Each directory
under `plugins/` is a separately installable bundle, listed in
`.claude-plugin/marketplace.json`.

## Plugins

| Plugin | What it is |
|--------|------------|
| `clawarr` | ClawARR media-stack skills; each directory under `plugins/clawarr/skills/` loads as an individual skill |

### `clawarr` skills

## Skills

| Skill | Configuration (`setup.sh` is in clawarr-core) | What it does |
|-------|---------------|--------------|
| `clawarr-core` | provides `scripts/setup.sh <service> <url>` | Guided setup/key discovery, service health, diagnostics, dashboard generation |
| `sonarr` | `scripts/setup.sh sonarr <url>` | TV library analytics, content management, search, queue |
| `radarr` | `scripts/setup.sh radarr <url>` | Movie library analytics, content management, search, queue |
| `lidarr` | `scripts/setup.sh lidarr <url>` | Music library analytics and search |
| `readarr` | `scripts/setup.sh readarr <url>` | Book library API workflows (authors, books, queue) |
| `prowlarr` | `scripts/setup.sh prowlarr <url>` | Indexer management, testing, cross-app sync |
| `seerr` | `scripts/setup.sh seerr <url>` | Request listing, approval, stats |
| `plex` | `scripts/setup.sh plex <url>` | Plex library stats and recently-added |
| `tautulli` | `scripts/setup.sh tautulli <url>` | Viewing analytics: streams, history, users, peak hours |
| `sabnzbd` | `scripts/setup.sh sabnzbd <url>` | Download queue, speed, pause/resume, history |
| `bazarr` | `scripts/setup.sh bazarr <url>` | Subtitle wanted/search/history/languages |
| `notifiarr` | `scripts/setup.sh notifiarr <url>` | Notification status, services, test alerts |
| `recyclarr` | `RECYCLARR_SSH` | TRaSH Guides quality-profile sync |
| `kometa` | `KOMETA_SSH` | Plex collections and overlays |
| `maintainerr` | `MAINTAINERR_URL` (no key) | Library cleanup rules and runs |
| `unpackerr` | `UNPACKERR_SSH` | Archive extraction monitoring |
| `trakt` | `TRAKT_CLIENT_ID`, `TRAKT_CLIENT_SECRET` | Trakt history/sync/scrobbling/lists + Traktarr/Retraktarr |
| `simkl` | `SIMKL_CLIENT_ID`, `SIMKL_CLIENT_SECRET` | Simkl auth, sync, watchlist |
| `letterboxd` | — (none required) | Letterboxd CSV export/import, profile reads |

Ported from [ffalor/clawarr-suite](https://github.com/ffalor/clawarr-suite),
split from one 20-key mega-skill so each skill loads on its own keys.

## Layout

```text
.claude-plugin/marketplace.json            # marketplace catalog (lists plugins by relative path)
plugins/clawarr/plugin.json         # Agent Plugins bundle manifest (single source of truth for the bundle)
plugins/clawarr/skills/<name>/SKILL.md      # one skill per directory; SKILL.md required
plugins/clawarr/skills/<name>/scripts/      # helper scripts (kept next to SKILL.md so relative refs hold)
plugins/clawarr/skills/<name>/references/   # reference docs
plugins/clawarr/skills/<name>/assets/       # skill icon, images
plugins/clawarr/skills/<name>/ui/           # setup page (in clawarr-core; reference copy, not loaded)
```

Why this shape: the repo root is a **marketplace**; each plugin lives in its own
directory under `plugins/`. Remote marketplaces may only reference plugins by
relative path inside the same repo, which is what `marketplace.json` does.
The bundle directory ships only `plugin.json` — **no** `openclaw.plugin.json`
and **no** `package.json` with `openclaw.extensions` (either flips detection to
native plugin) — so OpenClaw installs it as an Agent Plugins bundle
(`Format: bundle`, `Bundle format: agent`). The bundle stays content-only
(no in-process runtime, narrower trust boundary).

Scripts are verbatim copies of the upstream skill (some duplicated across
single-service skills where one script serves several apps — marked in each
SKILL.md); reference docs are per-service extracts. Each skill is
self-contained: no cross-skill file links. Upstream `openclaw.plugin.json`
is intentionally **not** copied (it would flip detection to native
plugin). Per-skill `requires` (bins/env) gating lives in each `SKILL.md`
frontmatter (`metadata.openclaw`), so every skill loads on its own keys.

## Install

```bash
# From the marketplace (this repo)
openclaw plugins marketplace list ffalor/openclaw
openclaw plugins install clawarr --marketplace ffalor/openclaw

# Local checkout (Gateway host path) — install the bundle dir directly
openclaw plugins install ./openclaw/plugins/clawarr
openclaw plugins install -l ./openclaw/plugins/clawarr   # link, for live editing

# Verify
openclaw plugins list
openclaw plugins inspect clawarr   # expect Format: bundle, Bundle format: agent
```

Mapped features are available in the next session (no Gateway restart needed
for install; restart if the Gateway was stopped).

## Configuration

Service configuration is managed per-service via the setup script. Each service
requires a base URL and API key:

### Setup per service

Run setup on the OpenClaw Gateway host to configure each service:

```bash
scripts/setup.sh <service> <url>
# Examples:
scripts/setup.sh sonarr https://sonarr.example.ts.net
scripts/setup.sh plex http://192.168.1.100:32400
scripts/setup.sh radarr http://192.168.1.100:7878
```

List available services:
```bash
scripts/setup.sh --list
```

### Configuration storage

- **HTTPS URLs** (`https://…`): The API key is stored securely in OpenClaw's
  secret store, bound to the service's hostname. Agents receive a sentinel value
  (`oc-sent-…`) and the Gateway's egress proxy substitutes the real key at HTTPS
  connection time. Requires `secrets.egressProxy.enabled: true` in OpenClaw
  configuration.

- **HTTP URLs** (`http://…`): The API key is stored plaintext in the Gateway's
  environment file at `~/.openclaw/.env` (or `$OPENCLAW_STATE_DIR/.env`). The
  egress proxy cannot proxy plain HTTP, so keys are stored locally.

- **Auto-detection**: If setup can auto-detect the key from the service (e.g.,
  `*arr` `/initialize.json`), it is stored automatically. Otherwise:
  - HTTPS: setup exits with code 3 and you supply the key via OpenClaw's
    `secrets` tool (`request` action — masked input, never enters chat)
  - HTTP: setup prompts for the key via hidden terminal input, or exits 4
    instructing you to manually add the line to `~/.openclaw/.env`

- **Service URLs** are always stored in `~/.openclaw/.env`. Restart the Gateway
  after setup: `openclaw gateway restart`

### Environment variables

Services are configured with:
- `<SERVICE>_URL` — base URL (e.g., `SONARR_URL=https://sonarr.example.ts.net`)
- `<SERVICE>_API_KEY` — API key (for *arr services)
- `PLEX_URL` + `PLEX_TOKEN` — Plex service

**Fallback** (when `<SERVICE>_URL` is unset):
- `CLAWARR_HOST` — constructs `http://$CLAWARR_HOST:<default-port>` for the service
- `CLAWARR_SCHEME` — optional scheme override (defaults to `http`)

Per-skill enablement (bundle installed, but only some skills active):

```json5
{
  skills: {
    entries: {
      "sonarr": { enabled: true }
    }
  }
}
```

## Adding another plugin

1. Create `plugins/<name>/plugin.json` (copy `plugins/clawarr/plugin.json`, change
   `name`/`description`/`version`) and put its skills in `plugins/<name>/skills/`.
2. Add an entry to `.claude-plugin/marketplace.json` with
   `"source": "./plugins/<name>"` and the same `version`.
3. Install: `openclaw plugins install <name> --marketplace ffalor/openclaw`.

## Adding a skill to clawarr

1. Copy the skill dir in: `plugins/clawarr/skills/<name>/SKILL.md` (+ helpers alongside it).
2. Keep every helper/reference the skill mentions **inside** `skills/<name>/`
   (bundle skill roots must stay inside the plugin root — boundary-checked).
3. Bump `version` in `plugins/clawarr/plugin.json` **and** the matching
   entry in `.claude-plugin/marketplace.json`, commit, then `openclaw plugins update clawarr`.

## Repo maintenance

Maintainers: read `.agents/skills/bundle-maintenance/SKILL.md` (project skill,
never bundled — it lives outside `skills/`). It encodes the Agent Plugins
conformance rules ([spec](https://agent-plugins.org/llms.txt)) and the
pre-commit validation for this repo.

## License

MIT — see [LICENSE](LICENSE). Skill content retains its upstream license/attribution.
