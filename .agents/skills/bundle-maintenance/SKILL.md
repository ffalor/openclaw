---
name: bundle-maintenance
description: >
  Maintain this Agent Plugins bundle repo (ffalor/openclaw). Use when adding a
  skill under skills/, editing plugin.json or .claude-plugin/plugin.json, or
  verifying bundle layout conformance before commit.
---

# Bundle maintenance

This repo is an [Agent Plugins 1.0.0](https://agent-plugins.org) bundle.
It intentionally ships **no** `openclaw.plugin.json`, so clients load it as a
content-only bundle (skills + MCP config, no in-process runtime).

**This skill is repo tooling, not bundle content.** It lives in
`.agents/skills/` (project agent skills), outside the `skills/` component root,
so no bundle client ever discovers or ships it.

## Source of truth

Before changing manifests or layout, read the spec:

- https://agent-plugins.org/llms.txt (full 1.0.0 spec; spec text is authoritative over the JSON schemas)
- Schemas: `https://agent-plugins.org/schemas/1.0.0/plugin.schema.json`, `.../mcp.schema.json`
  (canonical identifiers only — never fetch at load time; validate offline)

## Rules that have bitten before

1. **Root `plugin.json` is closed.** Only `$schema`, `name`, `version`,
   `description`, `author`, `homepage`, `repository`, `license`, `keywords`,
   `extensions`. Unknown top-level field = warn + ignore; any other schema
   violation (including missing `$schema` or `name`) = client MUST reject the
   whole plugin, no components load.
2. **`$schema` must be exactly**
   `https://agent-plugins.org/schemas/1.0.0/plugin.schema.json`.
3. **`name` constraints:** 1–64 chars, `a-z 0-9 - .` only, start/end
   alphanumeric, no `--` or `..`. Current: `ffalor-plugins`.
4. **`author` object** may contain only `name`/`email`/`url` strings.
5. **Skills:** one per immediate child dir of `skills/` containing `SKILL.md`.
   Never nest deeper — deeper `SKILL.md` files are NOT discovered. Dir name
   SHOULD match the `name:` frontmatter in `SKILL.md`.
6. **Keep each skill self-contained.** Everything `SKILL.md` references
   (`scripts/...`, `references/...`) must live inside `skills/<name>/` —
   clients boundary-check paths against the plugin root.
7. **No `mcp.json` unless a skill needs MCP servers.** Absent location is not
   an error. If added: closed schema, required `$schema` (must match the
   `plugin.json` version), `mcpServers` object; `command` is a single token
   (bare name or `./`-relative); `${PLUGIN_ROOT}`/`${PLUGIN_DATA}` expand in
   `args`/`env`/`cwd` only; never put secrets in `env`/`headers`.
8. **Never add `openclaw.plugin.json`.** OpenClaw checks native manifest
   first — its presence flips detection from bundle to native plugin.
9. **Dual-manifest setup:** `.claude-plugin/plugin.json` (Claude bundle,
   wins OpenClaw detection) + root `plugin.json` (Agent Plugins portable
   core) describe the same `skills/` dir. Bump `version` in both on change.
   Client-specific knobs belong under root `extensions.<reverse-domain>`,
   never as new top-level fields.

## Adding a skill

1. Copy in: `skills/<name>/SKILL.md` + helpers alongside (`scripts/`, `references/`).
2. Confirm `SKILL.md` frontmatter has `name:` (= dir name) and `description:`.
3. Confirm all relative refs resolve inside `skills/<name>/`.
4. Run validation below, bump both manifest versions, commit.

## Validation (run before commit)

```bash
export D="$(git rev-parse --show-toplevel)"
python3 - <<'EOF'
import json, re, os
D = os.environ.get("D", ".")
m = json.load(open(f"{D}/plugin.json"))
allowed = {"$schema","name","version","description","author","homepage","repository","license","keywords","extensions"}
assert set(m) <= allowed, f"unknown fields: {set(m)-allowed}"
assert m["$schema"] == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
assert re.fullmatch(r'[a-z0-9]+(?:[.-][a-z0-9]+)*', m["name"]) and len(m["name"]) <= 64
assert set(m.get("author", {})) <= {"name","email","url"}
for d in os.listdir(f"{D}/skills"):
    p = f"{D}/skills/{d}/SKILL.md"
    assert os.path.isfile(p), f"skills/{d} has no SKILL.md"
print("manifest + discovery OK:", m["name"], m["version"])
EOF
for f in skills/*/scripts/*.sh; do bash -n "$f" || exit 1; done && echo "scripts OK"
git status --short
```

Then install-test on a machine with the OpenClaw CLI:

```bash
openclaw plugins install -l <repo-path>
openclaw plugins inspect ffalor-plugins   # expect Format: bundle
```
