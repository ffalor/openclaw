#!/usr/bin/env bash
# search.sh - Unified search across Radarr/Sonarr/Lidarr
# Usage: search.sh "<query>" <type>
#   type: movie, series, music

set -euo pipefail

QUERY="${1:-}"
TYPE="${2:-movie}"

# Base URL per service: <SERVICE>_URL, else ${CLAWARR_SCHEME:-http}://$CLAWARR_HOST:<port>
arr_url() {
  if [[ -n "$1" ]]; then printf '%s' "${1%/}"
  elif [[ -n "${CLAWARR_HOST:-}" ]]; then printf '%s://%s:%s' "${CLAWARR_SCHEME:-http}" "$CLAWARR_HOST" "$2"
  fi
}
RADARR_URL="$(arr_url "${RADARR_URL:-}" "${RADARR_PORT:-7878}")"
SONARR_URL="$(arr_url "${SONARR_URL:-}" "${SONARR_PORT:-8989}")"
LIDARR_URL="$(arr_url "${LIDARR_URL:-}" "${LIDARR_PORT:-8686}")"
RADARR_API_KEY="${RADARR_API_KEY:-}"
SONARR_API_KEY="${SONARR_API_KEY:-}"
LIDARR_API_KEY="${LIDARR_API_KEY:-}"

if [[ -z "$QUERY" ]]; then
  echo "Usage: $0 \"<query>\" <type>"
  echo ""
  echo "Types: movie, series, music"
  echo ""
  echo "Examples:"
  echo "  $0 \"dune\" movie"
  echo "  $0 \"foundation\" series"
  echo "  $0 \"pink floyd\" music"
  echo ""
  echo "Requires: RADARR_URL/SONARR_URL/LIDARR_URL (or CLAWARR_HOST), RADARR_API_KEY/SONARR_API_KEY/LIDARR_API_KEY environment variables"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is required but not installed"
  exit 1
fi

# URL encode query
ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)

case "$TYPE" in
  movie)
    if [[ -z "$RADARR_API_KEY" || -z "$RADARR_URL" ]]; then
      echo "Error: RADARR_API_KEY and RADARR_URL (or CLAWARR_HOST) must be set"
      exit 1
    fi
    
    echo "🎬 Searching Radarr for: $QUERY"
    echo ""
    
    results=$(curl -sSf -H "X-Api-Key: ${RADARR_API_KEY}" \
      "${RADARR_URL}/api/v3/movie/lookup?term=${ENCODED_QUERY}" || echo '[]')
    
    count=$(echo "$results" | jq 'length')
    
    if [[ "$count" -eq 0 ]]; then
      echo "No results found"
    else
      echo "Found $count result(s):"
      echo ""
      echo "$results" | jq -r '.[] | "• \(.title) (\(.year))\n  TMDB: \(.tmdbId) | Rating: \(.ratings.imdb.value // "N/A")\n  \(.overview[0:150])...\n"' | head -20
    fi
    ;;
    
  series)
    if [[ -z "$SONARR_API_KEY" || -z "$SONARR_URL" ]]; then
      echo "Error: SONARR_API_KEY and SONARR_URL (or CLAWARR_HOST) must be set"
      exit 1
    fi
    
    echo "📺 Searching Sonarr for: $QUERY"
    echo ""
    
    results=$(curl -sSf -H "X-Api-Key: ${SONARR_API_KEY}" \
      "${SONARR_URL}/api/v3/series/lookup?term=${ENCODED_QUERY}" || echo '[]')
    
    count=$(echo "$results" | jq 'length')
    
    if [[ "$count" -eq 0 ]]; then
      echo "No results found"
    else
      echo "Found $count result(s):"
      echo ""
      echo "$results" | jq -r '.[] | "• \(.title) (\(.year // "N/A"))\n  TVDB: \(.tvdbId) | Seasons: \(.seasons | length)\n  \(.overview[0:150])...\n"' | head -20
    fi
    ;;
    
  music)
    if [[ -z "$LIDARR_API_KEY" || -z "$LIDARR_URL" ]]; then
      echo "Error: LIDARR_API_KEY and LIDARR_URL (or CLAWARR_HOST) must be set"
      exit 1
    fi
    
    echo "🎵 Searching Lidarr for: $QUERY"
    echo ""
    
    results=$(curl -sSf -H "X-Api-Key: ${LIDARR_API_KEY}" \
      "${LIDARR_URL}/api/v1/search?term=${ENCODED_QUERY}" || echo '[]')
    
    count=$(echo "$results" | jq 'length')
    
    if [[ "$count" -eq 0 ]]; then
      echo "No results found"
    else
      echo "Found $count result(s):"
      echo ""
      echo "$results" | jq -r '.[] | "• \(.artistName) - \(.albumTitle // "Artist")\n  Type: \(.albumType // "Artist") | Year: \(.releaseDate[0:4] // "N/A")\n"' | head -20
    fi
    ;;
    
  *)
    echo "Error: Unknown type '$TYPE'"
    echo "Valid types: movie, series, music"
    exit 1
    ;;
esac
