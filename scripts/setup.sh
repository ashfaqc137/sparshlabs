#!/bin/sh
# Check out the project submodules and install every site's dependencies.
set -eu

here=$(cd "$(dirname "$0")/.." && pwd)
cd "$here"

git submodule update --init
npm ci
(cd projects/ownci/website && npm ci)
(cd projects/sparsh && pnpm install --frozen-lockfile)
