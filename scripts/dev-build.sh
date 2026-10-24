#!/bin/bash
# Local development build:
#   - independent bundle id (local.opencontexts.mod) + display name (OpenContexts_mod),
#     so it does NOT clash with an installed release (local.opencontexts.app) in
#     System Settings > Privacy > Accessibility;
#   - stable self-signed signature, so Accessibility (TCC) permission survives rebuilds.
#
# Usage: ./scripts/dev-build.sh [debug|release]   (defaults to debug)
# First run shows a one-time keychain prompt on codesign — click "Always Allow".
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/create-signing-cert.sh

bundle_name="${APP_BUNDLE_NAME:-OpenContexts_mod}"

BUNDLE_ID="${BUNDLE_ID:-local.opencontexts.mod}" \
APP_NAME="${APP_NAME:-OpenContexts_mod}" \
APP_BUNDLE_NAME="$bundle_name" \
SIGNING_MODE=self-signed \
./scripts/build-app.sh "${1:-debug}"

# Relaunch cleanly. `open` only re-activates an already-running instance, so if the previous
# mod process is still alive (quit is async), it would re-activate the old/quitting process
# instead of launching the new build. Kill the running MOD instance (the release build lives at
# a different path and is matched out), wait for it to fully exit, then open.
pattern="/$bundle_name.app/Contents/MacOS/"
pkill -f "$pattern" 2>/dev/null || true
for _ in $(seq 1 50); do
    pgrep -f "$pattern" >/dev/null 2>&1 || break
    sleep 0.1
done
open "dist/$bundle_name.app"
