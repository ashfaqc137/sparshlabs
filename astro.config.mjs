import { defineConfig } from 'astro/config'

// Fully static site served at the root of sparshlabs.com; the only script is the copy button in
// components/Code.astro. Project sites (sparsh, ownci) are separate Workers on /sparsh* and
// /ownci* routes. Stylesheets, scripts and fonts are emitted as files (never inlined) so the
// Content-Security-Policy in _headers can stay at 'self' with no 'unsafe-inline'.
export default defineConfig({
  site: 'https://sparshlabs.com',
  trailingSlash: 'always',
  build: {
    inlineStylesheets: 'never',
  },
  vite: {
    build: {
      assetsInlineLimit: 0,
    },
  },
})
