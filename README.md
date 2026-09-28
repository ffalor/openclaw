# ffalor-plugins

Personal [OpenClaw](https://openclaw.ai) skill bundle. Install the whole repo
as one bundle; each directory under `skills/` loads as an individual skill.

## Skills

| Skill | Keys to load | What it does |
|-------|--------------|--------------|
| `clawarr-core` | `CLAWARR_HOST` | Guided setup/key discovery, service health, diagnostics, dashboard generation |
| `sonarr` | `CLAWARR_HOST`, `SONARR_KEY` | TV library analytics, content management, search, queue |
| `radarr` | `CLAWARR_HOST`, `RADARR_KEY` | Movie library analytics, content management, search, queue |
| `lidarr` | `CLAWARR_HOST`, `LIDARR_KEY` | Music library analytics and search |
| `readarr` | `CLAWARR_HOST`, `READARR_KEY` | Book library API workflows (authors, books, queue) |
| `prowlarr` | `CLAWARR_HOST`, `PROWLARR_KEY` | Indexer management, testing, cross-app sync |
| `overseerr` | `CLAWARR_HOST`, `OVERSEERR_KEY` | Request listing, approval, stats |
| `plex` | `CLAWARR_HOST`, `PLEX_TOKEN` | Plex library stats and recently-added |
| `tautulli` | `CLAWARR_HOST`, `TAUTULLI_KEY` | Viewing analytics: streams, history, users, peak hours |
| `sabnzbd` | `CLAWARR_HOST`, `SABNZBD_KEY` | Download queue, speed, pause/resume, history |
| `bazarr` | `CLAWARR_HOST`, `BAZARR_KEY` | Subtitle wanted/search/history/languages |
| `notifiarr` | `CLAWARR_HOST` | Notification status, services, test alerts (`NOTIFIARR_KEY` for writes) |
| `recyclarr` | `RECYCLARR_SSH` | TRaSH Guides quality-profile sync |
| `kometa` | `KOMETA_SSH` | Plex collections and overlays |
| `maintainerr` | `CLAWARR_HOST` | Library cleanup rules and runs |
| `unpackerr` | `UNPACKERR_SSH` | Archive extraction monitoring |
| `trakt` | `TRAKT_CLIENT_ID`, `TRAKT_CLIENT_SECRET` | Trakt history/sync/scrobbling/lists + Traktarr/Retraktarr |
| `simkl` | `SIMKL_CLIENT_ID`, `SIMKL_CLIENT_SECRET` | Simkl auth, sync, watchlist |
| `letterboxd` | — (none required) | Letterboxd CSV export/import, profile reads |

Ported from [ffalor/clawarr-suite](https://github.com/ffalor/clawarr-suite),
split from one 20-key mega-skill so each skill loads on its own keys.

## Layout

```text
plugin.json                  # Agent Plugins bundle manifest (single source of truth)
skills/<name>/SKILL.md       # one skill per directory; SKILL.md required
skills/<name>/scripts/       # skill helper scripts (kept next to SKILL.md so relative refs hold)
skills/<name>/references/    # skill reference docs
skills/<name>/assets/        # skill icon, images (Agent Skills standard dir)
skills/<name>/ui/            # setup page (in clawarr-core; reference copy, not loaded)
mcp.json                     # only when something needs MCP servers (absent = fine, not an error)
```

Why this shape: bundle detection checks `openclaw.plugin.json` (native) first,
then client markers, then root `plugin.json` — which is what this repo ships,
so OpenClaw installs it as an Agent Plugins bundle (`Format: bundle`,
`Bundle format: agent`). This repo deliberately ships **no**
`openclaw.plugin.json` and **no** `.claude-plugin/`, so there is exactly one
manifest and no competing detection path. The bundle stays content-only
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
# From git (bundle auto-detected on install)
openclaw plugins install git:github.com/ffalor/openclaw

# Local checkout (Gateway host path)
openclaw plugins install ./openclaw
openclaw plugins install -l ./openclaw   # link instead of copy, for live editing

# Verify
openclaw plugins list
openclaw plugins inspect ffalor-plugins   # expect Format: bundle, Bundle format: agent
```

Mapped features are available in the next session (no Gateway restart needed
for install; restart if the Gateway was stopped).

## Configure

Each skill declares its own required keys in `SKILL.md` frontmatter
(`bins: bash, curl, jq` plus 0–4 env vars) and loads as soon as its keys
exist — set only what you use. See
[`skills/clawarr-core/.env.example`](skills/clawarr-core/.env.example)
for endpoint overrides.

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

## Adding another skill

1. Copy the skill dir in: `skills/<name>/SKILL.md` (+ helpers alongside it).
2. Keep every helper/reference the skill mentions **inside** `skills/<name>/`
   (bundle skill roots must stay inside the plugin root — boundary-checked).
3. Bump `version` in `plugin.json`, commit, then `openclaw plugins update ffalor-plugins`.

## Repo maintenance

Maintainers: read `.agents/skills/bundle-maintenance/SKILL.md` (project skill,
never bundled — it lives outside `skills/`). It encodes the Agent Plugins
conformance rules ([spec](https://agent-plugins.org/llms.txt)) and the
pre-commit validation for this repo.

## License

MIT — see [LICENSE](LICENSE). Skill content retains its upstream license/attribution.
