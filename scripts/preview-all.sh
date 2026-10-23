#!/bin/sh
# Build sparshlabs, sparsh and ownci, merge them into one tree laid out the way sparshlabs.com
# routes them, and serve it with wrangler dev on http://localhost:8787.
#
#   sh scripts/preview-all.sh            build everything, then serve
#   sh scripts/preview-all.sh --no-build serve the existing dist/ folders
#
# In production these are three Workers on separate routes; here one Worker serves the merged
# tree, which behaves the same for paths, trailing slashes and 404 pages.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
work=${SPARSHLABS_WORK:-$(dirname "$here")}
ownci="$work/ownci/website"
sparsh="$work/sparsh/apps/website"
out=${SPARSHLABS_PREVIEW_DIR:-"${TMPDIR:-/tmp}/sparshlabs-preview"}

if [ "${1:-}" != "--no-build" ]; then
  (cd "$here" && npm run build)
  (cd "$ownci" && npm run build)
  (cd "$work/sparsh" && pnpm run build:website)
fi

rm -rf "$out"
mkdir -p "$out/site"
cp -R "$here/dist/." "$out/site/"
cp -R "$ownci/dist/ownci" "$out/site/ownci"
cp -R "$sparsh/dist/sparsh" "$out/site/sparsh"

# One _headers file for the merged tree. The lab's strict CSP is on /*, which would also cover
# /sparsh/*; sparsh's React islands need scripts, so detach that header there (production never
# needs this: each Worker only sees its own _headers).
{
  cat "$here/dist/_headers"
  echo
  cat "$ownci/dist/_headers"
  echo
  cat "$sparsh/dist/_headers"
  echo
  printf '/sparsh/*\n  ! Content-Security-Policy\n'
} > "$out/site/_headers"

cat > "$out/wrangler.jsonc" <<EOF
{
  "name": "sparshlabs-preview",
  "compatibility_date": "2026-10-08",
  "assets": { "directory": "./site", "not_found_handling": "404-page" }
}
EOF

echo "Serving $out/site on http://localhost:8787"
exec "$here/node_modules/.bin/wrangler" dev -c "$out/wrangler.jsonc" --port 8787
