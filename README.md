# ffalor-plugins

Personal [OpenClaw](https://openclaw.ai) skill bundle. Install the whole repo
as one bundle; each directory under `plugins/ffalor-plugins/skills/` loads as an individual skill.

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
.claude-plugin/marketplace.json            # marketplace catalog (lists plugins by relative path)
plugins/ffalor-plugins/plugin.json         # Agent Plugins bundle manifest (single source of truth for the bundle)
plugins/ffalor-plugins/skills/<name>/SKILL.md      # one skill per directory; SKILL.md required
plugins/ffalor-plugins/skills/<name>/scripts/      # helper scripts (kept next to SKILL.md so relative refs hold)
plugins/ffalor-plugins/skills/<name>/references/   # reference docs
plugins/ffalor-plugins/skills/<name>/assets/       # skill icon, images
plugins/ffalor-plugins/skills/<name>/ui/           # setup page (in clawarr-core; reference copy, not loaded)
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
openclaw plugins install ffalor-plugins --marketplace ffalor/openclaw

# Local checkout (Gateway host path) — install the bundle dir directly
openclaw plugins install ./openclaw/plugins/ffalor-plugins
openclaw plugins install -l ./openclaw/plugins/ffalor-plugins   # link, for live editing

# Verify
openclaw plugins list
openclaw plugins inspect ffalor-plugins   # expect Format: bundle, Bundle format: agent
```

Mapped features are available in the next session (no Gateway restart needed
for install; restart if the Gateway was stopped).

## Configure

Each skill declares its own required keys in `SKILL.md` frontmatter
(only the bins and env vars its scripts hard-require: usually `bash, curl, jq`
plus 0–2 env vars; kometa/recyclarr/unpackerr need `docker` *or* `ssh` via
`anyBins`, and lidarr also needs `bc`) and loads as soon as those exist — set
only what you use. See
[`plugins/ffalor-plugins/skills/clawarr-core/.env.example`](plugins/ffalor-plugins/skills/clawarr-core/.env.example)
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

1. Copy the skill dir in: `plugins/ffalor-plugins/skills/<name>/SKILL.md` (+ helpers alongside it).
2. Keep every helper/reference the skill mentions **inside** `skills/<name>/`
   (bundle skill roots must stay inside the plugin root — boundary-checked).
3. Bump `version` in `plugins/ffalor-plugins/plugin.json` **and** the matching
   entry in `.claude-plugin/marketplace.json`, commit, then `openclaw plugins update ffalor-plugins`.

## Repo maintenance

Maintainers: read `.agents/skills/bundle-maintenance/SKILL.md` (project skill,
never bundled — it lives outside `skills/`). It encodes the Agent Plugins
conformance rules ([spec](https://agent-plugins.org/llms.txt)) and the
pre-commit validation for this repo.

## License

MIT — see [LICENSE](LICENSE). Skill content retains its upstream license/attribution.
