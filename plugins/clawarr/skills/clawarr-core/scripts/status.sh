#!/usr/bin/env bash
# status.sh - Check health status of all *arr services
# Usage: status.sh
#        Reads <SERVICE>_URL / <SERVICE>_API_KEY (or CLAWARR_HOST for http://host:port defaults)

set -euo pipefail

SONARR_API_KEY="${SONARR_API_KEY:-}"
RADARR_API_KEY="${RADARR_API_KEY:-}"
LIDARR_API_KEY="${LIDARR_API_KEY:-}"
READARR_API_KEY="${READARR_API_KEY:-}"
PROWLARR_API_KEY="${PROWLARR_API_KEY:-}"
BAZARR_API_KEY="${BAZARR_API_KEY:-}"
SEERR_API_KEY="${SEERR_API_KEY:-}"
PLEX_TOKEN="${PLEX_TOKEN:-}"
TAUTULLI_API_KEY="${TAUTULLI_API_KEY:-}"
SABNZBD_API_KEY="${SABNZBD_API_KEY:-}"

# Base URL per service: <SERVICE>_URL, else ${CLAWARR_SCHEME:-http}://$CLAWARR_HOST:<port>
arr_url() {
  if [[ -n "$1" ]]; then printf '%s' "${1%/}"
  elif [[ -n "${CLAWARR_HOST:-}" ]]; then printf '%s://%s:%s' "${CLAWARR_SCHEME:-http}" "$CLAWARR_HOST" "$2"
  fi
}
SONARR_URL="$(arr_url "${SONARR_URL:-}" "${SONARR_PORT:-8989}")"
RADARR_URL="$(arr_url "${RADARR_URL:-}" "${RADARR_PORT:-7878}")"
LIDARR_URL="$(arr_url "${LIDARR_URL:-}" "${LIDARR_PORT:-8686}")"
READARR_URL="$(arr_url "${READARR_URL:-}" "${READARR_PORT:-8787}")"
PROWLARR_URL="$(arr_url "${PROWLARR_URL:-}" "${PROWLARR_PORT:-9696}")"
BAZARR_URL="$(arr_url "${BAZARR_URL:-}" "${BAZARR_PORT:-6767}")"
SEERR_URL="$(arr_url "${SEERR_URL:-}" "${SEERR_PORT:-5055}")"
TAUTULLI_URL="$(arr_url "${TAUTULLI_URL:-}" "${TAUTULLI_PORT:-8181}")"
SABNZBD_URL="$(arr_url "${SABNZBD_URL:-}" "${SABNZBD_PORT:-8081}")"
# Plex base URL: PLEX_URL, else ${PLEX_SCHEME:-http}://${PLEX_HOST:-$CLAWARR_HOST}:${PLEX_PORT:-32400}
if [[ -z "${PLEX_URL:-}" && -n "${PLEX_HOST:-${CLAWARR_HOST:-}}" ]]; then
  PLEX_URL="${PLEX_SCHEME:-http}://${PLEX_HOST:-$CLAWARR_HOST}:${PLEX_PORT:-32400}"
fi
PLEX_URL="${PLEX_URL:-}"
PLEX_URL="${PLEX_URL%/}"

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required but not installed"
  echo "Install: brew install jq (macOS) or apt install jq (Linux)"
  exit 1
fi

echo "📊 Checking service health..."
echo ""

# fetch <url> [header] - prints the body on 2xx; otherwise prints the HTTP status (000 = unreachable) and fails
fetch() {
  local url=$1 header=${2:-} out code
  out=$(mktemp)
  if [[ -n "$header" ]]; then
    code=$(curl -sS -o "$out" -w '%{http_code}' --connect-timeout 3 --max-time 10 -H "$header" "$url" 2>/dev/null) || true
  else
    code=$(curl -sS -o "$out" -w '%{http_code}' --connect-timeout 3 --max-time 10 "$url" 2>/dev/null) || true
  fi
  if [[ "$code" == 2* ]]; then cat "$out"; rm -f "$out"; return 0; fi
  rm -f "$out"; printf '%s' "${code:-000}"; return 1
}

fail_reason() {
  case "$1" in
    401|403) echo "HTTP $1 (API key rejected)" ;;
    000) echo "unreachable" ;;
    *) echo "HTTP $1" ;;
  esac
}

