#!/usr/bin/env bash
# setup.sh - Configure one ClawARR service for OpenClaw
# Usage: setup.sh <service> <url>
#        setup.sh --list
#
# Where the API key goes depends on the URL scheme:
#   https://  -> OpenClaw shared secret store as a protected secret bound to the URL's host.
#                Agents only ever see a sentinel; the Gateway egress proxy swaps in the real
#                key on the way out. Requires secrets.egressProxy.enabled.
#   http://   -> plaintext in the OpenClaw global .env (${OPENCLAW_STATE_DIR:-~/.openclaw}/.env).
#                The egress proxy refuses plain HTTP, so store secrets cannot work there.
# <SERVICE>_URL always goes in the global .env. A key never lives in both places.
#
# The key is auto-detected from /initialize.json where the app exposes it and is never
# printed. When it can't be detected:
#   https -> exit 3: the agent should ask the user for it with the `secrets` tool
#   http  -> prompt for it (no echo) on a terminal, otherwise exit 4 with instructions
#
# Exit codes: 0 configured, 1 error, 2 usage, 3 key needed via secrets tool, 4 key needed manually
# Compatible with bash 3.2+ (macOS default).

set -euo pipefail

# CLAWARR_ENV_FILE overrides the target file (e.g. for testing)
ENV_FILE="${CLAWARR_ENV_FILE:-${OPENCLAW_STATE_DIR:-$HOME/.openclaw}/.env}"

usage() {
  sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

list_services() {
  echo "Services: sonarr radarr lidarr readarr prowlarr bazarr overseerr tautulli sabnzbd notifiarr plex"
}

# svc_info <service> -> sets PREFIX KEY_VAR LABEL AUTODETECT CHECK AUTH
svc_info() {
  AUTODETECT=no AUTH=header
  case "$1" in
    sonarr)    PREFIX=SONARR    LABEL=Sonarr    AUTODETECT=yes CHECK=/api/v3/system/status ;;
    radarr)    PREFIX=RADARR    LABEL=Radarr    AUTODETECT=yes CHECK=/api/v3/system/status ;;
    lidarr)    PREFIX=LIDARR    LABEL=Lidarr    AUTODETECT=yes CHECK=/api/v1/system/status ;;
    readarr)   PREFIX=READARR   LABEL=Readarr   AUTODETECT=yes CHECK=/api/v1/system/status ;;
    prowlarr)  PREFIX=PROWLARR  LABEL=Prowlarr  AUTODETECT=yes CHECK=/api/v1/system/status ;;
    bazarr)    PREFIX=BAZARR    LABEL=Bazarr    CHECK=/api/system/status ;;
    overseerr) PREFIX=OVERSEERR LABEL=Overseerr CHECK=/api/v1/request/count ;;
    tautulli)  PREFIX=TAUTULLI  LABEL=Tautulli  CHECK="/api/v2?cmd=get_tautulli_info" AUTH=query ;;
    sabnzbd)   PREFIX=SABNZBD   LABEL=SABnzbd   CHECK="/api?mode=queue&output=json&limit=1" AUTH=query ;;
    notifiarr) PREFIX=NOTIFIARR LABEL=Notifiarr CHECK="" ;;
    plex)      PREFIX=PLEX      LABEL=Plex      CHECK=/library/sections AUTH=plex ;;
    *) return 1 ;;
  esac
  KEY_VAR="${PREFIX}_API_KEY"
  [[ "$1" == plex ]] && KEY_VAR=PLEX_TOKEN
  return 0
}

# --- global .env helpers -----------------------------------------------------

env_has() { [[ -f "$ENV_FILE" ]] && grep -Eq "^(export[[:space:]]+)?$1=" "$ENV_FILE"; }

env_unset() {
  env_has "$1" || return 0
  local tmp
  tmp=$(mktemp)
  grep -Ev "^(export[[:space:]]+)?$1=" "$ENV_FILE" > "$tmp" || true
  cat "$tmp" > "$ENV_FILE"
  rm -f "$tmp"
}

# env_set <name> - value is read from stdin so it never appears in argv
env_set() {
  local value
  IFS= read -r value || true
  mkdir -p "$(dirname "$ENV_FILE")"
  touch "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  env_unset "$1"
  printf '%s=%s\n' "$1" "$value" >> "$ENV_FILE"
}

# --- store helpers -------------------------------------------------------------

store_hosts() {
  openclaw secrets store list --json 2>/dev/null \
    | jq -r --arg n "$1" '.[] | select(.name == $n) | .allowedHosts[]?' 2>/dev/null || true
}

