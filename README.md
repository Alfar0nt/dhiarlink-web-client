# Dhiarlink Web Client

A React-based Progressive Web Application (PWA) dashboard for managing [Dhiarlink](https://github.com/dhiarlink/dhiarlink) — a self-hosted URL shortener. Built with a **Terminal / Hacker aesthetic** and deployed at **app.dhiarr.qzz.io**.

> This is a rebranded and restyled fork of [shlink-web-client](https://github.com/shlinkio/shlink-web-client), customized for the Dhiarlink URL shortener platform.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Design System](#design-system)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Local Development](#local-development)
  - [Connecting to a Dhiarlink Backend](#connecting-to-a-dhiarlink-backend)
- [Production Build](#production-build)
  - [Static Files](#static-files)
  - [Docker Image](#docker-image)
- [Deployment with Cloudflare Tunnel](#deployment-with-cloudflare-tunnel)
- [Pre-configuring Servers](#pre-configuring-servers)
  - [Via Environment Variables](#via-environment-variables)
  - [Via servers.json](#via-serversjson)
- [Environment Variables Reference](#environment-variables-reference)
- [Available Scripts](#available-scripts)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

---

## Features

- **Create & manage short URLs** — generate short links, set custom slugs, expiration dates, tags, and metadata
- **Visit analytics** — track clicks, referrers, browsers, devices, and geolocation with real-time updates (via Mercure SSE)
- **Multi-server support** — connect to and switch between multiple Dhiarlink instances from a single dashboard
- **Import / export servers** — transfer your server configuration between browsers or devices
- **Progressive Web App** — installable, works offline after first load, with service worker caching
- **Fully responsive** — optimized for both desktop and mobile with touch-friendly targets
- **Dark-only terminal UI** — Deep Ocean color palette with monospace typography

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Framework** | React | 19.x |
| **Language** | TypeScript | 5.9.x |
| **Build Tool** | Vite | 8.x |
| **CSS** | Tailwind CSS v4 | 4.x |
| **State Management** | Redux Toolkit | 2.x |
| **Routing** | React Router | 7.x |
| **PWA / Service Worker** | Workbox + vite-plugin-pwa | 7.x / 1.3.x |
| **UI Components** | @shlinkio/shlink-frontend-kit | 1.4.x |
| **Dashboard Widget** | @shlinkio/shlink-web-component | 0.18.x |
| **API Client** | @shlinkio/shlink-js-sdk | 3.1.x |
| **Icons** | Font Awesome | 7.x |
| **Testing** | Vitest + Testing Library + Playwright | 4.x |
| **Linting** | ESLint | 9.x |
| **Containerization** | Docker + nginx | Alpine-based |
| **Deployment** | Cloudflare Tunnel | — |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        DNS / Tunnel                           │
│                                                               │
│  dhiarr.qzz.io      → Dhiarlink backend  (PHP REST API)      │
│  app.dhiarr.qzz.io  → This project       (React SPA)         │
│  link.dhiarr.qzz.io → Dhiarlink backend  (short redirects)   │
└──────────────────────────────────────────────────────────────┘
```

The web client is a **static React SPA** served by nginx (or any HTTP server). It connects to the Dhiarlink REST API at `/rest/v3/...` using the standard Shlink JS SDK. There is no server-side rendering — just static HTML, CSS, and JS.

Key communication paths:
- **REST API** — all CRUD operations on short URLs, tags, visits, domains, etc.
- **Mercure SSE** — real-time push notifications for new visits (when enabled in backend)

---

## Design System

**Theme:** Terminal / Hacker Aesthetic — Deep Ocean Palette

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#0f1419` | Page / root background |
| Card Surface | `#192028` | Cards, panels, modals |
| Accent | `#4a9a8e` | Links, active states, brand color |
| Accent Hover | `#5cc4b3` | Hover/focus on accent elements |
| Text Primary | `#a8b2c1` | Body text, headings |
| Text Muted | `#6b7a8d` | Secondary text, labels |
| Success | `#4ade80` | Confirmations, green states |
| Error | `#f87171` | Errors, danger states |
| Border | `#2a3440` | Borders, dividers |
| Input Background | `#131a21` | Form input backgrounds |

**Typography:** `'JetBrains Mono'`, `'Fira Code'`, `'SF Mono'`, monospace

The app is **dark-mode only**. The upstream shlink-frontend-kit theme tokens are overridden via Tailwind CSS v4's `@theme` directive to match the Deep Ocean palette.

---

## Getting Started

### Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | >= 22.x | JavaScript runtime |
| npm | >= 10.x | Package manager |
| Git | >= 2.x | Version control |
| Docker | >= 24.x | Container runtime *(for production)* |

For production deployment:
- A Cloudflare account (free tier works)
- `cloudflared` CLI installed on your server
- A running Dhiarlink backend instance

### Local Development

```bash
# 1. Clone the repository
git clone https://github.com/dhiarlink/dhiarlink-web-client.git
cd dhiarlink-web-client

# 2. Install dependencies
npm install

# 3. Start the dev server
npm start
```

The Vite dev server starts on **http://localhost:3000** with hot module replacement. It binds to `0.0.0.0`, so it's also accessible on your LAN for mobile testing.

### Connecting to a Dhiarlink Backend

Once the dashboard opens, you'll need to add a server:

1. Click **"Add a server"**
2. Fill in the details:
   - **Name:** `Dhiarlink (local)`
   - **URL:** `http://localhost:8000` (local backend) or `https://dhiarr.qzz.io` (production)
   - **API key:** Generate one from the backend via `bin/cli api-key:generate`

Alternatively, create a `public/servers.json` file for pre-configuration (see [Pre-configuring Servers](#via-serversjson) below).

---

## Production Build

### Static Files

```bash
npm run build
```

Outputs optimized static files to `build/`:

```
build/
├── index.html
├── manifest.json
├── service-worker.js
├── assets/
│   ├── index-*.css     (~60 KB)
│   └── index-*.js      (~1.4 MB)
├── icons/
│   └── icon-*.png
└── favicon.*
```

Serve these files with any static HTTP server — nginx, Caddy, Apache, etc.

**Important:** The app uses client-side routing. Your web server must fall back to `index.html` for non-existent paths. See the [nginx config](config/docker/nginx.conf) for an example.

### Docker Image

```bash
# Build
docker build -t dhiarlink-web-client .

# Run
docker run -d \
  --name dhiarlink_web_client \
  -p 8080:8080 \
  dhiarlink-web-client
```

The container runs **nginx on port 8080** as a non-root user (UID 101).

With pre-configured server:

```bash
docker run -d \
  --name dhiarlink_web_client \
  -p 8080:8080 \
  -e DHIARLINK_SERVER_URL=https://dhiarr.qzz.io \
  -e DHIARLINK_SERVER_API_KEY=your-api-key \
  -e DHIARLINK_SERVER_NAME="Dhiarlink" \
  dhiarlink-web-client
```

Or using Docker Compose:

```bash
docker compose up -d
```

---

## Deployment with Cloudflare Tunnel

This is the recommended approach for deploying to `app.dhiarr.qzz.io`.

**Step 1: Authenticate cloudflared**

```bash
cloudflared tunnel login
```

**Step 2: Create a tunnel**

```bash
cloudflared tunnel create dhiarlink-web-client
```

**Step 3: Configure ingress** (`~/.cloudflared/config.yml`)

```yaml
tunnel: <TUNNEL_ID>
credentials-file: /home/<user>/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: app.dhiarr.qzz.io
    service: http://localhost:8080
    originRequest:
      noTLSVerify: true
  - hostname: dhiarr.qzz.io
    service: http://localhost:8000
  - hostname: link.dhiarr.qzz.io
    service: http://localhost:8000
  - service: http_status:404
```

**Step 4: Create DNS records**

```bash
cloudflared tunnel route dns dhiarlink-web-client app.dhiarr.qzz.io
cloudflared tunnel route dns dhiarlink-web-client dhiarr.qzz.io
cloudflared tunnel route dns dhiarlink-web-client link.dhiarr.qzz.io
```

**Step 5: Run the tunnel**

```bash
cloudflared tunnel run dhiarlink-web-client

# Or install as a systemd service for auto-start:
sudo cloudflared service install
sudo systemctl enable --now cloudflared
```

Alternatively, you can manage tunnels via the **Cloudflare Zero Trust Dashboard** (GUI) instead of CLI.

---

## Pre-configuring Servers

### Via Environment Variables

When running in Docker, you can pre-configure a server using environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DHIARLINK_SERVER_URL` | Base URL of the Dhiarlink API | — |
| `DHIARLINK_SERVER_API_KEY` | API key for authentication | — |
| `DHIARLINK_SERVER_NAME` | Display name in the dashboard | `Dhiarlink` |
| `DHIARLINK_SERVER_FORWARD_CREDENTIALS` | Forward browser credentials (cookies, etc.) | `false` |

> Legacy `SHLINK_*` variables are also supported for backward compatibility.

### Via servers.json

Place a `servers.json` file in the project root (same folder as `index.html`):

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

For Docker, mount it as a volume:

```bash
docker run -d -p 8080:8080 \
  -v ./servers.json:/usr/share/nginx/html/servers.json:ro \
  dhiarlink-web-client
```

> **Security notice:** Since this is a client-side app, `servers.json` (including API keys) is accessible from the browser. Only use pre-configuration in trusted/self-hosted environments.

---

## Environment Variables Reference

### Web Client (this project)

| Variable | Context | Default | Description |
|----------|---------|---------|-------------|
| `NODE_ENV` | Build | `development` | `production` for optimized builds |
| `DHIARLINK_SERVER_URL` | Docker runtime | — | Pre-configured server URL |
| `DHIARLINK_SERVER_API_KEY` | Docker runtime | — | Pre-configured API key |
| `DHIARLINK_SERVER_NAME` | Docker runtime | `Dhiarlink` | Pre-configured display name |

### Backend (Dhiarlink)

The Dhiarlink backend (at `../dhiarlink` or `dhiarr.qzz.io`) has its own configuration. Key variables:

| Variable | Description |
|----------|-------------|
| `DEFAULT_DOMAIN` | Domain for generated short URLs (e.g., `link.dhiarr.qzz.io`) |
| `IS_HTTPS_ENABLED` | Generate `https://` links |
| `DB_DRIVER` | Database driver (`mysql`, `postgres`, etc.) |
| `REDIS_SERVERS` | Redis connection for caching/real-time |
| `MERCURE_ENABLED` | Enable real-time visit updates via SSE |
| `MERCURE_PUBLIC_HUB_URL` | Public Mercure URL for the web client |
| `CORS_ALLOW_ORIGIN` | Allowed CORS origins (default `*`) |

---

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start Vite dev server on port 3000 |
| `npm run build` | Type-check + production build to `build/` |
| `npm run preview` | Preview the production build locally |
| `npm test` | Run the test suite (Vitest) |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Auto-fix lint issues |
| `npm run types` | Type-check without building |
| `npm run build:dist` | Build + create distributable zip |

---

## Project Structure

```
dhiarlink-web-client/
├── config/                     # Nginx config, test setup
│   ├── docker/nginx.conf
│   └── test/setupTests.ts
├── public/                     # Static assets (icons, favicons)
│   └── icons/icon-*.png
├── scripts/                    # Build & Docker scripts
│   ├── docker/servers_from_env.sh
│   ├── create-dist-file.mjs
│   ├── replace-version.mjs
│   └── set-homepage.cjs
├── src/
│   ├── api/services/           # ShlinkApiClientBuilder
│   ├── app/                    # App.tsx entry, appUpdates reducer
│   ├── common/                 # Shared components (Home, Header, NotFound, etc.)
│   ├── container/              # BottleJS dependency injection
│   ├── servers/                # Server management (CRUD, import/export)
│   ├── settings/               # User settings & preferences
│   ├── store/                  # Redux store configuration
│   ├── utils/                  # Helpers, hooks, services
│   ├── index.tsx               # Application entry point
│   ├── service-worker.ts       # Workbox service worker
│   └── tailwind.css            # Deep Ocean theme & Tailwind config
├── test/                       # Mirrors src/ structure for unit tests
├── Dockerfile                  # Multi-stage build (node → nginx)
├── docker-compose.yml          # Local development orchestration
├── manifest.ts                 # PWA manifest configuration
├── vite.config.ts              # Vite build configuration
├── tsconfig.json               # TypeScript configuration
└── package.json                # Dependencies & scripts
```

---

## Troubleshooting

### "Could not connect to this Dhiarlink server"

1. Verify the backend URL is reachable: `curl https://dhiarr.qzz.io/rest/health`
2. Check CORS — backend must allow your dashboard origin (or `*`)
3. Verify the API key: `curl -H "X-Api-Key: your-key" https://dhiarr.qzz.io/rest/v3/short-urls`

### Blank page after deployment

1. Check browser console for errors
2. Ensure `build/` was properly served by your web server
3. Verify `index.html` is being served (check Network tab)
4. Clear browser cache and unregister old service worker

### PWA not updating

1. The `AppUpdateBanner` component detects new versions — click "Restart now"
2. If stuck: DevTools > Application > Storage > Clear site data

### Build errors

```bash
# Clear and reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Type-check without building
npm run types

# Full clean build
npm run build
```

### Port conflicts

The dev server uses port 3000. To change it:
```bash
PORT=3001 npm start
```

---

## Contributing

Contributions are welcome. To get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-change`
3. Make your changes and run tests: `npm test`
4. Commit and push: `git push origin feature/my-change`
5. Open a pull request

Before submitting, ensure:
- TypeScript compiles without errors: `npm run types`
- Linting passes: `npm run lint`
- Tests pass: `npm test`

---

## Credits

This project is a rebranded fork of [shlink-web-client](https://github.com/shlinkio/shlink-web-client) by [shlinkio](https://shlink.io). The original project is licensed under the MIT License.

The Dhiarlink rebrand includes:
- Custom Terminal / Hacker aesthetic with the Deep Ocean color palette
- Rebranded UI text, logos, and metadata
- Tailwind CSS v4 theme overrides for the upstream component libraries
- Docker and deployment scripts adapted for Dhiarlink infrastructure
- Environment variable namespace changed from `SHLINK_*` to `DHIARLINK_*`

---

## License

This project is licensed under the [MIT License](LICENSE).
