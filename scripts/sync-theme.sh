#!/bin/sh
# Copy theme/sparshlabs.css into every project site that uses it.
#
#   sh scripts/sync-theme.sh          copy the theme into each project
#   sh scripts/sync-theme.sh --check  exit 1 if any project's copy differs (for CI or pre-commit)
#
# Projects are expected next to this repo (../sparsh, ../ownci). Set SPARSHLABS_WORK to the
# directory that holds them if they live elsewhere.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
work=${SPARSHLABS_WORK:-$(dirname "$here")}
src="$here/theme/sparshlabs.css"
check=false
[ "${1:-}" = "--check" ] && check=true

status=0
for dest in \
  "$work/sparsh/apps/website/src/styles/sparshlabs.css" \
  "$work/ownci/website/src/styles/sparshlabs.css"
do
  if [ ! -d "$(dirname "$dest")" ]; then
    echo "skip   $dest (project not found)"
    continue
  fi
  if $check; then
    if cmp -s "$src" "$dest"; then echo "ok     $dest"; else echo "stale  $dest"; status=1; fi
  else
    cp "$src" "$dest"
    echo "synced $dest"
  fi
done
exit $status