check_service() {
  local name=$1
  local base=$2
  local api_key=$3
  local api_path=$4

  if [[ -z "$api_key" ]]; then
    echo "⚠️  $name - No API key provided (skipping)"
    return
  fi
  if [[ -z "$base" ]]; then
    echo "⚠️  $name - No URL configured (skipping)"
    return
  fi

  local response
  if ! response=$(fetch "${base}${api_path}" "X-Api-Key: ${api_key}"); then
    echo "❌ $name - $(fail_reason "$response") at ${base}"
    return
  fi

  # Parse health issues
  local issues
  if issues=$(echo "$response" | jq -r '.[] | select(.type != "info") | "\(.type): \(.message)"' 2>/dev/null); then
    if [[ -z "$issues" ]]; then
      echo "✅ $name - Healthy"
    else
      echo "⚠️  $name - Issues detected:"
      echo "$issues" | while read -r line; do
        echo "    $line"
      done
    fi
  else
    echo "✅ $name - Running"
  fi
}

# check_simple <name> <url> [header]
check_simple() {
  local name=$1 url=$2 header=${3:-} response
  if response=$(fetch "$url" "$header"); then
    echo "✅ $name - Running"
  else
    echo "❌ $name - $(fail_reason "$response")"
  fi
}

# Check each service
[[ -n "$SONARR_API_KEY" ]] && check_service "Sonarr" "$SONARR_URL" "$SONARR_API_KEY" "/api/v3/health"
[[ -n "$RADARR_API_KEY" ]] && check_service "Radarr" "$RADARR_URL" "$RADARR_API_KEY" "/api/v3/health"
[[ -n "$LIDARR_API_KEY" ]] && check_service "Lidarr" "$LIDARR_URL" "$LIDARR_API_KEY" "/api/v1/health"
[[ -n "$READARR_API_KEY" ]] && check_service "Readarr" "$READARR_URL" "$READARR_API_KEY" "/api/v1/health"
[[ -n "$PROWLARR_API_KEY" ]] && check_service "Prowlarr" "$PROWLARR_URL" "$PROWLARR_API_KEY" "/api/v1/health"
[[ -n "$BAZARR_API_KEY" ]] && check_service "Bazarr" "$BAZARR_URL" "$BAZARR_API_KEY" "/api/system/health"

[[ -n "$SEERR_API_KEY" && -n "$SEERR_URL" ]] && check_simple "Seerr" "${SEERR_URL}/api/v1/status" "X-Api-Key: ${SEERR_API_KEY}"
[[ -n "$PLEX_TOKEN" && -n "$PLEX_URL" ]] && check_simple "Plex" "${PLEX_URL}/identity" "X-Plex-Token: ${PLEX_TOKEN}"
[[ -n "$TAUTULLI_API_KEY" && -n "$TAUTULLI_URL" ]] && check_simple "Tautulli" "${TAUTULLI_URL}/api/v2?apikey=${TAUTULLI_API_KEY}&cmd=status"
[[ -n "$SABNZBD_API_KEY" && -n "$SABNZBD_URL" ]] && check_simple "SABnzbd" "${SABNZBD_URL}/api?mode=version&apikey=${SABNZBD_API_KEY}"

# Auto-detect companion services (no API key needed)
echo ""
echo "🔧 Companion Services:"

companion() {
  local name=$1 url=$2
  [[ -z "$url" ]] && return 0
  if curl -sf -o /dev/null --connect-timeout 3 "$url" 2>/dev/null; then
    echo "✅ $name - Running"
  fi
}
companion "FlareSolverr" "$(arr_url "${FLARESOLVERR_URL:-}" "${FLARESOLVERR_PORT:-8191}")"
companion "Maintainerr" "$(arr_url "${MAINTAINERR_URL:-}" "${MAINTAINERR_PORT:-6246}")"
companion "Notifiarr" "$(arr_url "${NOTIFIARR_URL:-}" "${NOTIFIARR_PORT:-5454}")"
companion "Homarr" "$(arr_url "${HOMARR_URL:-}" "${HOMARR_PORT:-7575}")"

echo ""
echo "✅ Health check complete"
