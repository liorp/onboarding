#!/bin/bash

set -euo pipefail

# init.sh must keep running after a failed step, name it at the end, and exit
# non-zero instead of claiming everything installed.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/src"
cp "$REPO_ROOT/src/init.sh" "$TEST_DIR/src/init.sh"

# Stub every step: apps fails, the rest log that they ran.
echo 'true' > "$TEST_DIR/src/xcode.sh"
for step in homebrew omz nvm cf uv fzf kubectl starship codex projects pyenv manual_apps vscode macos_settings; do
    echo "echo ran-$step" > "$TEST_DIR/src/$step.sh"
done
echo 'echo ran-apps; false' > "$TEST_DIR/src/apps.sh"

status=0
output="$(bash "$TEST_DIR/src/init.sh" 2>&1)" || status=$?

if [ "$status" -eq 0 ]; then
    echo "expected non-zero exit when a step fails" >&2
    echo "$output" >&2
    exit 1
fi

if ! grep -qx '  - apps' <<<"$output"; then
    echo "expected the failed step to be listed, got:" >&2
    echo "$output" >&2
    exit 1
fi

if ! grep -qx 'ran-macos_settings' <<<"$output"; then
    echo "expected later steps to still run after a failure" >&2
    exit 1
fi

if grep -q 'All applications installed' <<<"$output"; then
    echo "must not claim success when a step failed" >&2
    exit 1
fi

# All steps succeed: exit 0 with the success message.
echo 'echo ran-apps' > "$TEST_DIR/src/apps.sh"
output="$(bash "$TEST_DIR/src/init.sh" 2>&1)"
grep -q 'All applications installed' <<<"$output"

echo "init_reports_failed_steps_test: ok"
