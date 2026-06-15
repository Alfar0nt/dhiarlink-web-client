#!/bin/bash
# Dhiarlink Web Client — Generate servers.json for bare metal deployment
#
# Usage:
#   ./scripts/bare-metal/setup-servers-json.sh
#
# Reads config from the project .env file (or environment variables) and
# writes build/servers.json so the dashboard auto-connects to the backend.
#
# This is the bare metal equivalent of scripts/docker/servers_from_env.sh
# (which runs automatically inside Docker via the entrypoint).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load .env if it exists
if [ -f "$PROJECT_ROOT/.env" ]; then
  set -a
  source "$PROJECT_ROOT/.env"
  set +a
fi

SERVER_URL="${DHIARLINK_SERVER_URL:-$SHLINK_SERVER_URL}"
SERVER_API_KEY="${DHIARLINK_SERVER_API_KEY:-$SHLINK_SERVER_API_KEY}"
SERVER_NAME="${DHIARLINK_SERVER_NAME:-${SHLINK_SERVER_NAME:-Dhiarlink}}"
SERVER_FORWARD_CREDENTIALS="${DHIARLINK_SERVER_FORWARD_CREDENTIALS:-${SHLINK_SERVER_FORWARD_CREDENTIALS:-false}}"

BUILD_DIR="$PROJECT_ROOT/build"
SERVERS_JSON="$BUILD_DIR/servers.json"

# Bail out if no URL configured
if [ -z "$SERVER_URL" ]; then
  echo "No DHIARLINK_SERVER_URL set — skipping servers.json"
  echo "[]" > "$SERVERS_JSON"
  exit 0
fi

# Bail out if no API key (intentional for public deployments)
if [ -z "$SERVER_API_KEY" ]; then
  echo "No DHIARLINK_SERVER_API_KEY set — no pre-configured server"
  echo "[]" > "$SERVERS_JSON"
  exit 0
fi

# Write servers.json
cat > "$SERVERS_JSON" <<EOF
[{"name":"${SERVER_NAME}","url":"${SERVER_URL}","apiKey":"${SERVER_API_KEY}","forwardCredentials":${SERVER_FORWARD_CREDENTIALS}}]
EOF

echo "servers.json written to $SERVERS_JSON"
echo "  Server: $SERVER_NAME ($SERVER_URL)"
