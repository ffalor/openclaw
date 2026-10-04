#!/usr/bin/env bash
# queue.sh - Show download queues across Sonarr/Radarr
# Usage: queue.sh

set -euo pipefail

SONARR_API_KEY="${SONARR_API_KEY:-}"
RADARR_API_KEY="${RADARR_API_KEY:-}"

# Base URL per service: <SERVICE>_URL, else ${CLAWARR_SCHEME:-http}://$CLAWARR_HOST:<port>
arr_url() {
  if [[ -n "$1" ]]; then printf '%s' "${1%/}"
  elif [[ -n "${CLAWARR_HOST:-}" ]]; then printf '%s://%s:%s' "${CLAWARR_SCHEME:-http}" "$CLAWARR_HOST" "$2"
  fi
}
SONARR_URL="$(arr_url "${SONARR_URL:-}" "${SONARR_PORT:-8989}")"
RADARR_URL="$(arr_url "${RADARR_URL:-}" "${RADARR_PORT:-7878}")"

if [[ -z "$SONARR_URL" && -z "$RADARR_URL" ]]; then
  echo "Error: set SONARR_URL/RADARR_URL (or CLAWARR_HOST)"
  echo ""
  echo "Usage:"
  echo "  export SONARR_URL=http://192.168.1.100:8989"
  echo "  export SONARR_API_KEY=abc123..."
  echo "  $0"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required but not installed"
  exit 1
fi

echo "📥 Download Queues"
echo ""

if [[ -n "$RADARR_API_KEY" && -n "$RADARR_URL" ]]; then
  echo "=== Radarr Queue ==="
  
  queue=$(curl -sSf -H "X-Api-Key: ${RADARR_API_KEY}" "${RADARR_URL}/api/v3/queue" || echo '{"records":[]}')
  
  count=$(echo "$queue" | jq '.records | length')
  
  if [[ "$count" -eq 0 ]]; then
    echo "  (empty)"
  else
    echo "$queue" | jq -r '.records[] | "  • \(.title)\n    Status: \(.status) | Progress: \(.sizeleft / 1024 / 1024 | floor)MB left of \(.size / 1024 / 1024 | floor)MB\n    ETA: \(.timeleft // "Unknown")"'
  fi
  echo ""
fi

if [[ -n "$SONARR_API_KEY" && -n "$SONARR_URL" ]]; then
  echo "=== Sonarr Queue ==="
  
  queue=$(curl -sSf -H "X-Api-Key: ${SONARR_API_KEY}" "${SONARR_URL}/api/v3/queue" || echo '{"records":[]}')
  
  count=$(echo "$queue" | jq '.records | length')
  
  if [[ "$count" -eq 0 ]]; then
    echo "  (empty)"
  else
    echo "$queue" | jq -r '.records[] | "  • \(.title)\n    Status: \(.status) | Progress: \(.sizeleft / 1024 / 1024 | floor)MB left of \(.size / 1024 / 1024 | floor)MB\n    ETA: \(.timeleft // "Unknown")"'
  fi
  echo ""
fi

if [[ -z "$RADARR_API_KEY" && -z "$SONARR_API_KEY" ]]; then
  echo "No API keys configured. Set RADARR_API_KEY and/or SONARR_API_KEY."
fi
