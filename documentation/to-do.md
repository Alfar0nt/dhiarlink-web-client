# Dhiarlink Web Client — Rebrand To-Do

> Target: `app.dhiarr.qzz.io` — URL shortener dashboard
> Theme: Terminal / Hacker Aesthetic — Deep Ocean Palette
> Backend: `../dhiarlink` (Dhiarlink PHP backend at `www.dhiarr.qzz.io`)
> Status: **Deployed to production on LXC container**

## Design Tokens

| Token          | Value     | Usage                        |
|----------------|-----------|------------------------------|
| Background     | `#0f1419` | Page / root background       |
| Card Surface   | `#192028` | Cards, panels, modals        |
| Accent         | `#4a9a8e` | Links, active states, brand  |
| Accent Hover   | `#5cc4b3` | Hover/focus on accent        |
| Text Primary   | `#a8b2c1` | Body text, headings          |
| Text Muted     | `#6b7a8d` | Secondary text, labels       |
| Success        | `#4ade80` | Confirmations, green states  |
| Error          | `#f87171` | Errors, danger states        |
| Border         | `#2a3440` | Borders, dividers            |
| Input BG       | `#131a21` | Form input backgrounds      |
| Font           | JetBrains Mono, Fira Code, SF Mono, monospace | All text |

---

## Completed

### Phase 1 — Project Metadata & Config
- [x] `package.json` — name `dhiarlink-web-client`, description, repository URL
- [x] `index.html` — title "Dhiarlink - URL Shortener Dashboard", theme-color meta, Google Fonts (JetBrains Mono)
- [x] `manifest.ts` — PWA short_name "Dhiarlink", name "Dhiarlink Web Client", theme/background `#0f1419`
- [x] `docker-compose.yml` — container/service names `dhiarlink_web_client_node`
- [x] `Dockerfile` — paths `/dhiarlink-web-client`, maintainer, entrypoint script name
- [x] `src/store/index.ts` — localStorage namespace `dhiarlink`
- [x] `scripts/docker/servers_from_env.sh` — env vars `DHIARLINK_SERVER_URL`/`DHIARLINK_SERVER_API_KEY`/`DHIARLINK_SERVER_NAME` (with backward-compat for `SHLINK_*` vars)

### Phase 2 — Theme & Styling
- [x] `src/tailwind.css` — Full Deep Ocean theme with CSS variables and `@theme` block
- [x] Tailwind v4 color tokens: `dh-bg`, `dh-card`, `dh-accent`, `dh-accent-hover`, `dh-text`, `dh-muted`, `dh-success`, `dh-error`, `dh-border`, `dh-input-bg`
- [x] Override upstream tokens: `lm-brand`, `dm-brand`, `lm-secondary`, `dm-secondary`, `lm-border`, `dm-border`, gray scale
- [x] Global base styles: JetBrains Mono font, scrollbar, selection, focus rings, inputs, modals, dropdowns, code blocks
- [x] `fadeIn` keyframe animation
- [x] Mobile touch target sizing (44px min on coarse pointers)
- [x] Force dark theme in `App.tsx` via `changeThemeInMarkup('dark')`

### Phase 3 — Logo & Branding
- [x] `src/common/img/DhiarlinkLogo.tsx` — Terminal-style SVG logo (`>_` prompt + link chain)
- [x] Replace ShlinkLogo → DhiarlinkLogo in `MainHeader.tsx`
- [x] Replace ShlinkLogo → DhiarlinkLogo in `Home.tsx`

### Phase 4 — Component Restyling
- [x] `MainHeader.tsx` — Dhiarlink brand text, accent logo, dark navbar styling
- [x] `Home.tsx` — Terminal greeting `> Welcome to Dhiarlink`, dark card, removed upstream Shlink docs link
- [x] `ServerForm.tsx` — Dark card surface with accent borders, removed SimpleCard dependency
- [x] `ManageServers.tsx` — Dark table container, removed SimpleCard dependency
- [x] `ManageServersRow.tsx` — Accent-colored auto-connect icon
- [x] `ServersListGroup.tsx` — Dark list items with accent hover
- [x] `ServerError.tsx` — Updated "Shlink" → "Dhiarlink" text references
- [x] `ErrorLayout.tsx` — Dark card with styled heading, removed SimpleCard dependency
- [x] `ErrorHandler.tsx` — Terminal-style error title `> Error: Something went wrong`
- [x] `NotFound.tsx` — Terminal-style 404 title `> 404: Route not found`
- [x] `AppUpdateBanner.tsx` — Dark banner with accent border, removed Card dependency
- [x] `ShlinkVersions.tsx` — Updated project refs to `dhiarlink`/`dhiarlink-web-client`, GitHub URLs
- [x] `NoMenuLayout.tsx` — Fade-in animation on mount
- [x] `App.tsx` — Dark background (`bg-dh-bg`), force dark theme, removed unused `useSettings` import

