#!/bin/sh

set -e

ME=$(basename $0)

# In order to allow people to pre-configure a server in their dhiarlink-web-client instance via env vars, this function
# dumps a servers.json file based on the values provided via env vars
setup_single_dhiarlink_server() {
  [ -n "$DHIARLINK_SERVER_URL" ] || [ -n "$SHLINK_SERVER_URL" ] || return 0
  local url="${DHIARLINK_SERVER_URL:-$SHLINK_SERVER_URL}"
  local apiKey="${DHIARLINK_SERVER_API_KEY:-$SHLINK_SERVER_API_KEY}"
  [ -n "$apiKey" ] || return 0
  local name="${DHIARLINK_SERVER_NAME:-${SHLINK_SERVER_NAME:-Dhiarlink}}"
  local forwardCredentials="${DHIARLINK_SERVER_FORWARD_CREDENTIALS:-${SHLINK_SERVER_FORWARD_CREDENTIALS:-false}}"
  echo "[{\"name\":\"${name}\",\"url\":\"${url}\",\"apiKey\":\"${apiKey}\",\"forwardCredentials\":${forwardCredentials}}]" > /usr/share/nginx/html/servers.json
}

setup_single_dhiarlink_server

exit 0
