---
name: overseerr
description: Manage Overseerr media requests — list, approve, deny, and inspect pending movie/TV requests.
metadata:
  openclaw:
    requires:
      bins: ["bash", "curl", "jq"]
      env: ["CLAWARR_HOST", "OVERSEERR_KEY"]
---

# Overseerr

Media request handling via Overseerr. List pending requests, approve or deny
them, inspect details, and view request statistics. See
`references/api-endpoints.md` for the raw API (including issue tracking,
webhooks, and collections).

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Required | Purpose |
|----------|----------|---------|
| `CLAWARR_HOST` | Yes | Host IP/hostname of the Overseerr instance (port 5055) |
| `OVERSEERR_KEY` | Yes | Overseerr API key (Settings → General → API Key) |

```bash
export CLAWARR_HOST=192.168.1.100
export OVERSEERR_KEY=stu901...
```

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
- "Approve all pending Overseerr requests"
- "What's the status of request 456?"
- "How many requests do we have total?"

## Troubleshooting

Connectivity checklist:

1. Host reachable: `curl -s "http://$CLAWARR_HOST:5055/api/v1/status?apikey=$OVERSEERR_KEY"`
2. `CLAWARR_HOST` is set and points at the Overseerr machine (no scheme, no port).
3. `OVERSEERR_KEY` matches Settings → General in the Overseerr web UI.
4. Port `5055` is open on the host firewall and the container is running (`docker logs overseerr`).
5. Container logs show no errors: `docker logs overseerr --tail 50`

## References

- `references/api-endpoints.md` — Overseerr API v1 reference (requests, search, media, users, issues, webhooks)
