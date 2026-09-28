#!/usr/bin/env bash
# indexers.sh - Prowlarr indexer management
# Usage: indexers.sh <command> [options]
#
# Commands:
#   list              - List configured indexers with status
#   test [id]         - Test indexer connectivity (all or specific ID)
#   stats             - Indexer performance statistics

set -euo pipefail

HOST="${CLAWARR_HOST:-}"
CLAWARR_SCHEME="${CLAWARR_SCHEME:-http}"
PROWLARR_KEY="${PROWLARR_KEY:-}"
PROWLARR_PORT="${PROWLARR_PORT:-9696}"

if [[ -z "$HOST" ]]; then
  echo "❌ Error: CLAWARR_HOST not set"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required"
  exit 1
fi

show_help() {
  head -n 11 "$0" | grep "^#" | sed 's/^# \?//'
  exit 0
}

# Helper: call Prowlarr API
prowlarr_api() {
  local method=$1
  local endpoint=$2
  local data="${3:-}"
  
  if [[ -z "$PROWLARR_KEY" ]]; then
    [[ "$method" == "GET" ]] && { printf '[]'; return 0; }
    echo "❌ PROWLARR_KEY not set" >&2
    return 1
  fi

  local url="${CLAWARR_SCHEME}://${HOST}:${PROWLARR_PORT}/api/v1${endpoint}"
  
  if [[ "$method" == "GET" ]]; then
    curl -fsS --connect-timeout 3 --max-time 20 -H "X-Api-Key: $PROWLARR_KEY" "$url" 2>/dev/null || printf '[]'
  elif [[ "$method" == "POST" ]]; then
    curl -fsS --connect-timeout 3 --max-time 20 -X POST -H "X-Api-Key: $PROWLARR_KEY" -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null
  fi
}

# Command: list
cmd_list() {
  echo "📡 Configured Indexers"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local indexers
  indexers=$(prowlarr_api GET "/indexer")
  
  if [[ $(echo "$indexers" | jq 'length') -eq 0 ]]; then
    echo "  No indexers configured"
    echo ""
    return
  fi
  
  echo "$indexers" | jq -r '.[] | 
    "[ID:\(.id)] \(.name)
    Protocol: \(.protocol | ascii_upcase) | Priority: \(.priority)
    Status: \(if .enable then "✅ Enabled" else "⏸️  Disabled" end)
    "' | sed 's/^/  /'
  
  local total
  total=$(echo "$indexers" | jq 'length')
  local enabled
  enabled=$(echo "$indexers" | jq '[.[] | select(.enable == true)] | length')
  
  echo "  Total: $total | Enabled: $enabled"
  echo ""
}

# Command: test
cmd_test() {
  local id="${1:-}"
  
  if [[ -z "$id" ]]; then
    echo "🧪 Testing All Indexers"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get all indexers
    local indexers
    indexers=$(prowlarr_api GET "/indexer")
    
    echo "$indexers" | jq -r '.[] | "\(.id) \(.name)"' | while read -r idx_id idx_name; do
      echo -n "  Testing $idx_name... "
      
      # Test individual indexer
      local test_data
      test_data=$(prowlarr_api GET "/indexer/$idx_id" | jq '{
        enable: .enable,
        name: .name,
        fields: .fields,
        implementationName: .implementationName,
        implementation: .implementation,
        configContract: .configContract,
        protocol: .protocol,
        priority: .priority
      }')
      
      if prowlarr_api POST "/indexer/test" "$test_data" >/dev/null 2>&1; then
        echo "✅ OK"
      else
        echo "❌ FAILED"
      fi
    done
  else
    echo "🧪 Testing Indexer ID: $id"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get indexer config
    local indexer
    indexer=$(prowlarr_api GET "/indexer/$id")
    local name
    name=$(echo "$indexer" | jq -r '.name')
    
    echo -n "  Testing $name... "
    
    local test_data
    test_data=$(echo "$indexer" | jq '{
      enable: .enable,
      name: .name,
      fields: .fields,
      implementationName: .implementationName,
      implementation: .implementation,
      configContract: .configContract,
      protocol: .protocol,
      priority: .priority
    }')
    
    if prowlarr_api POST "/indexer/test" "$test_data" >/dev/null 2>&1; then
      echo "✅ OK"
    else
      echo "❌ FAILED"
    fi
  fi
  
  echo ""
}

# Command: stats
cmd_stats() {
  echo "📊 Indexer Performance (Latest 100 Events)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Get indexer stats from history
  local history
  history=$(prowlarr_api GET "/history?page=1&pageSize=100")
  
  if [[ $(echo "$history" | jq '.records | length') -eq 0 ]]; then
    echo "  No indexer history available"
    echo ""
    return
  fi
  
  echo ""
  echo "  Recent Activity (by indexer):"
  
  # Count queries per indexer
  echo "$history" | jq -r '.records[] | .indexer' | sort | uniq -c | sort -rn | while read -r count indexer; do
    printf "    %-30s %6d queries\n" "$indexer" "$count"
  done
  
  echo ""
  echo "  Query Types:"
  echo "$history" | jq -r '.records[] | .eventType' | sort | uniq -c | sort -rn | while read -r count type; do
    printf "    %-30s %6d\n" "$type" "$count"
  done
  
  echo ""
  echo "  Success vs Failures:"
  local successful
  successful=$(echo "$history" | jq '[.records[] | select(.successful == true)] | length')
  local failed
  failed=$(echo "$history" | jq '[.records[] | select(.successful == false)] | length')
  local total
  total=$(echo "$history" | jq '.records | length')
  
  echo "    Successful: $successful"
  echo "    Failed: $failed"
  echo "    Events in this sample: $total"
  
  if [[ $total -gt 0 ]]; then
    local success_rate
    success_rate=$(echo "scale=1; ($successful * 100) / $total" | bc)
    echo "    Success Rate: ${success_rate}%"
  fi
  
  echo ""
}

# Main command router
COMMAND="${1:-help}"

if [[ -z "$PROWLARR_KEY" && "$COMMAND" != "help" && "$COMMAND" != "--help" && "$COMMAND" != "-h" ]]; then
  echo "⚠️  PROWLARR_KEY not set; skipping Prowlarr command"
  exit 0
fi

case "$COMMAND" in
  list)  cmd_list ;;
  test)  cmd_test "${2:-}" ;;
  stats) cmd_stats ;;
  help|--help|-h) show_help ;;
  *)
    echo "❌ Unknown command: $COMMAND"
    echo "Run '$0 help' for usage"
    exit 1
    ;;
esac
