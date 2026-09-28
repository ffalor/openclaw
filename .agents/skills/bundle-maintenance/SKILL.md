---
name: bundle-maintenance
description: >
  Maintain this Agent Plugins bundle repo (ffalor/openclaw). Use when adding a
  skill under plugins/clawarr/skills/, editing plugin.json or
  .claude-plugin/marketplace.json, or
  verifying bundle layout conformance before commit.
---

# Bundle maintenance

This repo is a marketplace (`.claude-plugin/marketplace.json` at the root)
whose plugins each live in `plugins/<name>/` as an
[Agent Plugins 1.0.0](https://agent-plugins.org) bundle (currently `clawarr`).
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

1. **The bundle's `plugin.json` is closed.** Only `$schema`, `name`, `version`,
   `description`, `author`, `homepage`, `repository`, `license`, `keywords`,
   `extensions`. Unknown top-level field = warn + ignore; any other schema
   violation (including missing `$schema` or `name`) = client MUST reject the
   whole plugin, no components load.
2. **`$schema` must be exactly**
   `https://agent-plugins.org/schemas/1.0.0/plugin.schema.json`.
3. **`name` constraints:** 1–64 chars, `a-z 0-9 - .` only, start/end
   alphanumeric, no `--` or `..`. Current: `clawarr`.
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
9. **Single manifest per bundle.** Inside each `plugins/<name>/`,
   `plugin.json` is the only manifest — no `openclaw.plugin.json` or
   `package.json` with `openclaw.extensions` (flip detection to native), no
   `.claude-plugin/` (would win detection as Claude format). The root
   `.claude-plugin/` holds only `marketplace.json`. Bump `version` in the
   bundle `plugin.json` **and** its marketplace entry together. Every
   `plugins/<name>/` must have a marketplace entry, and vice versa. Client-specific
   knobs belong under `extensions.<reverse-domain>`, never as new top-level
   fields.
10. **Marketplace sources are relative paths only** (`./plugins/<name>`);
    remote marketplaces reject git/GitHub/HTTP/absolute sources.

## Adding a skill

1. Copy in: `plugins/clawarr/skills/<name>/SKILL.md` + helpers alongside (`scripts/`, `references/`).
2. Confirm `SKILL.md` frontmatter has `name:` (= dir name) and `description:`.
3. Confirm all relative refs resolve inside `skills/<name>/`.
4. Run validation below, bump both manifest versions, commit.

## Validation (run before commit)

```bash
export D="$(git rev-parse --show-toplevel)"
python3 - <<'EOF'
import json, re, os
D = os.environ.get("D", ".")
mk = json.load(open(f"{D}/.claude-plugin/marketplace.json"))
dirs = sorted(os.listdir(f"{D}/plugins"))
assert sorted(e["name"] for e in mk["plugins"]) == dirs, "marketplace entries != plugins/ dirs"
for e in mk["plugins"]:
  B = f"{D}/plugins/{e['name']}"
  assert e["source"] == f"./plugins/{e['name']}", e["source"]
  m = json.load(open(f"{B}/plugin.json"))
  assert m["name"] == e["name"] and e.get("version") == m["version"], f"{e['name']}: marketplace entry out of sync"
  assert not os.path.exists(f"{B}/package.json") and not os.path.exists(f"{B}/openclaw.plugin.json")
  allowed = {"$schema","name","version","description","author","homepage","repository","license","keywords","extensions"}
  assert set(m) <= allowed, f"unknown fields: {set(m)-allowed}"
  assert m["$schema"] == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
  assert re.fullmatch(r'[a-z0-9]+(?:[.-][a-z0-9]+)*', m["name"]) and len(m["name"]) <= 64
  assert set(m.get("author", {})) <= {"name","email","url"}
  for d in os.listdir(f"{B}/skills"):
    assert os.path.isfile(f"{B}/skills/{d}/SKILL.md"), f"{e['name']}/skills/{d} has no SKILL.md"
  print("OK:", m["name"], m["version"])
EOF
for f in plugins/*/skills/*/scripts/*.sh; do bash -n "$f" || exit 1; done && echo "scripts OK"
git status --short
```

Then install-test on a machine with the OpenClaw CLI:

```bash
openclaw plugins install -l <repo-path>/plugins/clawarr
openclaw plugins marketplace list <repo-path>   # marketplace sees clawarr
openclaw plugins inspect clawarr   # expect Format: bundle, Bundle format: agent
```
