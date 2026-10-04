---
name: sabnzbd
description: Monitor and control SABnzbd downloads — queue status, speed, history, pause and resume.
metadata: {"openclaw": {"requires": {"bins": ["bash", "curl", "jq"], "env": []}}}
---

# SABnzbd

Download client operations via SABnzbd. View the active queue, check speed,
browse history, and pause/resume downloads. See `references/api-endpoints.md`
for the raw API (modes, queue response shape) and `references/common-issues.md`
for download-client troubleshooting.

## Prerequisites

Required binaries: `bash`, `curl`, `jq`.

| Variable | Purpose |
|----------|---------|
| `SABNZBD_URL` | SABnzbd base URL, e.g. `https://sabnzbd.example.ts.net` or `http://192.168.1.100:8081` |
| `SABNZBD_API_KEY` | API key (Config → General → Security → API Key) |
| `CLAWARR_HOST` | Optional fallback when `SABNZBD_URL` is unset: `http://$CLAWARR_HOST:8081` (`CLAWARR_SCHEME`, `SABNZBD_PORT` override) |

Configure both with the `clawarr-core` skill: `scripts/setup.sh sabnzbd <url>`. Over HTTPS the key is a protected OpenClaw store secret and `$SABNZBD_API_KEY` holds an `oc-sent-…` sentinel; over plain HTTP it is plaintext in `~/.openclaw/.env`.

SABnzbd API: `$SABNZBD_URL/api?apikey=$SABNZBD_API_KEY&mode=…&output=json` (key in the query string; the egress proxy substitutes it there too).

**Calling the API yourself:** always use `$SABNZBD_URL` with `$SABNZBD_API_KEY`. Never add `--noproxy`, unset `HTTP_PROXY`/`HTTPS_PROXY`, or print the key: an `oc-sent-…` value only works through the OpenClaw egress proxy, over HTTPS, to the host it is bound to. On a 401 report it and point the user at `clawarr-core`'s `scripts/setup.sh`; do not try other variables.

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

1. SABnzbd web UI reachable at `$SABNZBD_URL`; `SABNZBD_URL` is set (or `CLAWARR_HOST` as the http fallback) and points at the SABnzbd instance; run `scripts/setup.sh sabnzbd <url>` from the clawarr-core skill to (re)configure it.
2. `SABNZBD_API_KEY` matches Config → General → Security → API Key.
3. A 401 with an `oc-sent-…` key means the request bypassed the OpenClaw egress proxy (`--noproxy`, unset proxy vars, plain http) or the URL's host isn't in the secret's allowed hosts — never work around it by using another variable.
4. If *arr apps report connection failures, test connectivity from the *arr
   container and re-test in Settings → Download Clients → Test.
5. If downloads complete but imports never happen, compare the SABnzbd category
   against the *arr download-client category setting.

## References

- `references/api-endpoints.md` — SABnzbd API reference (modes, queue response)
- `references/common-issues.md` — Download client troubleshooting
