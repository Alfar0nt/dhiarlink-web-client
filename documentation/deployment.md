# Dhiarlink Web Client — Deployment Guide

> Full guide for running the Dhiarlink dashboard locally for development/testing and deploying to production via Cloudflare Tunnel — supports both Docker and bare metal deployments.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
    - [1. Clone and Install](#1-clone-and-install)
    - [2. Start the Dev Server](#2-start-the-dev-server)
    - [3. Connect to Your Dhiarlink Backend](#3-connect-to-your-dhiarlink-backend)
    - [4. Available Scripts](#4-available-scripts)
- [Production Build](#production-build)
    - [Static Files](#static-files)
    - [Docker Image](#docker-image)
- [Quick Redeploy — Docker](#quick-redeploy--docker)
- [Quick Redeploy — Bare Metal](#quick-redeploy--bare-metal)
- [Bare Metal Deployment (No Docker)](#bare-metal-deployment-no-docker)
    - [Migrating from Docker to Bare Metal](#migrating-from-docker-to-bare-metal)
    - [Step 1: Clean Up Docker Deployment](#step-1-clean-up-docker-deployment)
    - [Step 2: Install Node.js 22](#step-2-install-nodejs-22)
    - [Step 3: Clone and Build the Dashboard](#step-3-clone-and-build-the-dashboard)
    - [Step 4: Configure nginx](#step-4-configure-nginx)
    - [Step 5: Configure Server Pre-connection (Optional)](#step-5-configure-server-pre-connection-optional)
    - [Step 6: Verify the Dashboard](#step-6-verify-the-dashboard)
- [Production Deployment with Cloudflare Tunnel](#production-deployment-with-cloudflare-tunnel)
    - [Option A: Cloudflared on Your Server](#option-a-cloudflared-on-your-server)
    - [Option B: Cloudflare Tunnel via Dashboard](#option-b-cloudflare-tunnel-via-dashboard)
- [Pre-configuring a Server (Docker)](#pre-configuring-a-server-docker)
- [Environment Variables Reference](#environment-variables-reference)
- [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                         DNS / Tunnel                              │
│                                                                   │
│  www.dhiarr.qzz.io  → Dhiarlink backend  (PHP REST API)          │
│  app.dhiarr.qzz.io  → This project       (React SPA dashboard)   │
│  link.dhiarr.qzz.io → Dhiarlink backend  (short URL redirects)   │
└──────────────────────────────────────────────────────────────────┘

The web client (this repo) is a static React PWA.
It connects to the Dhiarlink REST API at https://www.dhiarr.qzz.io/rest/v3/...
No server-side rendering — just static files served by nginx or any HTTP server.
```

---

## Prerequisites

### For Docker Deployment

| Tool | Version | Purpose |
|------|---------|--------|
| Node.js | >= 22.x | JavaScript runtime (build only) |
| npm | >= 10.x | Package manager |
| Docker | >= 24.x | Container runtime |
| Docker Compose | >= 2.x | Multi-container orchestration |
| Git | >= 2.x | Version control |

### For Bare Metal Deployment

| Tool | Version | Purpose |
|------|---------|--------|
| Node.js | >= 22.x | Build the React app (one-time) |
| npm | >= 10.x | Package manager |
| nginx | >= 1.25 | Serve static files on port 8081 |
| Git | >= 2.x | Clone and pull updates |

### Common Requirements

- A Cloudflare account (free tier works)
- `cloudflared` CLI installed on your server
- The Dhiarlink backend running and accessible

---

## Local Development

### 1. Clone and Install

```bash
# Navigate to the project directory
cd /path/to/dhiarlink-web-client

# Install dependencies
npm install
```

### 2. Start the Dev Server

```bash
npm start
```

This starts the Vite dev server on **http://localhost:3000** with hot module replacement.

To also expose on your local network (for mobile testing):
```bash
# The server already binds to 0.0.0.0, so it's accessible on your LAN
# Find your IP with: ip addr show
# Then open: http://<your-lan-ip>:3000
```

### 3. Connect to Your Dhiarlink Backend

Once the dashboard opens at `http://localhost:3000`, you'll see the welcome screen.

**Option A: Add server via UI**

1. Click **"Add a server"**
2. Fill in:
   - **Name:** `Dhiarlink (local)`
   - **URL:** `http://localhost:8000` (if running backend locally via docker-compose) or `https://www.dhiarr.qzz.io`
   - **API key:** Generate one via `bin/cli api-key:generate` in the backend

**Option B: Pre-configure via `servers.json`**

Create `public/servers.json`:
```json
[
  {
    "name": "Dhiarlink (local)",
    "url": "http://localhost:8000",
    "apiKey": "your-api-key-here"
  }
]
```

The dev server will pick this up automatically.

### 4. Available Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start Vite dev server on port 3000 |
| `npm run build` | Type-check + production build to `build/` |
| `npm run preview` | Preview the production build locally |
| `npm test` | Run the test suite |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Auto-fix lint issues |
| `npm run types` | Type-check without building |

---

## Production Build

### Static Files

```bash
# Build the production bundle
npm run build
```

This outputs optimized static files to `build/`:
```
build/
├── index.html
├── manifest.json
├── service-worker.js
├── assets/
│   ├── index-*.css     (60 KB, gzipped: 11 KB)
│   └── index-*.js      (1.4 MB, gzipped: 417 KB)
├── icons/
│   └── icon-*.png
└── favicon.*
```

Serve these files with any static HTTP server (nginx, Caddy, Apache, `python -m http.server`, etc.).

### Docker Image

```bash
# Build the Docker image
docker build -t dhiarlink-web-client .

# Run it
docker run -d \
  --name dhiarlink_web_client \
  -p 8080:8080 \
  dhiarlink-web-client
```

The container runs nginx on port **8080** as a non-root user (UID 101).

To pre-configure a server:
```bash
docker run -d \
  --name dhiarlink_web_client \
  -p 8080:8080 \
  -e DHIARLINK_SERVER_URL=https://www.dhiarr.qzz.io \
  -e DHIARLINK_SERVER_API_KEY=your-api-key \
  -e DHIARLINK_SERVER_NAME="Dhiarlink Production" \
  dhiarlink-web-client
```

---

## Quick Redeploy — Docker

For day-to-day updates after pushing to GitHub, use the included `deploy.sh` script:

```bash
git pull && ./deploy.sh
```

This single command will:
1. Pull the latest code from GitHub
2. Load your production config from `.env`
3. Rebuild the Docker image
4. Stop and remove the old container
5. Start a new container on the correct Docker network

### First-Time Setup

```bash
# 1. Create .env from template
cp .env.example .env

# 2. Edit with your values (API key, Docker network)
nano .env

# 3. Deploy
./deploy.sh
```

The `.env` file is gitignored, so your API key and network config are never committed.

### `.env` Reference

| Variable | Example | Description |
|----------|---------|-------------|
| `DHIARLINK_SERVER_URL` | `https://www.dhiarr.qzz.io` | Backend API URL |
| `DHIARLINK_SERVER_API_KEY` | *(empty or your key)* | Pre-configures a default server |
| `DHIARLINK_SERVER_NAME` | `Dhiarlink` | Display name in dashboard |
| `DHIARLINK_SERVER_FORWARD_CREDENTIALS` | `false` | Forward browser credentials |
| `DOCKER_NETWORK` | `dhiarlink_dhiarlink_internal` | Network shared with Caddy |

> **Tip:** If `DHIARLINK_SERVER_API_KEY` is empty, visitors must manually add a server via the UI. This is intentional — it avoids exposing API keys in the client-side `servers.json`.

---

## Quick Redeploy — Bare Metal

For bare metal / LXC deployments (no Docker), use the `deploy-bare-metal.sh` script:

```bash
cd /opt/dhiarlink-web-client
git pull && ./deploy-bare-metal.sh
```

This will:
1. Load config from `.env`
2. Run `npm ci` (cached unless package files changed)
3. Build the production bundle to `build/`
4. Generate `servers.json` (if API key is configured)
5. Reload nginx

See the [Bare Metal Deployment](#bare-metal-deployment-no-docker) section below for the full first-time setup guide.

---

## Bare Metal Deployment (No Docker)

This guide deploys the Dhiarlink dashboard natively on Debian 13 — no Docker, no containers. The dashboard is a static React SPA served by nginx on port 8081, with Caddy reverse proxy routing `app.dhiarr.qzz.io` → `127.0.0.1:8081`.

> **Prerequisite:** The Dhiarlink backend must already be deployed on bare metal (see `../dhiarlink/documentation/deployment.md` → Bare Metal Deployment section). This guide assumes Caddy, RoadRunner, MariaDB, and Redis are already running.

### Architecture

```
                          Cloudflare Edge (TLS termination)
                          ├── www.dhiarr.qzz.io   (landing page)
                          ├── app.dhiarr.qzz.io   (dashboard UI)
                          └── link.dhiarr.qzz.io  (short URL redirects)
                                    │
                          Cloudflare Tunnel (encrypted)
                                    │
                     ┌──────────────▼──────────────┐
                     │  Caddy 2 (port 3000)         │
                     └────┬────────────┬───────────┘
                          │            │
                     ┌────▼──────┐ ┌───▼─────────────┐
                     │ RoadRunner │ │ nginx (port 8081)│
                     │ (port 8080)│ │ Dashboard SPA    │
                     └──┬──────┬─┘ └──────────────────┘
                        │      │
                     ┌───▼───┐ ┌─▼─────┐
                     │MariaDB│ │Redis  │
                     └───────┘ └───────┘
```

The dashboard (this project) runs on nginx at `127.0.0.1:8081`. Caddy routes all requests for `app.dhiarr.qzz.io` to it.

### Prerequisites

| Software | Version | Purpose |
|----------|---------|--------|
| Node.js | 22+ LTS | Build the React app (one-time, only on deploy) |
| npm | 10+ | Package manager |
| nginx | 1.25+ | Serve static files on port 8081 |
| Git | 2+ | Clone and pull updates |
| Caddy | 2.x | Already installed with the backend |

---

### Migrating from Docker to Bare Metal

If you previously ran the dashboard via Docker (`dhiarlink_dashboard` container), clean it up first:

### Step 1: Clean Up Docker Deployment

```bash
# Stop and remove the dashboard container
docker stop dhiarlink_dashboard 2>/dev/null || true
docker rm dhiarlink_dashboard 2>/dev/null || true

# Remove the Docker image
docker rmi dhiarlink-web-client:latest 2>/dev/null || true

# Verify it's gone
docker ps -a | grep dhiarlink_dashboard
# Should return nothing

# Remove deploy.sh and .env (Docker-specific, bare metal uses different files)
rm -f deploy.sh
# Keep .env if you want to reuse the same values for bare metal
```

> **Note:** Do NOT stop or remove the other Docker containers (`dhiarlink`, `dhiarlink_caddy`, `dhiarlink_redis`, `dhiarlink_db`) if you're running the backend via Docker. This guide only replaces the dashboard container with a bare metal nginx setup.

If you're also migrating the backend from Docker to bare metal, follow `../dhiarlink/documentation/deployment.md` → "Migrating from Docker to Bare Metal" first, then continue here.

---

### Step 2: Install Node.js 22

Node.js is only needed to build the dashboard. Once built, nginx serves the static files — Node.js is not required at runtime.

```bash
# Install Node.js 22 LTS (Debian 13)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Verify
node --version   # Should be v22.x
npm --version    # Should be 10+
```

---

### Step 3: Clone and Build the Dashboard

```bash
# Clone the dashboard repo (sibling to the backend)
sudo git clone <your-web-client-repo-url> /opt/dhiarlink-web-client
sudo chown -R $USER:$USER /opt/dhiarlink-web-client

cd /opt/dhiarlink-web-client

# Create .env from template (optional — for server pre-configuration)
cp .env.example .env
nano .env
# Set DHIARLINK_SERVER_API_KEY if you want a pre-configured server
# Leave it empty if you want visitors to add the server manually

# Install dependencies and build
npm ci
npm run build
```

The build outputs static files to `build/`:
```
build/
├── index.html
├── manifest.json
├── service-worker.js
├── assets/
│   ├── vendor-react-*.js
│   ├── vendor-redux-*.js
│   ├── vendor-router-*.js
│   ├── vendor-icons-*.js
│   ├── index-*.js
│   └── index-*.css
├── icons/
│   └── icon-*.png
└── favicon.*
```

---

### Step 4: Configure nginx

```bash
# Install nginx (if not already installed)
sudo apt install -y nginx

# Copy the bare metal nginx config
sudo cp /opt/dhiarlink-web-client/config/bare-metal/nginx.conf \
  /etc/nginx/sites-available/dhiarlink-dashboard

# Enable the site
sudo ln -sf /etc/nginx/sites-available/dhiarlink-dashboard /etc/nginx/sites-enabled/

# Remove default site (if it conflicts on port 80)
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# Verify nginx is listening on port 8081
sudo ss -tlnp | grep 8081
# Should show: 127.0.0.1:8081
```

> **Important:** The nginx config in `config/bare-metal/nginx.conf` is set up to listen on `127.0.0.1:8081` and serve files from `/opt/dhiarlink-web-client/build`. This matches the backend's `Caddyfile.bare-metal` which routes `app.dhiarr.qzz.io` → `127.0.0.1:8081`.

---

### Step 5: Configure Server Pre-connection (Optional)

If you want a pre-configured server to appear automatically when users visit the dashboard, set the API key in `.env` and run the setup script:

```bash
# Edit .env
nano /opt/dhiarlink-web-client/.env

# Set these values:
# DHIARLINK_SERVER_URL=https://www.dhiarr.qzz.io
# DHIARLINK_SERVER_API_KEY=your-api-key-here
# DHIARLINK_SERVER_NAME=Dhiarlink
# DHIARLINK_SERVER_FORWARD_CREDENTIALS=false

# Generate servers.json
bash /opt/dhiarlink-web-client/scripts/bare-metal/setup-servers-json.sh
```

This writes `build/servers.json` which the dashboard reads on load.

> **Security note:** Since `servers.json` is a static file served to browsers, the API key is visible to anyone who visits the dashboard URL. For public deployments, leave `DHIARLINK_SERVER_API_KEY` empty so visitors must add the server manually.

---

### Step 6: Verify the Dashboard

```bash
# Test nginx is serving the dashboard
curl -s http://127.0.0.1:8081 | head -5
# Should return HTML starting with <!doctype html>

# Test through Caddy (must be running with Caddyfile.bare-metal)
curl -s -H "Host: app.dhiarr.qzz.io" http://localhost:3000 | head -5

# Check all services are running
sudo systemctl status dhiarlink     # RoadRunner (backend)
sudo systemctl status caddy         # Reverse proxy
sudo systemctl status nginx         # Dashboard
sudo systemctl status mariadb       # Database
sudo systemctl status redis-server  # Cache
sudo systemctl status cloudflared   # Tunnel
```

Then open in your browser: **https://app.dhiarr.qzz.io**

---

### Bare Metal Maintenance

#### Updating the Dashboard

```bash
cd /opt/dhiarlink-web-client
git pull && ./deploy-bare-metal.sh
```

The `deploy-bare-metal.sh` script handles everything: `npm ci` → `npm run build` → `servers.json` → nginx reload.

#### Viewing Logs

```bash
# nginx access and error logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# nginx service status
sudo systemctl status nginx
sudo journalctl -u nginx -f
```

#### Manual Rebuild

If you need to rebuild without pulling:

```bash
cd /opt/dhiarlink-web-client
npm run build
bash scripts/bare-metal/setup-servers-json.sh
sudo systemctl reload nginx
```

---

## Production Deployment with Cloudflare Tunnel

This is the recommended approach for deploying to `app.dhiarr.qzz.io`.

### Option A: Cloudflared on Your Server

**Step 1: Install cloudflared**

```bash
# Debian/Ubuntu
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt update && sudo apt install cloudflared
```

**Step 2: Authenticate**

```bash
cloudflared tunnel login
```

This opens a browser to authorize your Cloudflare account. Select the `dhiarr.qzz.io` domain.

**Step 3: Create a tunnel**

```bash
cloudflared tunnel create dhiarlink-web-client
# Note the tunnel ID: <TUNNEL_ID>
# Note the credentials file: ~/.cloudflared/<TUNNEL_ID>.json
```

**Step 4: Configure the tunnel**

Create `~/.cloudflared/config.yml`:
```yaml
tunnel: <TUNNEL_ID>
credentials-file: /home/<user>/.cloudflared/<TUNNEL_ID>.json

ingress:
  # Dhiarlink web client dashboard
  - hostname: app.dhiarr.qzz.io
    service: http://localhost:8080
    originRequest:
      noTLSVerify: true

  # Dhiarlink backend API (if also tunneling from same server)
  - hostname: www.dhiarr.qzz.io
    service: http://localhost:8000

  # Short URL domain (same backend)
  - hostname: link.dhiarr.qzz.io
    service: http://localhost:8000

  # Catch-all (required)
  - service: http_status:404
```

**Step 5: Create DNS records**

```bash
# Point the subdomains to the tunnel
cloudflared tunnel route dns dhiarlink-web-client app.dhiarr.qzz.io
cloudflared tunnel route dns dhiarlink-web-client www.dhiarr.qzz.io
cloudflared tunnel route dns dhiarlink-web-client link.dhiarr.qzz.io
```

**Step 6: Run the Dhiarlink web client container**

```bash
docker run -d \
  --name dhiarlink_web_client \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DHIARLINK_SERVER_URL=https://www.dhiarr.qzz.io \
  -e DHIARLINK_SERVER_API_KEY=your-api-key \
  -e DHIARLINK_SERVER_NAME="Dhiarlink" \
  dhiarlink-web-client
```

**Step 7: Run the tunnel as a service**

```bash
# Start the tunnel
cloudflared tunnel run dhiarlink-web-client

# Or install as a system service (auto-start on boot)
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

**Step 8: Verify**

```bash
# Check tunnel status
cloudflared tunnel info dhiarlink-web-client

# Test the dashboard
curl -I https://app.dhiarr.qzz.io
# Should return HTTP 200
```

### Option B: Cloudflare Tunnel via Dashboard

If you prefer GUI management:

1. Go to **Cloudflare Zero Trust** > **Networks** > **Tunnels**
2. Click **Create a tunnel** > choose **Cloudflared**
3. Name it `dhiarlink-web-client`
4. Copy the install token and run it on your server
5. Add public hostnames:
   - `app.dhiarr.qzz.io` → `http://localhost:8080`
   - `www.dhiarr.qzz.io` → `http://localhost:8000` (if applicable)
   - `link.dhiarr.qzz.io` → `http://localhost:8000` (if applicable)
6. Enable **TLS** in the tunnel settings for automatic HTTPS

---

## Pre-configuring a Server (Docker)

When running the web client via Docker, you can pre-configure the Dhiarlink server connection using environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DHIARLINK_SERVER_URL` | Base URL of the Dhiarlink API | `https://www.dhiarr.qzz.io` |
| `DHIARLINK_SERVER_API_KEY` | API key for authentication | `your-api-key-here` |
| `DHIARLINK_SERVER_NAME` | Display name in the dashboard | `Dhiarlink Production` |
| `DHIARLINK_SERVER_FORWARD_CREDENTIALS` | Forward browser credentials | `false` |

Legacy `SHLINK_*` variables are also supported for backward compatibility.

Alternatively, mount a `servers.json` file:
```bash
docker run -d \
  -p 8080:8080 \
  -v ./servers.json:/usr/share/nginx/html/servers.json:ro \
  dhiarlink-web-client
```

Where `servers.json` contains:
```json
[
  {
    "name": "Dhiarlink Production",
    "url": "https://www.dhiarr.qzz.io",
    "apiKey": "your-api-key-here",
    "autoConnect": true
  }
]
```

Setting `autoConnect: true` will automatically redirect to this server when the dashboard loads.

---

## Environment Variables Reference

### Web Client (this project)

| Variable | Context | Default | Description |
|----------|---------|---------|-------------|
| `NODE_ENV` | Build | `development` | Set to `production` for optimized builds |
| `DHIARLINK_SERVER_URL` | Docker runtime | — | Pre-configured server URL |
| `DHIARLINK_SERVER_API_KEY` | Docker runtime | — | Pre-configured API key |
| `DHIARLINK_SERVER_NAME` | Docker runtime | `Dhiarlink` | Pre-configured server name |
| `DHIARLINK_SERVER_FORWARD_CREDENTIALS` | Docker runtime | `false` | Forward credentials flag |

### Backend (Dhiarlink at `../dhiarlink`)

The backend needs these key variables (see `../dhiarlink/.env.example` for full reference):

| Variable | Description |
|----------|-------------|
| `DEFAULT_DOMAIN` | Domain for generated short URLs (e.g., `link.dhiarr.qzz.io`) |
| `IS_HTTPS_ENABLED` | Generate `https://` links |
| `DB_DRIVER` | Database driver (`mysql`, `postgres`, etc.) |
| `REDIS_SERVERS` | Redis connection for caching/real-time |
| `MERCURE_ENABLED` | Enable real-time visit updates |
| `MERCURE_PUBLIC_HUB_URL` | Public Mercure URL for the web client |
| `CORS_ALLOW_ORIGIN` | Allowed CORS origins (default `*`) |

---

## Troubleshooting

### "Could not connect to this Dhiarlink server"

1. Verify the backend URL is reachable from your browser: `curl https://www.dhiarr.qzz.io/rest/health`
2. Check CORS — the backend must allow requests from `app.dhiarr.qzz.io` (or `*`)
3. Verify the API key is valid: `curl -H "X-Api-Key: your-key" https://www.dhiarr.qzz.io/rest/v3/short-urls`

### Blank page after deployment

1. Check browser console for errors
2. Ensure the `build/` directory was properly copied to the nginx html root
3. Verify `index.html` is being served (check Network tab)
4. Clear browser cache and service worker (Application > Service Workers > Unregister)

### PWA not updating

1. The service worker caches aggressively. After deploying a new build:
   - The `AppUpdateBanner` component should detect the new version
   - Click "Restart now" to force-update
2. If stuck, manually clear: DevTools > Application > Storage > Clear site data

### TypeScript or build errors

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Type-check without building
npm run types

# Full clean build
npm run build
```

### Port conflicts

The dev server uses port 3000. If occupied:
```bash
# Edit vite.config.ts and change server.port, or:
PORT=3001 npm start
```

### Docker permission issues

```bash
# If the container fails with permission errors on node_modules binaries:
chmod +x node_modules/.bin/*
chmod +x node_modules/typescript/bin/*
```
