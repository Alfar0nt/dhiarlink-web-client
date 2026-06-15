#!/bin/bash
# Dhiarlink Web Client — Bare Metal Deploy Script
# Usage: ./deploy-bare-metal.sh
#
# Builds the production bundle and updates the nginx-served static files.
# Run after `git pull` to deploy updates on a bare metal / LXC server.
#
# Prerequisites:
#   - Node.js 22+ installed
#   - nginx installed and configured (see config/bare-metal/nginx.conf)
#   - Project cloned to /opt/dhiarlink-web-client (or adjust PROJECT_DIR below)
#
# Configuration:
#   Option A: Create a .env file in the project root (see .env.example)
#   Option B: Export env vars before running

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Dhiarlink Web Client — Bare Metal Deploy"
echo "    Project: $PROJECT_DIR"
echo ""

# Load .env file if it exists
if [ -f "$PROJECT_DIR/.env" ]; then
  echo "==> Loading config from .env"
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

# --- Step 1: Install dependencies (cached unless package.json/lock changed) ---
echo "==> Installing dependencies..."
cd "$PROJECT_DIR"
npm ci --silent 2>/dev/null || npm ci

# --- Step 2: Build production bundle ---
echo "==> Building production bundle..."
npm run build

# --- Step 3: Generate servers.json (optional pre-configured server) ---
echo "==> Setting up servers.json..."
bash "$PROJECT_DIR/scripts/bare-metal/setup-servers-json.sh"

# --- Step 4: Verify nginx is serving the build ---
echo ""
echo "==> Done! Build output is at: $PROJECT_DIR/build/"
echo ""

# Check if nginx is configured and running
if command -v nginx &>/dev/null; then
  if nginx -t 2>/dev/null; then
    echo "==> Reloading nginx..."
    sudo systemctl reload nginx 2>/dev/null || sudo nginx -s reload 2>/dev/null || true
    echo "    nginx reloaded."
  else
    echo "    WARNING: nginx config test failed. Run: sudo nginx -t"
  fi
else
  echo "    NOTE: nginx not found. Make sure your web server is serving $PROJECT_DIR/build/"
fi

echo ""
echo "==> Deployment complete!"
echo "    Build:   $PROJECT_DIR/build/"
echo "    Config:  /etc/nginx/sites-available/dhiarlink-dashboard"
echo ""
echo "    To verify:  curl -s http://127.0.0.1:8081 | head -5"
echo "    Dashboard:  https://app.dhiarr.qzz.io"
