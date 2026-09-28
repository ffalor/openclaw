---
name: maintainerr
description: Rule-based Plex library cleanup management (rules, collections, runs) via maintainerr.sh.
metadata:
  {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": ["CLAWARR_HOST"]}}}
---

# Maintainerr

Automated Plex library cleanup based on configurable rules (unwatched, old, low-rated). Matched media moves to a collection, then is deleted after a grace period unless excluded.

## Requires

| Variable | Purpose | Default |
|---|---|---|
| `CLAWARR_HOST` | Maintainerr server host | — |
| `MAINTAINERR_PORT` | Maintainerr HTTP port | `6246` |
| `DOCKER_CONFIG_BASE` | Docker config root (optional, unused here) | `/volume1/docker` |

Create rules in the web UI at `http://<host>:6246`. See `references/companion-services.md` (Maintainerr section) for common rules and the API.

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

1. `CLAWARR_HOST` points at the Maintainerr server host
2. Port 6246 reachable (or `MAINTAINERR_PORT` override matches)
3. Web UI at `http://<host>:6246` loads
4. At least one rule exists (`maintainerr.sh rules` non-empty)
5. Maintainerr is linked to Plex (and Sonarr/Radarr for deletion)
