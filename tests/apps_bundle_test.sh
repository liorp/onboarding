#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/bin"

cat > "$TEST_DIR/bin/brew" <<'EOF'
#!/bin/bash
set -euo pipefail

printf '%s\n' "$@" > "$BREW_ARGS_FILE"

if [ "${1:-}" != "bundle" ]; then
    echo "expected one brew bundle invocation, got: brew $*" >&2
    exit 1
fi

brewfile=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --file=*) brewfile="${1#--file=}" ;;
        --no-upgrade)
            echo "brew bundle must retain its default upgrade behavior" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$brewfile" ] || [ ! -f "$brewfile" ]; then
    echo "brew bundle did not receive a valid Brewfile" >&2
    exit 1
fi

grep -Fx 'cask "grok-build"' "$brewfile" >/dev/null
grep -Fx 'cask "cursor-cli"' "$brewfile" >/dev/null
grep -Fx 'cask "time-out"' "$brewfile" >/dev/null

if grep -Eq 'cask "(codex-app|chatgpt-atlas)"' "$brewfile"; then
    echo "Brewfile still includes a deprecated app" >&2
    exit 1
fi

expected_casks=35
actual_casks="$(grep -c '^cask ' "$brewfile")"
if [ "$actual_casks" -ne "$expected_casks" ]; then
    echo "expected $expected_casks casks, found $actual_casks" >&2
    exit 1
fi

expected_formulas=24
actual_formulas="$(grep -c '^brew ' "$brewfile")"
if [ "$actual_formulas" -ne "$expected_formulas" ]; then
    echo "expected $expected_formulas formulas, found $actual_formulas" >&2
    exit 1
fi
EOF
chmod +x "$TEST_DIR/bin/brew"

BREW_ARGS_FILE="$TEST_DIR/brew-args" \
PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    bash "$REPO_ROOT/src/apps.sh"

if [ "$(wc -l < "$TEST_DIR/brew-args" | tr -d ' ')" -ne 2 ]; then
    echo "expected: brew bundle --file=<path>" >&2
    echo "actual arguments:" >&2
    cat "$TEST_DIR/brew-args" >&2
    exit 1
fi

echo "apps bundle test passed"
