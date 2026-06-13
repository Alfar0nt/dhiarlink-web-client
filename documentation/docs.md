# Dhiarlink Web Client — Project Documentation

> Comprehensive technical reference for the Dhiarlink Web Client project.
> Live deployment: [app.dhiarr.qzz.io](https://app.dhiarr.qzz.io)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Design System](#design-system)
- [Dependencies](#dependencies)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)
- [Available Scripts](#available-scripts)
- [Backend Integration](#backend-integration)
- [Pre-configuring Servers](#pre-configuring-servers)
- [Build & Output](#build--output)
- [Troubleshooting](#troubleshooting)

---

## Overview

Dhiarlink Web Client is a React-based Progressive Web Application (PWA) that serves as the management dashboard for the [Dhiarlink](https://github.com/dhiarlink/dhiarlink) URL shortener. It is a rebranded and restyled fork of [shlink-web-client](https://github.com/shlinkio/shlink-web-client), customized with a Terminal / Hacker aesthetic and the Deep Ocean color palette.

**Key features:**
- Create and manage short URLs with custom slugs, expiration, tags, and metadata
- Visit analytics with real-time updates (via Mercure SSE)
- Multi-server support — connect to multiple Dhiarlink instances
- Import/export server configurations between browsers
- Progressive Web App — installable, offline-capable after first load
- Fully responsive with touch-friendly targets
- Dark-only terminal UI with monospace typography

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        DNS / Tunnel                           │
│                                                               │
│  www.dhiarr.qzz.io  → Dhiarlink backend  (PHP REST API)      │
│  app.dhiarr.qzz.io  → This project       (React SPA)         │
│  link.dhiarr.qzz.io → Dhiarlink backend  (short redirects)   │
└──────────────────────────────────────────────────────────────┘
```

The web client is a **static React SPA** served by nginx (or any HTTP server). It communicates with the Dhiarlink backend via:

- **REST API** (`/rest/v3/...`) — CRUD operations on short URLs, tags, visits, domains, etc.
- **Mercure SSE** — real-time push notifications for new visits (when enabled)

There is **no server-side rendering**. The app is purely client-side — static HTML, CSS, and JS.

**Production deployment:** Running on an LXC container, served via Docker + nginx on port 8080, exposed through a Cloudflare Tunnel at `app.dhiarr.qzz.io`.

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
| **DI Container** | BottleJS | 2.x |
| **Testing** | Vitest + Testing Library + Playwright | 4.x |
| **Linting** | ESLint | 9.x |
| **Containerization** | Docker + nginx (Alpine) | — |
| **Deployment** | Cloudflare Tunnel | — |

---

## Design System

**Theme:** Terminal / Hacker Aesthetic — Deep Ocean Palette

### Color Tokens

| Token | Value | CSS Variable | Usage |
|-------|-------|-------------|-------|
| Background | `#0f1419` | `--color-dh-bg` | Page / root background |
| Card Surface | `#192028` | `--color-dh-card` | Cards, panels, modals |
| Accent | `#4a9a8e` | `--color-dh-accent` | Links, active states, brand |
| Accent Hover | `#5cc4b3` | `--color-dh-accent-hover` | Hover/focus on accent |
| Text Primary | `#a8b2c1` | `--color-dh-text` | Body text, headings |
| Text Muted | `#6b7a8d` | `--color-dh-muted` | Secondary text, labels |
| Success | `#4ade80` | `--color-dh-success` | Confirmations |
| Error | `#f87171` | `--color-dh-error` | Errors, danger states |
| Border | `#2a3440` | `--color-dh-border` | Borders, dividers |
| Input BG | `#131a21` | `--color-dh-input-bg` | Form input backgrounds |

### Typography

```css
font-family: 'JetBrains Mono', 'Fira Code', 'SF Mono', monospace;
```

Loaded via Google Fonts in `index.html`.

### Theme Implementation

The app is **dark-mode only**. Theme is enforced via:

1. `App.tsx` calls `changeThemeInMarkup('dark')` on mount
2. `src/tailwind.css` defines custom tokens in Tailwind v4's `@theme` block
3. Upstream `shlink-frontend-kit` tokens (`lm-brand`, `dm-brand`, `lm-secondary`, etc.) are overridden to match the Deep Ocean palette
4. Gray scale tokens are remapped to the dark palette

### Global CSS Overrides

The `@layer base` block in `tailwind.css` provides:
- JetBrains Mono font stack
- Dark scrollbars (`scrollbar-color: #2a3440 #0f1419`)
- Accent-colored text selection
- Accent-colored focus rings
- Dark-themed inputs, modals, dropdowns, and tables
- Code block styling
- `fadeIn` keyframe animation (0.2s ease)
- Mobile touch target sizing (44px min on coarse pointers)

---

## Dependencies

### Runtime Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `react` | ^19.2.6 | UI framework |
| `react-dom` | ^19.2.6 | DOM renderer |
| `react-router` | ^7.17.0 | Client-side routing |
| `react-redux` | ^9.3.0 | Redux React bindings |
| `@reduxjs/toolkit` | ^2.12.0 | State management |
| `redux-localstorage-simple` | ^2.5.1 | Persist Redux state to localStorage |
| `@shlinkio/shlink-frontend-kit` | ^1.4.0 | UI component library (NavBar, Card, Button, etc.) |
| `@shlinkio/shlink-web-component` | ^0.18.0 | Dashboard widget (sidebar, charts, tables, visits) |
| `@shlinkio/shlink-js-sdk` | ^3.1.0 | REST API client for Shlink/Dhiarlink |
| `@shlinkio/data-manipulation` | ^1.0.4 | Data transformation utilities |
| `@fortawesome/fontawesome-free` | ^7.2.0 | Icon font |
| `@fortawesome/fontawesome-svg-core` | ^7.2.0 | SVG icon core |
| `@fortawesome/free-solid-svg-icons` | ^7.2.0 | Solid icons |
| `@fortawesome/free-regular-svg-icons` | ^7.2.0 | Regular icons |
| `@fortawesome/free-brands-svg-icons` | ^7.2.0 | Brand icons |
| `@fortawesome/react-fontawesome` | ^3.3.1 | React icon components |
| `@json2csv/plainjs` | ^7.0.6 | CSV export |
| `bottlejs` | ^2.0.1 | Dependency injection container |
| `clsx` | ^2.1.1 | Conditional class name builder |
| `compare-versions` | ^6.1.1 | Semver comparison |
| `csvtojson` | ^2.0.14 | CSV import/parsing |
| `date-fns` | ^4.4.0 | Date formatting utilities |
| `react-external-link` | ^2.7.0 | External link component |
| `workbox-core` | ^7.4.0 | Service worker core |
| `workbox-expiration` | ^7.4.0 | Cache expiration |
| `workbox-precaching` | ^7.4.0 | Precache assets |
| `workbox-routing` | ^7.4.0 | Route matching |
| `workbox-strategies` | ^7.4.0 | Caching strategies |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `vite` | ^8.0.16 | Build tool & dev server |
| `@vitejs/plugin-react` | ^6.0.2 | React Fast Refresh |
| `@tailwindcss/vite` | ^4.3.0 | Tailwind CSS Vite plugin |
| `tailwindcss` | ^4.1.3 | CSS framework |
| `typescript` | ^5.9.3 | Type checker |
| `vitest` | ^4.0.3 | Test runner |
| `@vitest/browser` | ^4.0.3 | Browser-based test execution |
| `@vitest/browser-playwright` | ^4.1.8 | Playwright browser provider |
| `@vitest/coverage-v8` | ^4.1.2 | Code coverage |
| `playwright` | ^1.60.0 | Browser automation |
| `@testing-library/react` | ^16.3.2 | React component testing |
| `@testing-library/jest-dom` | ^6.9.1 | DOM matchers |
| `@testing-library/user-event` | ^14.6.1 | User interaction simulation |
| `eslint` | ^9.39.2 | Linter |
| `typescript-eslint` | ^8.54.0 | TypeScript ESLint plugin |
| `vite-plugin-pwa` | ^1.3.0 | PWA manifest & service worker |
| `adm-zip` | ^0.5.17 | ZIP file creation (dist scripts) |

---

## Project Structure

```
dhiarlink-web-client/
├── config/
│   ├── docker/
│   │   └── nginx.conf              # Production nginx server config
│   └── test/
│       └── setupTests.ts           # Test setup (vitest)
├── documentation/
│   ├── deployment.md               # Deployment guide
│   ├── docs.md                     # This file — project docs
│   ├── prompt-history.md           # Conversation/prompt log
│   └── to-do.md                    # Rebrand task tracker
├── public/
│   ├── icons/
│   │   └── icon-*.png              # PWA icons (28 sizes)
│   ├── .htaccess                   # Apache fallback rules
│   ├── favicon.ico/svg/png/gif     # Favicons
├── scripts/
│   ├── docker/
│   │   └── servers_from_env.sh     # Docker entrypoint: DHIARLINK_* env → servers.json
│   ├── create-dist-file.mjs        # Creates distributable ZIP
│   ├── replace-version.mjs         # Injects version into build
│   └── set-homepage.cjs            # Sets homepage in package.json
├── src/
│   ├── api/services/
│   │   └── ShlinkApiClientBuilder.ts   # API client factory
│   ├── app/
│   │   ├── App.tsx                     # Root component, forces dark theme
│   │   └── reducers/
│   │       └── appUpdates.ts           # App version tracking
│   ├── common/
│   │   ├── img/
│   │   │   └── DhiarlinkLogo.tsx       # Terminal-style SVG logo
│   │   ├── AppUpdateBanner.tsx         # PWA update notification
│   │   ├── ErrorHandler.tsx            # Error boundary
│   │   ├── ErrorLayout.tsx             # Error page layout
│   │   ├── Home.tsx                    # Welcome/landing page
│   │   ├── MainHeader.tsx              # Top navigation bar
│   │   ├── NoMenuLayout.tsx            # Layout without sidebar
│   │   ├── NotFound.tsx                # 404 page
│   │   ├── ScrollToTop.tsx             # Route change scroll reset
│   │   ├── ShlinkVersions.tsx          # Version display
│   │   ├── ShlinkVersionsContainer.tsx # Version container
│   │   └── ShlinkWebComponentContainer.tsx # Dashboard wrapper
│   ├── container/
│   │   ├── context.tsx                 # React context for DI
│   │   └── index.ts                    # BottleJS service registration
│   ├── servers/
│   │   ├── data/
│   │   │   └── index.ts               # Server data types
│   │   ├── helpers/
│   │   │   ├── DuplicatedServersModal.tsx
│   │   │   ├── ImportServersBtn.tsx
│   │   │   ├── ServerError.tsx
│   │   │   ├── ServerForm.tsx
│   │   │   ├── withSelectedServer.tsx
│   │   │   └── withoutSelectedServer.tsx
│   │   ├── reducers/
│   │   │   ├── remoteServers.ts
│   │   │   ├── selectedServer.ts
│   │   │   └── servers.ts
│   │   ├── services/
│   │   │   ├── ServersExporter.ts
│   │   │   └── ServersImporter.ts
│   │   ├── CreateServer.tsx
│   │   ├── DeleteServerButton.tsx
│   │   ├── DeleteServerModal.tsx
│   │   ├── EditServer.tsx
│   │   ├── ManageServers.tsx
│   │   ├── ManageServersRow.tsx
│   │   ├── ManageServersRowDropdown.tsx
│   │   ├── ServersDropdown.tsx
│   │   └── ServersListGroup.tsx
│   ├── settings/
│   │   ├── helpers/
│   │   ├── reducers/
│   │   │   └── settings.ts
│   │   └── Settings.tsx
│   ├── store/
│   │   ├── helpers.ts
│   │   ├── index.ts                    # Redux store (namespace: 'dhiarlink')
│   │   └── reducers.ts
│   ├── utils/
│   │   ├── helpers/
│   │   │   ├── csvjson.ts
│   │   │   ├── files.ts
│   │   │   ├── hooks.ts
│   │   │   ├── sw.ts
│   │   │   ├── uri.ts
│   │   │   └── version.ts
│   │   ├── services/
│   │   │   ├── LocalStorage.ts
│   │   │   └── TagColorsStorage.ts
│   │   ├── types.ts
│   │   └── utils.ts
│   ├── index.tsx                       # Application entry point
│   ├── service-worker.ts              # Workbox service worker
│   ├── serviceWorkerRegistration.ts   # SW registration
│   └── tailwind.css                   # Deep Ocean theme & Tailwind config
├── test/                               # Mirrors src/ structure
├── Dockerfile                         # Multi-stage: node → nginx
├── dev.Dockerfile                     # Development container
├── docker-compose.yml                 # Dev orchestration
├── index.html                         # HTML entry with Google Fonts
├── manifest.ts                        # PWA manifest config
├── vite.config.ts                     # Vite + Vitest configuration
├── tsconfig.json                      # TypeScript config
├── eslint.config.js                   # ESLint flat config
├── package.json                       # Dependencies & scripts
├── screenshoot_1.png                  # Screenshot — dashboard home
├── screenshoot_2.png                  # Screenshot — server management
└── screenshoot_3.png                  # Screenshot — URL management
```

---

## Environment Variables

### Web Client

| Variable | Context | Default | Description |
|----------|---------|---------|-------------|
| `NODE_ENV` | Build | `development` | `production` for optimized builds |
| `DHIARLINK_SERVER_URL` | Docker runtime | — | Pre-configured Dhiarlink API base URL |
| `DHIARLINK_SERVER_API_KEY` | Docker runtime | — | Pre-configured API key |
| `DHIARLINK_SERVER_NAME` | Docker runtime | `Dhiarlink` | Display name in the dashboard |
| `DHIARLINK_SERVER_FORWARD_CREDENTIALS` | Docker runtime | `false` | Forward browser credentials (cookies) |

> Legacy `SHLINK_*` variables (`SHLINK_SERVER_URL`, `SHLINK_SERVER_API_KEY`, `SHLINK_SERVER_NAME`, `SHLINK_SERVER_FORWARD_CREDENTIALS`) are also supported for backward compatibility.

### Backend (Dhiarlink)

The Dhiarlink backend at `www.dhiarr.qzz.io` has its own configuration:

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
| `npm start` | Start Vite dev server on port 3000 (HMR) |
| `npm run build` | Type-check + production build to `build/` |
| `npm run preview` | Preview the production build locally |
| `npm test` | Run the test suite (Vitest + Playwright) |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:ci` | Run tests with code coverage |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Auto-fix lint issues |
| `npm run types` | Type-check without building |
| `npm run build:dist` | Build + create distributable ZIP |

---

## Backend Integration

### How It Works

The web client uses `@shlinkio/shlink-js-sdk` which sends standard HTTP requests to the Shlink REST API. Since Dhiarlink is a fork of Shlink, the API endpoints are identical:

```
GET  /rest/health                    → Health check
GET  /rest/v3/short-urls             → List short URLs
POST /rest/v3/short-urls             → Create short URL
GET  /rest/v3/short-urls/{hash}      → Get short URL details
DELETE /rest/v3/short-urls/{hash}    → Delete short URL
GET  /rest/v3/visits                 → Get visit statistics
GET  /rest/v3/tags                   → List tags
GET  /rest/v3/domains                → List domains
...
```

All requests are authenticated via the `X-Api-Key` header.

### CORS Configuration

The Dhiarlink backend defaults `CORS_ALLOW_ORIGIN` to `*`, which allows the web client at any origin. For production, you can restrict this to `https://app.dhiarr.qzz.io`.

### Mercure Real-time Updates

When `MERCURE_ENABLED=true` in the backend, the web client subscribes to SSE events at the Mercure hub for real-time visit notifications. The backend's Mercure CORS configuration must include the web client's origin.

### Server Pre-configuration via Docker

The script `scripts/docker/servers_from_env.sh` runs as a Docker entrypoint and generates `/usr/share/nginx/html/servers.json` from the `DHIARLINK_*` environment variables. This allows zero-touch server configuration when deploying the container.

---

## Pre-configuring Servers

### Via Environment Variables (Docker)

```bash
docker run -d \
  --name dhiarlink_web_client \
  -p 8080:8080 \
  -e DHIARLINK_SERVER_URL=https://www.dhiarr.qzz.io \
  -e DHIARLINK_SERVER_API_KEY=your-api-key \
  -e DHIARLINK_SERVER_NAME="Dhiarlink" \
  dhiarlink-web-client
```

### Via servers.json

Create a `servers.json` file in the project root (same folder as `index.html`):

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

For Docker, mount as a volume:
```bash
docker run -d -p 8080:8080 \
  -v ./servers.json:/usr/share/nginx/html/servers.json:ro \
  dhiarlink-web-client
```

> **Security:** Since this is a client-side app, `servers.json` (including API keys) is accessible from the browser. Only use pre-configuration in trusted/self-hosted environments.

---

## Build & Output

### Production Build

```bash
npm run build
```

Runs TypeScript type-checking, then Vite production build, then injects the version string.

**Output directory:** `build/`

```
build/
├── index.html
├── manifest.json
├── service-worker.js
├── assets/
│   ├── index-*.css     (~60 KB, gzipped: ~11 KB)
│   └── index-*.js      (~1.4 MB, gzipped: ~417 KB)
├── icons/
│   └── icon-*.png
└── favicon.*
```

### Docker Build

```bash
docker build -t dhiarlink-web-client .
```

Multi-stage build:
1. **Stage 1 (node):** `npm ci` + `npm run build` in `/dhiarlink-web-client`
2. **Stage 2 (nginx-unprivileged):** Copies build output to `/usr/share/nginx/html`, configures nginx, sets up entrypoint scripts

The container runs as non-root user (UID 101) on port 8080.

---

## Troubleshooting

### "Could not connect to this Dhiarlink server"

1. Verify the backend is reachable: `curl https://www.dhiarr.qzz.io/rest/health`
2. Check CORS — backend must allow your dashboard origin (or `*`)
3. Verify the API key: `curl -H "X-Api-Key: your-key" https://www.dhiarr.qzz.io/rest/v3/short-urls`

### Blank page after deployment

1. Check browser console for errors
2. Ensure `build/` is properly served by your web server
3. Verify `index.html` is being served (Network tab)
4. Clear browser cache and unregister old service worker

### PWA not updating

1. The `AppUpdateBanner` detects new versions — click "Restart now"
2. If stuck: DevTools > Application > Storage > Clear site data

### Build errors

```bash
rm -rf node_modules package-lock.json
npm install
npm run types     # Type-check without building
npm run build     # Full clean build
```

### Port conflicts

Dev server uses port 3000. To change:
```bash
PORT=3001 npm start
```

### Docker permission issues

```bash
chmod +x node_modules/.bin/*
chmod +x node_modules/typescript/bin/*
```
