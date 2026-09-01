#!/bin/bash
# Build a self-extracting installer that bundles all onboarding scripts
# into a single executable artifact via makeself.
#
# Usage:
#   bash build.sh                 # builds dist/onboarding-dev.run
#   bash build.sh v1.2.3          # builds dist/onboarding-v1.2.3.run
#   VERSION=v1.2.3 bash build.sh  # same, via env var

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
VERSION="${1:-${VERSION:-dev}}"

if ! command -v makeself >/dev/null 2>&1; then
    echo "makeself is required but not installed." >&2
    echo "  macOS:  brew install makeself" >&2
    echo "  Ubuntu: sudo apt-get install makeself" >&2
    exit 1
fi

STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

mkdir -p "$DIST_DIR"

cp -R "$SCRIPT_DIR/src" "$STAGE_DIR/src"
cp "$SCRIPT_DIR/main.sh" "$STAGE_DIR/main.sh"
cp "$SCRIPT_DIR/Brewfile" "$STAGE_DIR/Brewfile"
chmod +x "$STAGE_DIR/main.sh"

echo "$VERSION" > "$STAGE_DIR/VERSION"

OUTPUT="$DIST_DIR/onboarding-$VERSION.run"

makeself \
    --sha256 \
    "$STAGE_DIR" \
    "$OUTPUT" \
    "MacBook Onboarding $VERSION" \
    ./main.sh

echo "Built $OUTPUT"