### Phase 5 — UX & Responsiveness
- [x] Smooth transitions on all interactive elements (global 0.15s ease)
- [x] Custom scrollbar styling (thin, dark themed)
- [x] Custom selection color (accent teal with transparency)
- [x] Accent-colored focus rings (`outline: 2px solid #4a9a8e`)
- [x] Mobile touch target minimum 44px (via `@media (pointer: coarse)`)
- [x] fadeIn animation on page transitions
- [x] Dark-themed inputs, modals, dropdowns, tables via global CSS overrides

### Phase 6 — Backend Integration
- [x] `servers_from_env.sh` — Dhiarlink env var names with backward compatibility for Shlink vars
- [x] Verified API compatibility — web client uses `@shlinkio/shlink-js-sdk` which talks standard Shlink REST API at `/rest/v3/...`
- [x] Backend CORS allows `*` by default; Mercure CORS includes `localhost:3000` and `app.dhiarr.qzz.io`

### Phase 7 — Documentation
- [x] `to-do.md` — This file with full status tracking
- [x] `deployment.md` — Full guide for local dev and production deployment
- [x] `documentation/deployment.md` — Domain updated to `app.dhiarr.qzz.io` (frontend) + `www.dhiarr.qzz.io` (backend)
- [x] `documentation/docs.md` — Comprehensive project documentation (tech stack, architecture, dependencies, env vars, project structure, backend integration)
- [x] `documentation/prompt-history.md` — Full conversation/development log
- [x] `README.md` — Streamlined to intro + screenshots + quick start + contributing

### Phase 8 — Production Deployment
- [x] Docker image built and deployed on LXC container
- [x] Running in production at `app.dhiarr.qzz.io`
- [x] Backend API connected at `www.dhiarr.qzz.io`
- [x] Cloudflare Tunnel routing configured
- [x] Caddy reverse proxy routing traffic to container via Docker internal network

### Phase 9 — Deployment Automation
- [x] `deploy.sh` — one-command production redeploy script (`git pull && ./deploy.sh`)
- [x] `.env.example` — production config template (server URL, API key, Docker network)
- [x] `.env` auto-loading in deploy script — loads config from file if present
- [x] `.gitignore` — added `.env` to prevent committing secrets
- [x] Docker network support (`--network dhiarlink_dhiarlink_internal`) for Caddy routing
- [x] `DHIARLINK_SERVER_FORWARD_CREDENTIALS` env var support in deploy script
- [x] Documentation updated: `deployment.md` quick-redeploy section, `docs.md` automation section, `CHANGELOG.md`
- [x] No pre-configured server by default — visitors add servers via UI (intentional, avoids exposing API key)

### Build Verification
- [x] `npm install` — All 663 packages installed
- [x] `tsc --noEmit` — TypeScript compiles with zero errors
- [x] `vite build` — Production build succeeds (60.90 KB CSS + 1,387 KB JS)
- [x] `vite serve` — Dev server runs on port 3000

---

## Remaining / Future Work

### Icons & Favicons (waiting on user-provided assets)
- [ ] Replace Dhiarlink PWA icon PNGs (`public/icons/icon-*.png` — 28 sizes)
- [ ] Replace `public/favicon.svg` with Dhiarlink branding
- [ ] Replace `public/favicon.ico`, `favicon.png`, `favicon.gif`

### Testing
- [ ] Update test snapshots to match new theme (visual regression)
- [ ] Update or disable tests that reference "Shlink" text strings
- [ ] Run full test suite: `npm test` and fix any failures

### Inner Dashboard Theme (optional — deep override)
- [ ] Deep theme the `@shlinkio/shlink-web-component` inner dashboard (sidebar, charts, tables, visit analytics)
- [ ] This requires either CSS variable overrides that reach into the web component's shadow DOM, or forking the upstream package

### Production Readiness
- [x] Deploy to `app.dhiarr.qzz.io` via Cloudflare Tunnel (deployed on LXC container)
- [ ] Verify full flow: web client → Dhiarlink API at `www.dhiarr.qzz.io/rest/v3/...`
- [ ] Test Mercure real-time visit updates from `app.dhiarr.qzz.io` → backend
- [ ] Configure PWA offline support and service worker caching strategy
- [ ] Set up `servers.json` pre-configuration for production Docker deployment
