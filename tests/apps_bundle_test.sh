#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/bin"

cat > "$TEST_DIR/bin/brew" <<'EOF'
#!/bin/bash
set -euo pipefail

case "${1:-}" in
    --repository) echo "$FAKE_BREW_REPO"; exit 0 ;;
    tap) echo "$*" >> "$BREW_TAP_LOG"; exit 0 ;;
    trust) [ "${2:-}" = "--help" ] || echo "$*" >> "$BREW_TRUST_LOG"; exit 0 ;;
esac

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
grep -Fx 'cask "conductor"' "$brewfile" >/dev/null
grep -Fx 'cask "time-out"' "$brewfile" >/dev/null
grep -Fx 'cask "obs"' "$brewfile" >/dev/null
grep -Fx 'cask "t3-code"' "$brewfile" >/dev/null
grep -Fx 'brew "herdr"' "$brewfile" >/dev/null
grep -Fx 'brew "hf"' "$brewfile" >/dev/null
grep -Fx 'brew "coreutils"' "$brewfile" >/dev/null
grep -Fx 'brew "mas"' "$brewfile" >/dev/null
grep -Fx 'mas "Xcode", id: 497799835' "$brewfile" >/dev/null
# azure-cli moved from homebrew/core to a cask.
grep -Fx 'cask "azure-cli"' "$brewfile" >/dev/null
if grep -Fxq 'brew "azure-cli"' "$brewfile"; then
    echo "azure-cli must be installed as a cask" >&2
    exit 1
fi
grep -Fx 'tap "yazinsai/openoats", "https://github.com/yazinsai/OpenOats"' "$brewfile" >/dev/null

if grep -Eq 'cask "(codex-app|chatgpt-atlas)"' "$brewfile"; then
    echo "Brewfile still includes a deprecated app" >&2
    exit 1
fi

expected_casks=39
actual_casks="$(grep -c '^cask ' "$brewfile")"
if [ "$actual_casks" -ne "$expected_casks" ]; then
    echo "expected $expected_casks casks, found $actual_casks" >&2
    exit 1
fi

expected_formulas=27
actual_formulas="$(grep -c '^brew ' "$brewfile")"
if [ "$actual_formulas" -ne "$expected_formulas" ]; then
    echo "expected $expected_formulas formulas, found $actual_formulas" >&2
    exit 1
fi
EOF
chmod +x "$TEST_DIR/bin/brew"

# Every tap is reachable in this test.
cat > "$TEST_DIR/bin/git" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$TEST_DIR/bin/git"

FAKE_BREW_REPO="$TEST_DIR/brew-repo" \
BREW_TAP_LOG="$TEST_DIR/tap.log" \
BREW_TRUST_LOG="$TEST_DIR/trust.log" \
BREW_ARGS_FILE="$TEST_DIR/brew-args" \
XCODE_APP="$TEST_DIR/no-xcode" PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    bash "$REPO_ROOT/src/apps.sh"

if [ "$(wc -l < "$TEST_DIR/brew-args" | tr -d ' ')" -ne 2 ]; then
    echo "expected: brew bundle --file=<path>" >&2
    echo "actual arguments:" >&2
    cat "$TEST_DIR/brew-args" >&2
    exit 1
fi

# Third-party packages are trusted one by one, never as whole taps.
expected_trust='trust --quiet --formula pulumi/tap/pulumi oven-sh/bun/bun
trust --quiet --cask yazinsai/openoats/openoats'
if [ "$(cat "$TEST_DIR/trust.log")" != "$expected_trust" ]; then
    echo "unexpected brew trust calls:" >&2
    cat "$TEST_DIR/trust.log" >&2
    exit 1
fi

grep -Fxq 'tap yazinsai/openoats https://github.com/yazinsai/OpenOats' "$TEST_DIR/tap.log" || {
    echo "OpenOats tap was not added from its repo URL" >&2
    cat "$TEST_DIR/tap.log" >&2
    exit 1
}

echo "apps bundle test passed"
