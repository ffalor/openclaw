---
name: seerr
description: Manage Seerr media requests — list, approve, deny, and inspect pending movie/TV requests.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# Seerr

Media request handling via Seerr. List pending requests, approve or deny
them, inspect details, and view request statistics. See
`references/api-endpoints.md` for the raw API (including issue tracking,
webhooks, and collections).

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `SEERR_URL` | Seerr base URL, e.g. `https://seerr.example.ts.net` or `http://192.168.1.100:5055` |
| `SEERR_API_KEY` | API key (Settings → General → API Key) |
| `CLAWARR_HOST` | Optional fallback when `SEERR_URL` is unset: `http://$CLAWARR_HOST:5055` (`CLAWARR_SCHEME`, `SEERR_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh seerr <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$SEERR_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

Seerr API: `$SEERR_URL/api/v1`, auth header `X-Api-Key: $SEERR_API_KEY`.

**Calling the API yourself:** always use `$SEERR_URL` with `$SEERR_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

## Scripts

### Request management (`requests.sh`)

```bash
scripts/requests.sh list [pending|approved|available|all]  # List requests (default: all)
scripts/requests.sh approve <id>                           # Approve a request
scripts/requests.sh deny <id> [reason]                     # Deny a request with optional reason
scripts/requests.sh info <id>                              # Show request details
scripts/requests.sh stats                                  # Request statistics
```

## Common Workflows

```bash
# Show pending requests
scripts/requests.sh list pending

# Approve or deny a request
scripts/requests.sh approve 123
scripts/requests.sh deny 123 "Quality too low, please search for better release"

# Inspect a single request
scripts/requests.sh info 456

# Request statistics
scripts/requests.sh stats
```

To bulk-approve a pending queue, list pending requests then loop `approve <id>`
over each result.

## Example Prompts

- "Show pending media requests"
- "Approve all pending Seerr requests"
- "What's the status of request 456?"
- "How many requests do we have total?"

## Troubleshooting

Connectivity checklist:

1. Host reachable: `curl -s "$SEERR_URL/api/v1/status?apikey=$SEERR_API_KEY"`
2. `SEERR_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the Seerr instance; run `scripts/setup.sh seerr <url>` from the clawarr-core skill to (re)configure it.
3. `SEERR_API_KEY` matches Settings → General in the Seerr web UI.
4. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
5. Port `5055` is open on the host firewall and the container is running (`docker logs seerr`).
6. Container logs show no errors: `docker logs seerr --tail 50`

## References

- `references/api-endpoints.md` — Seerr API v1 reference (requests, search, media, users, issues, webhooks)

## Destructive actions

Approving or denying a request changes what gets downloaded and notifies the requester. Act only on explicit user request.
