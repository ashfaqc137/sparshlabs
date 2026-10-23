import { defineConfig } from 'astro/config'

// Fully static, script-free site served at the root of sparshlabs.com. Project sites (sparsh,
// ownci) are separate Workers on /sparsh* and /ownci* routes. Stylesheets and fonts are emitted
// as files (never inlined) so the Content-Security-Policy in _headers can stay at 'self'.
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