store_has() {
  openclaw secrets store list --json 2>/dev/null \
    | jq -e --arg n "$1" 'any(.[]; .name == $n)' >/dev/null 2>&1
}

# --- key detection / verification ----------------------------------------------

detect_key() {
  local base=$1 resp key=""
  resp=$(curl -sf --connect-timeout 5 --max-time 15 "${base}/initialize.json" 2>/dev/null || true)
  [[ -n "$resp" ]] && key=$(printf '%s' "$resp" | jq -r '.apiKey // empty' 2>/dev/null || true)
  if [[ -z "$key" ]]; then
    resp=$(curl -sf --connect-timeout 5 --max-time 15 "${base}/initialize.js" 2>/dev/null || true)
    [[ -n "$resp" ]] && key=$(printf '%s' "$resp" | grep -o "apiKey: '[^']*'" | cut -d"'" -f2 || true)
  fi
  printf '%s' "$key"
}

# verify_key <base> <key> - 0 when the service accepts the key; prints a reason otherwise
verify_key() {
  local base=$1 key=$2 out code
  [[ -z "$CHECK" ]] && { echo "no authenticated check for $LABEL"; return 0; }
  out=$(mktemp)
  case "$AUTH" in
    header) code=$(curl -sS -o "$out" -w '%{http_code}' --connect-timeout 5 --max-time 15 -H "X-Api-Key: $key" "${base}${CHECK}" 2>/dev/null) || true ;;
    plex)   code=$(curl -sS -o "$out" -w '%{http_code}' --connect-timeout 5 --max-time 15 -H "X-Plex-Token: $key" -H "Accept: application/json" "${base}${CHECK}" 2>/dev/null) || true ;;
    query)  code=$(curl -sS -o "$out" -w '%{http_code}' --connect-timeout 5 --max-time 15 "${base}${CHECK}&apikey=${key}" 2>/dev/null) || true ;;
  esac
  local ok=1
  if [[ "$code" == 2* ]]; then
    ok=0
    # Tautulli and SABnzbd answer 200 with an error body for a bad key
    if [[ "$PREFIX" == TAUTULLI ]] && ! jq -e '.response.result == "success"' "$out" >/dev/null 2>&1; then ok=1; fi
    if [[ "$PREFIX" == SABNZBD ]] && jq -e '.status == false' "$out" >/dev/null 2>&1; then ok=1; fi
  fi
  rm -f "$out"
  [[ $ok -eq 0 ]] && return 0
  case "${code:-000}" in
    000) echo "unreachable" ;;
    401|403) echo "HTTP $code (key rejected)" ;;
    2*) echo "key rejected" ;;
    *) echo "HTTP $code" ;;
  esac
  return 1
}

# --- main ----------------------------------------------------------------------

[[ $# -ge 1 ]] || usage
case "$1" in
  -h|--help) usage ;;
  --list) list_services; exit 0 ;;
esac
[[ $# -eq 2 ]] || usage

SERVICE=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
URL="${2%/}"

if ! svc_info "$SERVICE"; then
  echo "❌ Unknown service: $1"; list_services; exit 2
fi
for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "❌ $bin is required"; exit 1; }
done

SCHEME="${URL%%://*}"
case "$SCHEME" in
  http|https) ;;
  *) echo "❌ URL must start with http:// or https:// (got: $URL)"; exit 2 ;;
esac
HOSTPORT="${URL#*://}"; HOSTPORT="${HOSTPORT%%/*}"
URL_HOST="${HOSTPORT%%:*}"
URL_HOST=$(printf '%s' "$URL_HOST" | tr '[:upper:]' '[:lower:]')

echo "🔧 $LABEL → $URL"

# Reachability (any HTTP answer counts; auth is checked later)
code=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 5 --max-time 15 "$URL/" 2>/dev/null || true)
if [[ -z "$code" || "$code" == 000 ]]; then
  echo "❌ $URL is not reachable from this host"
  exit 1
fi
echo "  ✅ reachable"

if [[ "$SCHEME" == https ]]; then
  command -v openclaw >/dev/null 2>&1 || {
    echo "❌ https needs the openclaw CLI (run this on the OpenClaw Gateway host)"; exit 1; }
  if [[ "$(openclaw config get secrets.egressProxy.enabled 2>/dev/null | tail -n1)" != "true" ]]; then
    echo "❌ The secret egress proxy is off, so store secrets would never reach $LABEL."
    echo "   Ask the user to enable it, then restart the Gateway:"
    echo "     openclaw config set secrets.egressProxy.enabled true --strict-json"
    echo "     openclaw gateway restart"
    exit 1
  fi
