#!/usr/bin/env bash
# analytics.sh - Rich viewing analytics from Tautulli and Plex
# Usage: analytics.sh <command> [options]
#
# Commands:
#   activity                    - Currently watching / active streams
#   history [count]             - Watch history (default: 20)
#   most-watched [period]       - Most watched content (week/month/year, default: month)
#   popular-genres              - Most common genres in the latest 100 history records
#   peak-hours                  - Peak watching hours breakdown
#   user-stats [user]           - User activity summary (default: all)
#   library-stats               - Plex library section statistics
#   recent-added [count]        - Recently added to Plex (default: 10)
#   play-totals                 - Total play count and duration

set -euo pipefail

HOST="${CLAWARR_HOST:-}"
CLAWARR_SCHEME="${CLAWARR_SCHEME:-http}"
TAUTULLI_KEY="${TAUTULLI_KEY:-}"
TAUTULLI_PORT="${TAUTULLI_PORT:-8181}"
PLEX_TOKEN="${PLEX_TOKEN:-}"
PLEX_HOST="${PLEX_HOST:-$HOST}"
PLEX_SCHEME="${PLEX_SCHEME:-http}"
PLEX_PORT="${PLEX_PORT:-32400}"

if [[ -z "$HOST" ]]; then
  echo "❌ Error: CLAWARR_HOST not set"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required"
  exit 1
fi

show_help() {
  head -n 18 "$0" | grep "^#" | sed 's/^# \?//'
  exit 0
}

# Helper: call Tautulli API
tautulli_api() {
  local cmd=$1
  shift
  local params="$*"
  
  if [[ -z "$TAUTULLI_KEY" ]]; then
    printf '{}'
    return 0
  fi
  
  local url="${CLAWARR_SCHEME}://${HOST}:${TAUTULLI_PORT}/api/v2?apikey=${TAUTULLI_KEY}&cmd=${cmd}"
  if [[ -n "$params" ]]; then
    url="${url}&${params}"
  fi
  
  curl -fsS --connect-timeout 3 --max-time 20 "$url" 2>/dev/null || printf '{}'
}

# Helper: call Plex API
plex_api() {
  local endpoint=$1
  
  if [[ -z "$PLEX_TOKEN" ]]; then
    printf '{}'
    return 0
  fi
  
  curl -fsS --connect-timeout 3 --max-time 20 -H "X-Plex-Token: ${PLEX_TOKEN}" -H "Accept: application/json" \
    "${PLEX_SCHEME}://${PLEX_HOST}:${PLEX_PORT}${endpoint}" 2>/dev/null || printf '{}'
}

# Command: activity (current streams)
cmd_activity() {
  echo "🎬 Current Activity"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local data
  data=$(tautulli_api "get_activity")
  
  local stream_count
  stream_count=$(echo "$data" | jq -r '.response.data.stream_count')
  
  if [[ "$stream_count" == "0" ]]; then
    echo "  No active streams"
    echo ""
    return
  fi
  
  echo "  Active Streams: $stream_count"
  echo ""
  
  echo "$data" | jq -r '.response.data.sessions[] | "  \(.user) → \(.full_title)\n    [\(.state | ascii_upcase)] \(.progress_percent)% • \(.transcode_decision)"'
  echo ""
}

# Command: history
cmd_history() {
  local count="${1:-20}"

  [[ "$count" =~ ^[0-9]+$ ]] || count=20
  (( count > 100 )) && count=100
  
  echo "📜 Watch History (Last $count)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local data
  data=$(tautulli_api "get_history" "length=${count}")
  
  echo "$data" | jq -r '.response.data.data[] | "\(.date | tonumber | strftime("%Y-%m-%d %H:%M"))  \(.user) watched \(.full_title)"'
  echo ""
}

# Command: most-watched
cmd_most_watched() {
  local period="${1:-month}"
  local time_range=30
  
  case "$period" in
    week)  time_range=7 ;;
    month) time_range=30 ;;
    year)  time_range=365 ;;
    *)
      echo "❌ Invalid period. Use: week, month, or year"
      exit 1
      ;;
  esac
  
  echo "🏆 Most Watched (Last $period)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Movies
  echo ""
  echo "Movies:"
  local movies
  movies=$(tautulli_api "get_home_stats" "time_range=${time_range}&stats_type=plays&stats_count=10&stat_id=popular_movies")
  echo "$movies" | jq -r '.response.data[0].rows[]? | "  \(.title) - \(.total_plays) plays"' 2>/dev/null || echo "  No data"
  
  # TV Shows
  echo ""
  echo "TV Shows:"
  local shows
  shows=$(tautulli_api "get_home_stats" "time_range=${time_range}&stats_type=plays&stats_count=10&stat_id=popular_tv")
  echo "$shows" | jq -r '.response.data[0].rows[]? | "  \(.title) - \(.total_plays) plays"' 2>/dev/null || echo "  No data"
  
  echo ""
}

