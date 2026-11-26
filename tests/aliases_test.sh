#!/bin/bash
# shellcheck disable=SC2016  # expected zshrc text is matched literally

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

export HOME="$TEST_DIR"
unset ZDOTDIR

# Running twice must not duplicate anything.
bash "$REPO_ROOT/src/aliases.sh" >/dev/null
bash "$REPO_ROOT/src/aliases.sh" >/dev/null

for line in 'alias c="claude"' 'alias co="codex"' 'alias cu="cursor-agent"' 'alias g="grok"'; do
    count="$(grep -Fxc "$line" "$HOME/.zshrc" || true)"
    if [ "$count" -ne 1 ]; then
        echo "expected '$line' once in .zshrc, found $count" >&2
        exit 1
    fi
done

if ! grep -qx '    run_step aliases' "$REPO_ROOT/src/init.sh"; then
    echo "init.sh does not run the aliases step" >&2
    exit 1
fi

echo "aliases_test: ok"
