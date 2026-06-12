# Dhiarlink Web Client — Deployment Guide

> Full guide for running the Dhiarlink dashboard locally for development/testing and deploying to production via Cloudflare Tunnel.

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
│  dhiarr.qzz.io      → Dhiarlink backend  (PHP REST API)          │
│  app.dhiarr.qzz.io  → This project       (React SPA dashboard)   │
│  link.dhiarr.qzz.io → Dhiarlink backend  (short URL redirects)   │
└──────────────────────────────────────────────────────────────────┘

The web client (this repo) is a static React PWA.
It connects to the Dhiarlink REST API at https://dhiarr.qzz.io/rest/v3/...
No server-side rendering — just static files served by nginx or any HTTP server.
```

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | >= 22.x | JavaScript runtime |
| npm | >= 10.x | Package manager |
| Docker | >= 24.x | Container runtime (for production) |
| Docker Compose | >= 2.x | Multi-container orchestration |
| Git | >= 2.x | Version control |

For production deployment:
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
   - **URL:** `http://localhost:8000` (if running backend locally via docker-compose) or `https://dhiarr.qzz.io`
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
  -e DHIARLINK_SERVER_URL=https://dhiarr.qzz.io \
  -e DHIARLINK_SERVER_API_KEY=your-api-key \
  -e DHIARLINK_SERVER_NAME="Dhiarlink Production" \
  dhiarlink-web-client
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
  - hostname: dhiarr.qzz.io
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
cloudflared tunnel route dns dhiarlink-web-client dhiarr.qzz.io
cloudflared tunnel route dns dhiarlink-web-client link.dhiarr.qzz.io
```

**Step 6: Run the Dhiarlink web client container**

```bash
docker run -d \
  --name dhiarlink_web_client \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DHIARLINK_SERVER_URL=https://dhiarr.qzz.io \
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
   - `dhiarr.qzz.io` → `http://localhost:8000` (if applicable)
   - `link.dhiarr.qzz.io` → `http://localhost:8000` (if applicable)
6. Enable **TLS** in the tunnel settings for automatic HTTPS

---

## Pre-configuring a Server (Docker)

When running the web client via Docker, you can pre-configure the Dhiarlink server connection using environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DHIARLINK_SERVER_URL` | Base URL of the Dhiarlink API | `https://dhiarr.qzz.io` |
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
    "url": "https://dhiarr.qzz.io",
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

1. Verify the backend URL is reachable from your browser: `curl https://dhiarr.qzz.io/rest/health`
2. Check CORS — the backend must allow requests from `app.dhiarr.qzz.io` (or `*`)
3. Verify the API key is valid: `curl -H "X-Api-Key: your-key" https://dhiarr.qzz.io/rest/v3/short-urls`

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
