---
name: notifiarr
description: Unified Notifiarr notifications — status, connected services, test alerts, and recent logs.
metadata:
  openclaw:
    requires:
      bins: ["bash", "curl", "jq"]
      env: ["CLAWARR_HOST"]
---

# Notifiarr

Unified notification management across the *arr stack. Check status and
integrations, list notification triggers, inspect connected services, send test
notifications, and view the recent notification log. See
`references/companion-services.md` for setup (Discord webhooks, triggers) and
`references/api-endpoints.md` for the raw API.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Required | Purpose |
|----------|----------|---------|
| `CLAWARR_HOST` | Yes | Host IP/hostname of the Notifiarr instance |
| `NOTIFIARR_KEY` | No | Notifiarr API key (script works unauthenticated for local status if unset) |
| `NOTIFIARR_PORT` | No | Notifiarr HTTP port (default: `5454`) |

```bash
export CLAWARR_HOST=192.168.1.100
export NOTIFIARR_KEY=xyz123...
# export NOTIFIARR_PORT=5454  # only if non-default
```

Notifiarr needs a Discord webhook to actually deliver notifications — configure
it in the web UI at `http://<host>:5454` along with *arr service URLs/keys and
notification triggers (grabs, imports, health, upgrades, failures).

## Scripts

### Notification management (`notifiarr.sh`)

```bash
scripts/notifiarr.sh status          # Check status & integrations
scripts/notifiarr.sh triggers        # List notification triggers
scripts/notifiarr.sh services        # Show connected services
scripts/notifiarr.sh test [channel]  # Send test notification (all channels if omitted)
scripts/notifiarr.sh config          # Configuration summary
scripts/notifiarr.sh logs            # Recent notification log
```

## Common Workflows

```bash
# Health + integrations overview
scripts/notifiarr.sh status
scripts/notifiarr.sh services

# Verify delivery end to end
scripts/notifiarr.sh test
scripts/notifiarr.sh test discord

# What fired recently?
scripts/notifiarr.sh logs
```

## Example Prompts

- "Check Notifiarr status and integrations"
- "Send a test notification"
- "Show recent notifications"
- "What services are connected to Notifiarr?"

## Troubleshooting

Connectivity checklist:

1. Web UI reachable: `curl -s http://$CLAWARR_HOST:5454` (no API key needed for the reachability check).
2. `CLAWARR_HOST` is set and points at the Notifiarr machine (no scheme, no port).
3. If authenticated calls fail, verify `NOTIFIARR_KEY` against the Notifiarr settings.
4. Port `5454` is open on the host firewall and the container is running (`docker logs notifiarr`).
5. Container logs show no errors: `docker logs notifiarr --tail 50`

## References

- `references/api-endpoints.md` — Notifiarr API reference (status, notifications, services, logs)
- `references/companion-services.md` — Setup, notification types, Discord webhook guide
