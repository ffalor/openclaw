---
name: maintainerr
description: Rule-based Plex library cleanup management (rules, collections, runs) via maintainerr.sh.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Maintainerr

Automated Plex library cleanup based on configurable rules (unwatched, old, low-rated). Matched media moves to a collection, then is deleted after a grace period unless excluded.

## Prerequisites

| Variable | Purpose |
|----------|---------|
| `MAINTAINERR_URL` | Maintainerr base URL, e.g. `http://192.168.1.100:6246` |
| `CLAWARR_HOST` | Optional fallback when `MAINTAINERR_URL` is unset: `http://$CLAWARR_HOST:6246` (`MAINTAINERR_PORT` override) |

Maintainerr's API takes no key. Create rules in its web UI. See `references/companion-services.md` (Maintainerr section) for common rules and the API.

## Commands (`scripts/maintainerr.sh`)

```bash
maintainerr.sh status             # Check status
maintainerr.sh rules              # List cleanup rules
maintainerr.sh collections        # List managed collections
maintainerr.sh run [rule_id]      # Trigger rules (all or specific)
maintainerr.sh media <rule_id>    # Show media matched by a rule
maintainerr.sh exclude <m> <r>    # Exclude media from rule
maintainerr.sh logs               # View activity log
```

## Example prompts

- "List my Maintainerr cleanup rules"
- "What media matches rule 3?"
- "Run Maintainerr rule 2 now"
- "Exclude that movie from the unwatched rule"

## Connectivity checklist

1. `MAINTAINERR_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Maintainerr instance; run `scripts/setup.sh maintainerr <url>` from the clawarr-core skill to (re)configure it.
2. Port 6246 reachable (or `MAINTAINERR_PORT` override matches)
3. Web UI loads at `$MAINTAINERR_URL`
4. At least one rule exists (`maintainerr.sh rules` non-empty)
5. Maintainerr is linked to Plex (and Sonarr/Radarr for deletion)

## Destructive actions

`maintainerr.sh run` executes cleanup rules, which can delete media from Plex/*arr libraries. Never run it automatically — show `rules`/matched media first and run only on explicit user request.