fi

# The URL is not a secret: it always goes in the global .env
printf '%s' "$URL" | env_set "${PREFIX}_URL"
echo "  ✅ ${PREFIX}_URL written to $ENV_FILE"

KEY=""
[[ "$AUTODETECT" == yes ]] && KEY=$(detect_key "$URL")

if [[ "$SCHEME" == https ]]; then
  # Keep any hosts the entry is already bound to and add this one
  HOSTS="$URL_HOST"
  for h in $(store_hosts "$KEY_VAR"); do
    [[ "$h" == "$URL_HOST" ]] || HOSTS="$HOSTS $h"
  done
  HOST_ARGS=()
  for h in $HOSTS; do HOST_ARGS+=(--allow-host "$h"); done

  if env_has "$KEY_VAR"; then
    env_unset "$KEY_VAR"
    echo "  ✅ removed plaintext $KEY_VAR from $ENV_FILE (it now lives in the secret store)"
  fi

  if [[ -n "$KEY" ]]; then
    if ! reason=$(verify_key "$URL" "$KEY"); then
      echo "❌ $LABEL rejected the auto-detected key: $reason"; exit 1
    fi
    printf '%s' "$KEY" | openclaw secrets store set "$KEY_VAR" --kind secret --value-file - "${HOST_ARGS[@]}" >/dev/null
    KEY=""
    echo "  ✅ $KEY_VAR stored as a protected secret (hosts: $HOSTS)"
  elif store_has "$KEY_VAR"; then
    # Already stored: just make sure this host is allowed
    openclaw secrets store set "$KEY_VAR" "${HOST_ARGS[@]}" >/dev/null
    echo "  ✅ $KEY_VAR already in the secret store; allowed hosts: $HOSTS"
  else
    echo ""
    echo "  ⚠️  Could not auto-detect the $LABEL key. Ask the user for it with the secrets tool:"
    printf '  SECRETS_REQUEST %s\n' "$(jq -cn --arg n "$KEY_VAR" --arg h "$URL_HOST" --arg l "$LABEL" \
      '{action: "request", name: $n, allowedHosts: [$h], reason: ("ClawARR needs the " + $l + " API key to call " + $h)}')"
    exit 3
  fi
  if [[ -n "${!KEY_VAR:-}" && "${!KEY_VAR}" != oc-sent-* ]]; then
    echo "  ⚠️  $KEY_VAR is also set as a plaintext process variable (container/service env)."
    echo "     Remove it there, or it may shadow the store secret."
  fi
  echo ""
  echo "✅ $LABEL configured. Store changes reach new agent runs only;"
  echo "   ${PREFIX}_URL is in $ENV_FILE, which the Gateway reads at start: restart it once"
  echo "   (openclaw gateway restart), then verify in a new run with scripts/status.sh."
  exit 0
fi

# --- http: plaintext key in the global .env ------------------------------------
if store_has "$KEY_VAR" 2>/dev/null; then
  echo "  ⚠️  $KEY_VAR also exists in the OpenClaw secret store. One name must have one source:"
  echo "     ask the user to remove it with: openclaw secrets store rm $KEY_VAR"
fi

if [[ -z "$KEY" ]]; then
  if [[ -t 0 ]]; then
    read -rsp "  Enter the $LABEL API key (input hidden): " KEY; echo
  else
    echo ""
    echo "  ⚠️  Could not auto-detect the $LABEL key, and plain HTTP cannot use the secret store."
    echo "     Ask the user to add this line to $ENV_FILE themselves (never paste keys into chat):"
    echo "       $KEY_VAR=<their $LABEL API key>"
    echo "     or to run this script in a terminal, or to serve $LABEL over HTTPS instead."
    exit 4
  fi
fi
[[ -n "$KEY" ]] || { echo "❌ No key entered"; exit 1; }

if ! reason=$(verify_key "$URL" "$KEY"); then
  echo "❌ $LABEL rejected the key: $reason"; exit 1
fi
printf '%s' "$KEY" | env_set "$KEY_VAR"
KEY=""
echo "  ✅ $KEY_VAR written to $ENV_FILE"
echo ""
echo "✅ $LABEL configured. The Gateway reads $ENV_FILE at start: restart it"
echo "   (openclaw gateway restart), then verify in a new run with scripts/status.sh."