# Command: popular genres
cmd_popular_genres() {
  echo "🎭 Most Common Genres (Latest 100 History Records)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Get history and extract genres
  local data
  data=$(tautulli_api "get_history" "length=100")
  
  echo "$data" | jq -r '.response.data.data[] | .genres' | \
    tr '|' '\n' | sort | uniq -c | sort -rn | head -15 | \
    while read -r count genre; do
      printf "  %-25s %5d plays\n" "$genre" "$count"
    done
  
  echo ""
}

# Command: peak hours
cmd_peak_hours() {
  echo "⏰ Peak Watching Hours"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local data
  data=$(tautulli_api "get_plays_by_hour_of_day" "time_range=30")
  
  echo "$data" | jq -r '.response.data[] | "\(.hour):00 - \((.plays | tonumber)) plays"' | \
    sort -t'-' -k2 -rn | head -24
  
  echo ""
}

# Command: user stats
cmd_user_stats() {
  local user="${1:-}"
  
  if [[ -z "$user" ]]; then
    echo "👥 All Users Activity Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local users
    users=$(tautulli_api "get_users")
    
    echo "$users" | jq -r '.response.data[] | "\(.friendly_name):\n  Total Plays: \(.plays)\n  Duration: \(.duration / 3600 | floor)h \(((.duration % 3600) / 60) | floor)m\n"'
  else
    echo "👤 User Stats: $user"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get user ID first
    local users
    users=$(tautulli_api "get_users")
    local user_id
    user_id=$(echo "$users" | jq -r ".response.data[] | select(.friendly_name == \"$user\") | .user_id")
    
    if [[ -z "$user_id" ]]; then
      echo "❌ User not found: $user"
      return 1
    fi
    
    local stats
    stats=$(tautulli_api "get_user_watch_time_stats" "user_id=${user_id}")
    
    echo "$stats" | jq -r '.response.data[] | "  \(.query_days) days: \(.total_plays) plays, \(.total_time / 3600 | floor)h \(((.total_time % 3600) / 60) | floor)m"'
  fi
  
  echo ""
}

# Command: library stats
cmd_library_stats() {
  echo "📚 Plex Library Statistics"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local sections
  sections=$(plex_api "/library/sections")
  echo "$sections" | jq -r '.MediaContainer.Directory[]? | "\(.title):\n  Type: \(.type)"'
  
  # Alternative: use Tautulli
  local taut_libs
  taut_libs=$(tautulli_api "get_libraries")
  
  echo ""
  echo "Library Details (from Tautulli):"
  echo "$taut_libs" | jq -r '.response.data[]? | "  \(.section_name): \(.count | tonumber? // 0) items (\(.section_type))"'
  
  echo ""
}

# Command: recently added
cmd_recent_added() {
  local count="${1:-10}"

  [[ "$count" =~ ^[0-9]+$ ]] || count=10
  (( count > 100 )) && count=100
  
  echo "🆕 Recently Added to Plex (Last $count)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local data
  data=$(tautulli_api "get_recently_added" "count=${count}")
  
  echo "$data" | jq -r '.response.data.recently_added[] | "\(.added_at | tonumber | strftime("%Y-%m-%d"))  \(.title) (\(.year // "N/A"))"'
  
  echo ""
}

# Command: play totals
cmd_play_totals() {
  echo "📊 Total Play Statistics"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local stats
  stats=$(tautulli_api "get_home_stats" "time_range=0&stats_count=1")
  
  # Extract total plays and duration from various stat types
  echo "$stats" | jq -r '.response.data[] | 
    if .rows then
      "  \(.stat_id): \(.rows[0].total_plays // 0) plays, \((.rows[0].total_duration // 0) / 3600 | floor)h total"
    else
      empty
    end' | head -10
  
  echo ""
  
  # Get overall server stats
  local activity
  activity=$(tautulli_api "get_activity")
  echo "Current Bandwidth: $(echo "$activity" | jq -r '.response.data.total_bandwidth') kbps"
  echo ""
}

# Main command router
COMMAND="${1:-help}"

case "$COMMAND" in
  activity)        cmd_activity ;;
  history)         cmd_history "${2:-20}" ;;
  most-watched)    cmd_most_watched "${2:-month}" ;;
  popular-genres)  cmd_popular_genres ;;
  peak-hours)      cmd_peak_hours ;;
  user-stats)      cmd_user_stats "${2:-}" ;;
  library-stats)   cmd_library_stats ;;
  recent-added)    cmd_recent_added "${2:-10}" ;;
  play-totals)     cmd_play_totals ;;
  help|--help|-h)  show_help ;;
  *)
    echo "❌ Unknown command: $COMMAND"
    echo "Run '$0 help' for usage"
    exit 1
    ;;
esac
