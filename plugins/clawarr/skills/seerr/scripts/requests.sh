#!/usr/bin/env bash
# requests.sh - Seerr request management
# Usage: requests.sh <command> [options]
#
# Commands:
#   list [status]     - List requests (pending|approved|available|all, default: all)
#   approve <id>      - Approve a request
#   deny <id> [reason] - Deny a request with optional reason
#   info <id>         - Show request details
#   stats             - Request statistics

set -euo pipefail

SEERR_API_KEY="${SEERR_API_KEY:-}"

# Base URL per service: <SERVICE>_URL, else ${CLAWARR_SCHEME:-http}://$CLAWARR_HOST:<port>
arr_url() {
  if [[ -n "$1" ]]; then printf '%s' "${1%/}"
  elif [[ -n "${CLAWARR_HOST:-}" ]]; then printf '%s://%s:%s' "${CLAWARR_SCHEME:-http}" "$CLAWARR_HOST" "$2"
  fi
}
SEERR_URL="$(arr_url "${SEERR_URL:-}" "${SEERR_PORT:-5055}")"

if [[ -z "$SEERR_URL" ]]; then
  echo "❌ Error: SEERR_URL (or CLAWARR_HOST) not set"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required"
  exit 1
fi

show_help() {
  head -n 13 "$0" | grep "^#" | sed 's/^# \?//'
  exit 0
}

# Helper: call Seerr API
seerr_api() {
  local method=$1
  local endpoint=$2
  local data="${3:-}"
  
  if [[ -z "$SEERR_API_KEY" ]]; then
    [[ "$method" == "GET" ]] && { printf '{}'; return 0; }
    echo "❌ SEERR_API_KEY not set" >&2
    return 1
  fi

  local url="${SEERR_URL}/api/v1${endpoint}"
  
  if [[ "$method" == "GET" ]]; then
    curl -fsS --connect-timeout 3 --max-time 20 -H "X-Api-Key: $SEERR_API_KEY" "$url" || printf '{}'
  elif [[ "$method" == "POST" ]]; then
    curl -fsS --connect-timeout 3 --max-time 20 -X POST -H "X-Api-Key: $SEERR_API_KEY" -H "Content-Type: application/json" -d "$data" "$url"
  fi
}

# Command: list
cmd_list() {
  local status="${1:-all}"
  local filter=""
  
  case "$status" in
    pending)    filter="&filter=pending" ;;
    approved)   filter="&filter=approved" ;;
    available)  filter="&filter=available" ;;
    all)        filter="" ;;
    *)
      echo "❌ Invalid status. Use: pending, approved, available, or all"
      exit 1
      ;;
  esac
  
  echo "📋 Requests - $(echo "$status" | tr '[:lower:]' '[:upper:]')"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local requests
  requests=$(seerr_api GET "/request?take=50&skip=0${filter}")
  
  if [[ $(echo "$requests" | jq '.results | length') -eq 0 ]]; then
    echo "  No requests found"
    echo ""
    return
  fi
  
  echo "$requests" | jq -r '.results[] | 
    "[ID:\(.id)] \(.media.tmdbId // .media.tvdbId) - \(.type | ascii_upcase) - \(.media.title // .media.name // "Unknown")
    Status: \(if .media.status == 5 then "✅ Available" elif .media.status == 4 then "⏬ Downloading" elif .media.status == 3 then "🔍 Processing" elif .media.status == 2 then "⏳ Pending" else "❓ Unknown" end)
    Requested by: \(.requestedBy.displayName // .requestedBy.email)
    "' | sed 's/^/  /'
  
  local total
  total=$(echo "$requests" | jq '.pageInfo.results // (.results | length) // 0')
  echo "  Total: $total"
  echo ""
}

# Command: approve
cmd_approve() {
  local id="$1"
  
  if [[ -z "$id" ]]; then
    echo "❌ Error: Request ID required"
    echo "Usage: $0 approve <id>"
    exit 1
  fi
  
  echo "✅ Approving request ID: $id"
  
  if seerr_api POST "/request/$id/approve" '{}' >/dev/null 2>&1; then
    echo "✅ Request approved successfully"
  else
    echo "❌ Failed to approve request"
  fi
}

