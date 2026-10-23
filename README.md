# sparshlabs

The home page of [sparshlabs.com](https://sparshlabs.com) and the shared sparshlabs theme.

sparshlabs builds small, focused open-source tools. Each project keeps its own repository and
its own site, mounted under a path on sparshlabs.com:

| URL | Served by | Source |
| --- | --- | --- |
| `sparshlabs.com/` | Worker `sparshlabs` | this repo |
| `sparshlabs.com/sparsh/` | Worker `sparsh` | [ashfaqc137/sparsh](https://github.com/ashfaqc137/sparsh) `apps/website` |
| `sparshlabs.com/ownci/` | Worker `ownci` | [ashfaqc137/ownci](https://github.com/ashfaqc137/ownci) `website` |

```bash
npm ci
npm run dev           # http://localhost:4321
npm run build         # astro check + static build into dist/, plus dist/_headers
npm run sync-theme    # copy theme/sparshlabs.css into ../sparsh and ../ownci
npm run preview-all   # build all three sites and serve them together on http://localhost:8787
```

Node ≥ 22 (see `.nvmrc`). Dependencies are pinned to exact versions.

## Layout

| Path | What |
| --- | --- |
| `theme/sparshlabs.css` | **The shared theme**: tokens, header, nav, footer, heroes, sections, cards, docs layout, code, tables |
| `src/data/projects.ts` | The project cards on the home page; one entry per project |
| `src/pages/index.astro` | Home: hero, project cards, about the lab, how we build |
| `src/layouts/BaseLayout.astro` | Header, footer, font imports |
| `src/styles/site.css` | Home-page-only styles (project cards, marks) |
| `_headers` | Security headers (strict CSP, no scripts), copied into `dist/` by `npm run build` |
| `scripts/sync-theme.sh` | Copies the theme into each project; `--check` fails if a copy is stale |
| `scripts/preview-all.sh` | Builds the three sites and serves them merged, like production |

## The shared theme

Every sparshlabs site imports `sparshlabs.css` before its own stylesheet, uses its tokens for
every colour, and builds its header the same way:

```html
<div class="brand">
  <a class="brand-lab" href="/">sparshlabs</a>
  <span class="brand-sep" aria-hidden="true">/</span>
  <a class="brand-home" href="/<project>/"><span class="brand-mark">…</span><span>Project</span></a>
</div>
```

- **Accent** `--accent #d3f36b` (lime), the one sparshlabs accent, with `--accent-hover`,
  `--accent-soft`, `--accent-muted`, `--accent-ink` (text on accent) and the `--accent-08/14/25/40`
  tints. Change it in one place and every site follows after a sync.
- **Base** `--bg #11120f` warm dark, `--surface-1..4`, text ramp `--text` → `--text-faint`,
  `--emph` for the second line of headlines, `--line` / `--line-strong` hairlines.
- **Status** `--pass`, `--warn`, `--fail`; **paper** tokens for light product mock-ups.
- **Type** Manrope (display), DM Sans (body), DM Mono (labels, code), self-hosted via
  `@fontsource` (dm-sans 400/700, manrope 600/700, dm-mono 400) in every site.

Each project has a copy at `src/styles/sparshlabs.css`. Edit the theme here, then run
`npm run sync-theme` and commit the copy in each project. Don't edit a copy directly; the next
sync overwrites it. `sh scripts/sync-theme.sh --check` exits 1 if any copy is stale.

## Deployment (Cloudflare)

The three sites are separate Workers serving static assets, each connected to its repository
with **Workers & Pages → Create → Import a repository**, and each claiming its part of
sparshlabs.com with a route in its `wrangler.jsonc`. Cloudflare picks the most specific route,
so `/sparsh*` and `/ownci*` go to the project Workers and everything else comes here.

For this repo:

| Setting | Value |
| --- | --- |
| Root directory | `/` |
| Build command | `npm ci && npm run build` |
| Deploy command | `npx wrangler deploy` |

One-time setup for the domain (zone `sparshlabs.com` on Cloudflare):

1. **DNS**: the routes only see traffic for proxied hostnames. If the apex has no record yet,
   add `AAAA @ 100::` (proxied, orange cloud), and the same for `www`.
2. **www**: add a Redirect Rule `www.sparshlabs.com/*` → `https://sparshlabs.com/${1}` (301).
3. Deploy this Worker first, then merge the sparsh and ownci branches that add their routes.
   `wrangler deploy` creates the routes from `wrangler.jsonc`; the API token used by Workers
   Builds needs *Workers Routes: Edit* on the zone.

Project sites build into `dist/<slug>/` with Astro `base: '/<slug>'`, because Workers static
assets don't strip the path prefix. Each project's `_headers` uses `/<slug>/…` patterns.

## Adding a project

1. In the project's site: copy `src/lib/paths.ts` from ownci or sparsh, set
   `base: '/<slug>'` and `outDir: './dist/<slug>'` in `astro.config.mjs`, send internal links
   through `href()`, import the fonts and `sparshlabs.css`, and add the route
   `sparshlabs.com/<slug>*` to its `wrangler.jsonc`.
2. Add the project to `scripts/sync-theme.sh` and `scripts/preview-all.sh`.
3. Add an entry to `src/data/projects.ts` (and a mark style in `src/styles/site.css`).

## Local preview of the whole domain

`npm run preview-all` builds sparshlabs, `../ownci/website` and `../sparsh` (with
`pnpm run build:website`), merges the three `dist/` folders into one tree, and serves it with
`wrangler dev` on http://localhost:8787, which handles trailing-slash redirects, 404 pages and
`_headers` the way production does. Pass `--no-build` to reuse existing builds. Set
`SPARSHLABS_WORK` if the projects aren't next to this repo.
