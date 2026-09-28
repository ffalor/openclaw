# ffalor-plugins

Personal [OpenClaw](https://openclaw.ai) skill bundle. Install the whole repo
as one bundle; each directory under `skills/` loads as an individual skill.

## Skills

| Skill | Source | What it does |
|-------|--------|--------------|
| `clawarr-suite` | [`skills/clawarr-suite/`](skills/clawarr-suite/) | Unified control for self-hosted media stacks (Sonarr, Radarr, Prowlarr, Plex, Tautulli, SABnzbd, + companions). Ported from [ffalor/clawarr-suite](https://github.com/ffalor/clawarr-suite). |

## Layout

```text
plugin.json                  # Agent Plugins bundle manifest (single source of truth)
skills/<name>/SKILL.md       # one skill per directory; SKILL.md required
skills/<name>/scripts/       # skill helper scripts (kept next to SKILL.md so relative refs hold)
skills/<name>/references/    # skill reference docs
skills/<name>/assets/        # skill icon, images (Agent Skills standard dir)
skills/<name>/ui/            # clawarr-suite setup page (reference copy; not loaded by OpenClaw)
mcp.json                     # only when something needs MCP servers (absent = fine, not an error)
```

Why this shape: bundle detection checks `openclaw.plugin.json` (native) first,
then client markers, then root `plugin.json` — which is what this repo ships,
so OpenClaw installs it as an Agent Plugins bundle (`Format: bundle`,
`Bundle format: agent`). This repo deliberately ships **no**
`openclaw.plugin.json` and **no** `.claude-plugin/`, so there is exactly one
manifest and no competing detection path. The bundle stays content-only
(no in-process runtime, narrower trust boundary).

`SKILL.md`, `scripts/`, and `references/` are verbatim copies of the upstream
skill; internal `scripts/...` / `references/...` paths keep working because the
relative layout is preserved inside `skills/clawarr-suite/`. `openclaw.plugin.json`
from upstream is intentionally **not** copied (it would flip detection to native
plugin). Its `requires` (bins/env) and `security` declarations live on in the
skill frontmatter (`metadata.openclaw`) in `SKILL.md`, which is what gates skill
eligibility for bundles.

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

Skill eligibility comes from `SKILL.md` frontmatter (`bins: bash, curl, jq`;
all env keys optional — the skill degrades gracefully). Set whichever keys you
use; see [`skills/clawarr-suite/.env.example`](skills/clawarr-suite/.env.example)
for endpoint overrides and the full key list in `SKILL.md`.

Per-skill enablement (bundle installed, but only some skills active):

```json5
{
  skills: {
    entries: {
      "clawarr-suite": { enabled: true }
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