# Command: deny
cmd_deny() {
  local id="$1"
  local reason="${2:-No reason provided}"
  
  if [[ -z "$id" ]]; then
    echo "❌ Error: Request ID required"
    echo "Usage: $0 deny <id> [reason]"
    exit 1
  fi
  
  echo "❌ Denying request ID: $id"
  echo "   Reason: $reason"
  
  local data
  data=$(jq -n --arg reason "$reason" '{message: $reason}')
  
  if seerr_api POST "/request/$id/decline" "$data" >/dev/null 2>&1; then
    echo "✅ Request denied successfully"
  else
    echo "❌ Failed to deny request"
  fi
}

# Command: info
cmd_info() {
  local id="$1"
  
  if [[ -z "$id" ]]; then
    echo "❌ Error: Request ID required"
    echo "Usage: $0 info <id>"
    exit 1
  fi
  
  echo "ℹ️  Request Details - ID: $id"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local request
  request=$(seerr_api GET "/request/$id")
  
  echo "$request" | jq -r '
    "Title: \(.media.title // .media.name // "Unknown")",
    "Type: \(.type | ascii_upcase)",
    "Status: \(
      if .media.status == 5 then "Available"
      elif .media.status == 4 then "Downloading"
      elif .media.status == 3 then "Processing"
      elif .media.status == 2 then "Pending"
      else "Unknown"
      end
    )",
    "Requested by: \(.requestedBy.displayName // .requestedBy.email)",
    "Requested on: \(.createdAt | split("T")[0])",
    "TMDB/TVDB ID: \(.media.tmdbId // .media.tvdbId)",
    (if .seasons then "Seasons: \(.seasons | map(.seasonNumber) | join(", "))" else empty end),
    ""
  ' | sed 's/^/  /'
}

# Command: stats
cmd_stats() {
  echo "📊 Request Statistics"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Get all requests
  local counts recent_requests
  counts=$(seerr_api GET "/request/count")
  recent_requests=$(seerr_api GET "/request?take=50&skip=0")
  local total pending processing available movies tv
  total=$(echo "$counts" | jq '.total // 0')
  pending=$(echo "$counts" | jq '.pending // 0')
  processing=$(echo "$counts" | jq '.processing // 0')
  available=$(echo "$counts" | jq '.available // 0')
  movies=$(echo "$counts" | jq '.movie // 0')
  tv=$(echo "$counts" | jq '.tv // 0')
  
  echo "  Total Requests: $total"
  echo "  Pending: $pending"
  echo "  Processing: $processing"
  echo "  Available: $available"
  echo ""
  echo "  Movies: $movies"
  echo "  TV Shows: $tv"
  echo ""
  
  # Top requesters
  echo "  Top Requesters (latest 50 requests):"
  echo "$recent_requests" | jq -r '.results[]? | .requestedBy.displayName // .requestedBy.email' | \
    sort | uniq -c | sort -rn | head -5 | while read -r count user; do
      printf "    %-30s %5d requests\n" "$user" "$count"
    done
  
  echo ""
}

# Main command router
COMMAND="${1:-help}"

if [[ -z "$SEERR_API_KEY" && "$COMMAND" != "help" && "$COMMAND" != "--help" && "$COMMAND" != "-h" ]]; then
  echo "⚠️  SEERR_API_KEY not set; skipping Seerr command"
  exit 0
fi

case "$COMMAND" in
  list)    cmd_list "${2:-all}" ;;
  approve) cmd_approve "${2:-}" ;;
  deny)    cmd_deny "${2:-}" "${3:-}" ;;
  info)    cmd_info "${2:-}" ;;
  stats)   cmd_stats ;;
  help|--help|-h) show_help ;;
  *)
    echo "❌ Unknown command: $COMMAND"
    echo "Run '$0 help' for usage"
    exit 1
    ;;
esac
