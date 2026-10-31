# sparshlabs

The home page of [sparshlabs.com](https://sparshlabs.com) and the shared sparshlabs theme.

sparshlabs builds small, focused open-source tools. Each project keeps its own repository and
its own site, mounted under a path on sparshlabs.com. The projects are git submodules under
`projects/`, so the design of every site can be changed from this repo:

| URL | Served by | Source |
| --- | --- | --- |
| `sparshlabs.com/` | Worker `sparshlabs` | this repo |
| `author.sparshlabs.com/` | Worker `sparshlabs` (rewritten to `/author/`) | this repo, `src/pages/author.astro` |
| `sparshlabs.com/sparsh/` | Worker `sparsh` | `projects/sparsh` → [ashfaqc137/sparsh](https://github.com/ashfaqc137/sparsh) `apps/website` |
| `sparshlabs.com/ownci/` | Worker `ownci` | `projects/ownci` → [ashfaqc137/ownci](https://github.com/ashfaqc137/ownci) `website` |

```bash
git clone --recurse-submodules https://github.com/ashfaqc137/sparshlabs.git
npm run setup         # check out the submodules, npm ci here and in ownci, pnpm install in sparsh
npm run dev           # http://localhost:4321
npm run build         # astro check + static build into dist/, plus dist/_headers
npm run sync-theme    # copy theme/sparshlabs.css into each project in projects/
npm run preview-all   # build all three sites and serve them together on http://localhost:8787
```

Node ≥ 22 (see `.nvmrc`). Dependencies are pinned to exact versions.

## Layout

| Path | What |
| --- | --- |
| `projects/ownci`, `projects/sparsh` | The project repositories, as submodules |
| `theme/sparshlabs.css` | **The shared theme**: tokens, header, nav, footer, heroes, sections, cards, docs layout, code, tables |
| `src/data/projects.ts` | The project cards on the home page; one entry per project |
| `src/pages/index.astro` | Home: hero, project cards, about the lab, how I build |
| `src/pages/author.astro` | The author bio, served at author.sparshlabs.com |
| `src/layouts/BaseLayout.astro` | Header, footer, font imports |
| `src/styles/site.css` | Home-page-only styles (project cards, marks) |
| `src/components/Code.astro` | Code block with a copy button (the home page's only script), same as OwnCI's |
| `_headers` | Security headers (strict CSP, scripts only from 'self'), copied into `dist/` by `npm run build` |
| `scripts/setup.sh` | Checks out the submodules and installs every site's dependencies |
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

- **Accent** `--accent #6ee7d8` (signal cyan), the one sparshlabs accent, with `--accent-hover`,
  `--accent-soft`, `--accent-muted`, `--accent-ink` (text on accent) and the `--accent-08/14/25/40`
  tints. Change it in one place and every site follows after a sync.
- **Base** `--bg #11120f` warm dark, `--surface-1..4`, text ramp `--text` → `--text-faint`,
  `--emph` for the second line of headlines, `--line` / `--line-strong` hairlines.
- **Status** `--pass`, `--warn`, `--fail`; **paper** tokens for light product mock-ups.
- **Type** Manrope (display), DM Sans (body), DM Mono (labels, code), self-hosted via
  `@fontsource` (dm-sans 400/700, manrope 600/700, dm-mono 400) in every site.

Each project has a copy at `src/styles/sparshlabs.css`, because Cloudflare builds each project
repository on its own and can't reach this file. Don't edit a copy directly; the next sync
overwrites it. `sh scripts/sync-theme.sh --check` exits 1 if any copy is stale.

## Changing the design of every site

All of it happens in this repo:

1. Edit `theme/sparshlabs.css` (shared look), or a project's own styles and pages in
   `projects/<name>/…` (sparsh: `apps/website/src/styles.css`, ownci: `website/src/styles/global.css`).
2. `npm run sync-theme`, then `npm run preview-all` to check all three sites together.
3. Commit inside each submodule you changed, on a branch, and push it:
   `git -C projects/ownci switch -c website/<change> && git -C projects/ownci commit -am "…" && git -C projects/ownci push -u origin HEAD`.
4. Commit here: the theme plus the new submodule pointers (`git add theme projects && git commit`).
5. Merge the project branches. Each project's Cloudflare build deploys its site; merging here
   deploys the home page.

The submodules track `main` (ownci) and `master` (sparsh). `git submodule update --remote`
moves them to the latest commit on those branches; commit the updated pointers afterwards.
A submodule is a normal clone: `git -C projects/sparsh log`, `switch`, `pull` work as usual, and
it starts in "detached HEAD" after `git submodule update`, so switch to a branch before
committing.

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

The home page build doesn't use `projects/`; the submodules exist for local design work, and
each project still deploys from its own repository.

One-time setup for the domain (zone `sparshlabs.com` on Cloudflare):

1. **DNS**: the routes only see traffic for proxied hostnames. If the apex has no record yet,
   add `AAAA @ 100::` (proxied, orange cloud), and the same for `www`.
2. **www**: add a Redirect Rule `www.sparshlabs.com/*` → `https://sparshlabs.com/${1}` (301).
3. Deploy this Worker first, then merge the sparsh and ownci branches that add their routes.
   `wrangler deploy` creates the routes from `wrangler.jsonc`; the API token used by Workers
   Builds needs *Workers Routes: Edit* on the zone.
4. **author.sparshlabs.com**: the bio is `dist/author/index.html` from this repo, served by the
   same Worker (route `author.sparshlabs.com/*` in `wrangler.jsonc`). Three dashboard settings:
   - DNS: `AAAA author 100::` (proxied).
   - **Rules → URL Rewrite Rule**: when `http.host eq "author.sparshlabs.com" and
     http.request.uri.path eq "/"`, rewrite the path (static) to `/author/`. Only `/` is
     rewritten, so `/_astro/*` and `/favicon.svg` load as they do on the apex.
   - **Rules → Redirect Rule**: when `http.host eq "sparshlabs.com" and
     starts_with(http.request.uri.path, "/author")`, 301 to `https://author.sparshlabs.com/`,
     so the bio has one public address.

   Because the page is served from another host, every link on it back to the lab is absolute:
   `BaseLayout` takes `absoluteLinks` (header and footer) and `canonical`.

Project sites build into `dist/<slug>/` with Astro `base: '/<slug>'`, because Workers static
assets don't strip the path prefix. Each project's `_headers` uses `/<slug>/…` patterns.

## Adding a project

1. `git submodule add -b <default-branch> https://github.com/ashfaqc137/<repo>.git projects/<slug>`.
2. In the project's site: copy `src/lib/paths.ts` from ownci or sparsh, set
   `base: '/<slug>'` and `outDir: './dist/<slug>'` in `astro.config.mjs`, send internal links
   through `href()`, import the fonts and `sparshlabs.css`, and add the route
   `sparshlabs.com/<slug>*` to its `wrangler.jsonc`.
3. Add the project to `scripts/setup.sh`, `scripts/sync-theme.sh` and `scripts/preview-all.sh`.
4. Add an entry to `src/data/projects.ts` (and a mark style in `src/styles/site.css`).

## Local preview of the whole domain

`npm run preview-all` builds sparshlabs, `projects/ownci/website` and `projects/sparsh` (with
`pnpm run build:website`), merges the three `dist/` folders into one tree, and serves it with
`wrangler dev` on http://localhost:8787, which handles trailing-slash redirects, 404 pages and
`_headers` the way production does. Pass `--no-build` to reuse existing builds.
