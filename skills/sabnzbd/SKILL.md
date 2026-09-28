---
name: sabnzbd
description: Monitor and control SABnzbd downloads — queue status, speed, history, pause and resume.
metadata:
  openclaw:
    requires:
      bins: ["bash", "curl", "jq"]
      env: ["CLAWARR_HOST", "SABNZBD_KEY"]
---

# SABnzbd

Download client operations via SABnzbd. View the active queue, check speed,
browse history, and pause/resume downloads. See `references/api-endpoints.md`
for the raw API (modes, queue response shape) and `references/common-issues.md`
for download-client troubleshooting.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Required | Purpose |
|----------|----------|---------|
| `CLAWARR_HOST` | Yes | Host IP/hostname of the SABnzbd instance |
| `SABNZBD_KEY` | Yes | SABnzbd API key (Config → General → Security → API Key) |
| `SABNZBD_PORT` | No | SABnzbd HTTP port (default: `8081`) |

```bash
export CLAWARR_HOST=192.168.1.100
export SABNZBD_KEY=abc890...
# export SABNZBD_PORT=8081  # only if non-default
```

## Scripts

### Download client (`downloads.sh`)

```bash
scripts/downloads.sh active          # Currently downloading
scripts/downloads.sh speed           # Current download speed
scripts/downloads.sh history [count] # Download history (default: 20)
scripts/downloads.sh pause           # Pause downloads
scripts/downloads.sh resume          # Resume downloads
scripts/downloads.sh queue           # Full queue details
```

## Common Workflows

```bash
# What's downloading right now?
scripts/downloads.sh active
scripts/downloads.sh speed

# Recent history
scripts/downloads.sh history 30

# Pause / resume everything
scripts/downloads.sh pause
scripts/downloads.sh resume
```

If *arr apps can't see completed downloads, the usual causes are category
mismatch (SABnzbd category must match the *arr download-client category) or a
remote path mapping problem — see `references/common-issues.md`.

## Example Prompts

- "Show me what's downloading right now"
- "What's the current download speed?"
- "Pause downloads" / "Resume downloads"
- "Show SABnzbd download history"

## Troubleshooting

See `references/common-issues.md` (Download Client Issues) for diagnosing
connection failures, stalled downloads, and category mismatches. Quick checks:

1. SABnzbd web UI reachable at `http://$CLAWARR_HOST:$SABNZBD_PORT`.
2. `SABNZBD_KEY` matches Config → General → Security → API Key.
3. If *arr apps report connection failures, test connectivity from the *arr
   container and re-test in Settings → Download Clients → Test.
4. If downloads complete but imports never happen, compare the SABnzbd category
   against the *arr download-client category setting.

## References

- `references/api-endpoints.md` — SABnzbd API reference (modes, queue response)
- `references/common-issues.md` — Download client troubleshooting
