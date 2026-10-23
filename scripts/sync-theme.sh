#!/bin/sh
# Copy theme/sparshlabs.css into every project site that uses it (the submodules in projects/).
#
#   sh scripts/sync-theme.sh          copy the theme into each project
#   sh scripts/sync-theme.sh --check  exit 1 if any project's copy differs (for CI or pre-commit)
#
# Each project builds on its own (Cloudflare builds the project repo alone), so it carries a copy
# of the theme rather than importing this file. After syncing, commit the copy inside each
# submodule, then commit the new submodule pointers here.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
src="$here/theme/sparshlabs.css"
check=false
[ "${1:-}" = "--check" ] && check=true

status=0
for dest in \
  "$here/projects/sparsh/apps/website/src/styles/sparshlabs.css" \
  "$here/projects/ownci/website/src/styles/sparshlabs.css"
do
  if [ ! -d "$(dirname "$dest")" ]; then
    echo "skip   $dest (submodule not checked out: run npm run setup)"
    status=1
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
