#!/bin/bash
# Dhiarlink Web Client — Production Redeploy Script
# Usage: ./deploy.sh
#
# Rebuilds the production Docker image and recreates the container.
# Run after `git pull` to deploy updates.
#
# Configuration:
#   Option A: Create a .env file next to this script (see .env.example)
#   Option B: Export env vars before running (e.g., export DHIARLINK_SERVER_API_KEY=xxx)

set -e

IMAGE_NAME="dhiarlink-web-client"
CONTAINER_NAME="dhiarlink_dashboard"

# Load .env file if it exists
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  echo "==> Loading config from .env"
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

# Defaults
SERVER_URL="${DHIARLINK_SERVER_URL:-https://www.dhiarr.qzz.io}"
SERVER_API_KEY="${DHIARLINK_SERVER_API_KEY:-}"
SERVER_NAME="${DHIARLINK_SERVER_NAME:-Dhiarlink}"
SERVER_FORWARD_CREDENTIALS="${DHIARLINK_SERVER_FORWARD_CREDENTIALS:-false}"
DOCKER_NETWORK="${DOCKER_NETWORK:-}"

if [ -z "$SERVER_API_KEY" ]; then
  echo "    WARNING: DHIARLINK_SERVER_API_KEY is not set."
  echo "    The dashboard will start without a pre-configured server."
  echo "    Set it in .env or via: export DHIARLINK_SERVER_API_KEY=your-key"
  echo ""
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_TAR="$SCRIPT_DIR/dhiarlink-web-client.tar.gz"

# If a pre-built image tarball exists, load it instead of building
if [ -f "$IMAGE_TAR" ]; then
  echo "==> Loading pre-built image from $IMAGE_TAR"
  docker load -i "$IMAGE_TAR"
  echo "    Removing tarball to free space..."
  rm -f "$IMAGE_TAR"
else
  echo "==> Building production image..."
  echo "    (first build: ~5 min, subsequent builds: ~30s thanks to layer caching)"
  docker build -t "$IMAGE_NAME":latest .
fi

echo "==> Stopping old container (if exists)..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "==> Starting new container..."

# Build the docker run command
RUN_ARGS=(
  -d
  --name "$CONTAINER_NAME"
  --restart unless-stopped
  -e DHIARLINK_SERVER_URL="$SERVER_URL"
  -e DHIARLINK_SERVER_API_KEY="$SERVER_API_KEY"
  -e DHIARLINK_SERVER_NAME="$SERVER_NAME"
  -e DHIARLINK_SERVER_FORWARD_CREDENTIALS="$SERVER_FORWARD_CREDENTIALS"
)

# Attach to Docker network if specified (needed for Caddy reverse proxy)
if [ -n "$DOCKER_NETWORK" ]; then
  RUN_ARGS+=(--network "$DOCKER_NETWORK")
fi

docker run "${RUN_ARGS[@]}" "$IMAGE_NAME":latest

echo ""
echo "==> Done! Container '$CONTAINER_NAME' is running."
echo "    Image:   $IMAGE_NAME:latest"
echo "    Network: ${DOCKER_NETWORK:-default}"
echo ""
echo "    To check:  docker ps | grep $CONTAINER_NAME"
echo "    To logs:   docker logs -f $CONTAINER_NAME"
