#!/bin/bash

set -euo pipefail

# manual_apps.sh opens App Store pages only for apps that are missing, and
# never installs them itself.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/bin" "$TEST_DIR/Applications/Xcode.app"

cat > "$TEST_DIR/bin/open" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$OPEN_LOG"
STUB
chmod +x "$TEST_DIR/bin/open"

export OPEN_LOG="$TEST_DIR/open.log"
APPLICATIONS_DIR="$TEST_DIR/Applications" PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    bash "$REPO_ROOT/src/manual_apps.sh" >/dev/null </dev/null

if ! grep -Fxq 'macappstore://apps.apple.com/app/id937984704' "$OPEN_LOG"; then
    echo "expected the missing Amphetamine store page to open" >&2
    cat "$OPEN_LOG" >&2
    exit 1
fi

if grep -Fq 'id497799835' "$OPEN_LOG"; then
    echo "must not open the store page for an installed app (Xcode)" >&2
    exit 1
fi

# Amphetamine missing and no terminal: never block waiting, never launch it.
if grep -Fq 'Amphetamine.app' "$OPEN_LOG"; then
    echo "must not launch an app that is not installed" >&2
    exit 1
fi

# Installed and marked for launch: Amphetamine is launched, Xcode is not.
mkdir -p "$TEST_DIR/Applications/Amphetamine.app"
: > "$OPEN_LOG"
APPLICATIONS_DIR="$TEST_DIR/Applications" PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    bash "$REPO_ROOT/src/manual_apps.sh" >/dev/null </dev/null

if ! grep -Fxq -- "-a $TEST_DIR/Applications/Amphetamine.app" "$OPEN_LOG"; then
    echo "expected installed Amphetamine to be launched" >&2
    cat "$OPEN_LOG" >&2
    exit 1
fi
if grep -Fq -e 'Xcode.app' -e 'macappstore' "$OPEN_LOG"; then
    echo "must not launch Xcode or open store pages for installed apps" >&2
    cat "$OPEN_LOG" >&2
    exit 1
fi

echo "manual_apps_test: ok"
