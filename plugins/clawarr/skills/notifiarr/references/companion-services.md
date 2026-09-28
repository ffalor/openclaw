# Notifiarr Companion Service

Guide for *arr stack companion services: Prowlarr, Recyclarr, FlareSolverr, Unpackerr, Notifiarr, Maintainerr, and Kometa.


## Notifiarr — Unified Notifications

### What It Does
Routes notifications from all *arr services to Discord, Telegram, Slack, or other targets. Provides health monitoring, grab notifications, import confirmations.

### Setup
1. Run container (port 5454)
2. Open web UI at `http://host:5454`
3. Configure Discord webhook URL
4. Add *arr service URLs and API keys
5. Enable desired notification triggers

### Notification Types
- **Grabs**: When content is grabbed from indexer
- **Imports**: When content is imported to library
- **Health**: Service health alerts
- **Upgrades**: When quality upgrades happen
- **Failures**: Download/import failures

### Discord Webhook Setup
1. Discord Server Settings → Integrations → Webhooks
2. Create webhook in desired channel
3. Copy webhook URL
4. Paste in Notifiarr settings

---
