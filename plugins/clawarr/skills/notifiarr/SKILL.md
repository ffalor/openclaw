---
name: notifiarr
description: Unified Notifiarr notifications — status, connected services, test alerts, and recent logs.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Notifiarr

Unified notification management across the *arr stack. Check status and
integrations, list notification triggers, inspect connected services, send test
notifications, and view the recent notification log. See
`references/companion-services.md` for setup (Discord webhooks, triggers) and
`references/api-endpoints.md` for the raw API.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `NOTIFIARR_URL` | Notifiarr base URL, e.g. `https://notifiarr.example.ts.net` or `http://192.168.1.100:5454` |
| `NOTIFIARR_API_KEY` | API key (optional; local status works unauthenticated) |
| `CLAWARR_HOST` | Optional fallback when `NOTIFIARR_URL` is unset: `http://$CLAWARR_HOST:5454` (`CLAWARR_SCHEME`, `NOTIFIARR_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh notifiarr <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$NOTIFIARR_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Notifiarr needs a Discord webhook to actually deliver notifications — configure it in the Notifiarr web UI along with *arr service URLs/keys and notification triggers (grabs, imports, health, upgrades, failures).

Notifiarr API: `$NOTIFIARR_URL/api`, auth header `X-Api-Key: $NOTIFIARR_API_KEY`.

**Calling the API yourself:** always use `$NOTIFIARR_URL` with `$NOTIFIARR_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

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

1. Web UI reachable: `curl -s $NOTIFIARR_URL` (no API key needed for the reachability check).
2. `NOTIFIARR_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Notifiarr instance; run `scripts/setup.sh notifiarr <url>` from the clawarr-core skill to (re)configure it.
3. If authenticated calls fail, verify `NOTIFIARR_API_KEY` against the Notifiarr settings.
4. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
5. Port `5454` is open on the host firewall and the container is running (`docker logs notifiarr`).
6. Container logs show no errors: `docker logs notifiarr --tail 50`

## References

- `references/api-endpoints.md` — Notifiarr API reference (status, notifications, services, logs)
- `references/companion-services.md` — Setup, notification types, Discord webhook guide
