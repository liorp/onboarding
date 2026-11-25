#!/bin/bash
# An unreachable tap must not abort the whole bundle: it and its packages are
# skipped, everything else is installed, and the step reports failure.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/bin" "$TEST_DIR/pkg/src" "$TEST_DIR/brew-repo/Library/Taps/tapped/homebrew-already"
cp "$REPO_ROOT/src/apps.sh" "$TEST_DIR/pkg/src/apps.sh"

cat > "$TEST_DIR/pkg/Brewfile" <<'EOF2'
tap "gone/tap", "https://example.invalid/gone/tap"
tap "good/explicit", "https://example.invalid/good/explicit"
cask "firefox"
cask "gone/tap/app"
cask "good/explicit/app"
brew "jq"
brew "implicit/gone/tool"
brew "implicit/good/tool"
brew "tapped/already/tool"
EOF2

cat > "$TEST_DIR/bin/brew" <<'EOF2'
#!/bin/bash
set -euo pipefail
case "${1:-}" in
    --repository) echo "$FAKE_BREW_REPO" ;;
    bundle) cp "${2#--file=}" "$BUNDLED_FILE" ;;
    tap) ;;
    trust) [ "${2:-}" = "--help" ] || echo "$*" >> "$TRUST_LOG" ;;
    *) echo "unexpected: brew $*" >&2; exit 1 ;;
esac
EOF2

# Reachable unless the URL names a "gone" tap; must never be asked about an
# already-tapped tap.
cat > "$TEST_DIR/bin/git" <<'EOF2'
#!/bin/bash
url="${*: -2:1}"
echo "$url" >> "$GIT_LOG"
case "$url" in
    *already*) echo "checked an already-tapped tap" >&2; exit 2 ;;
    *gone*) exit 128 ;;
esac
exit 0
EOF2
chmod +x "$TEST_DIR/bin/brew" "$TEST_DIR/bin/git"

status=0
FAKE_BREW_REPO="$TEST_DIR/brew-repo" BUNDLED_FILE="$TEST_DIR/bundled" GIT_LOG="$TEST_DIR/git.log" TRUST_LOG="$TEST_DIR/trust.log" \
XCODE_APP="$TEST_DIR/no-xcode" PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    bash "$TEST_DIR/pkg/src/apps.sh" 2> "$TEST_DIR/stderr" || status=$?

fail() { echo "FAIL: $*" >&2; cat "$TEST_DIR/stderr" >&2; exit 1; }

[ "$status" -ne 0 ] || fail "expected non-zero exit when a tap is skipped"
[ -f "$TEST_DIR/bundled" ] || fail "brew bundle was not run"

for line in 'cask "firefox"' 'brew "jq"' 'tap "good/explicit", "https://example.invalid/good/explicit"' \
            'cask "good/explicit/app"' 'brew "implicit/good/tool"' 'brew "tapped/already/tool"'; do
    grep -Fxq "$line" "$TEST_DIR/bundled" || fail "missing kept entry: $line"
done
for pattern in 'gone/tap' 'implicit/gone'; do
    if grep -Fq "$pattern" "$TEST_DIR/bundled"; then fail "unreachable entry kept: $pattern"; fi
    grep -Fq "$pattern" "$TEST_DIR/stderr" || fail "no warning for $pattern"
done
if grep -Fq 'gone' "$TEST_DIR/trust.log"; then fail "trusted a package from a skipped tap"; fi
grep -Fq 'implicit/good/tool' "$TEST_DIR/trust.log" || fail "reachable third-party formula not trusted"
grep -Fxq "https://github.com/implicit/homebrew-gone" "$TEST_DIR/git.log" || fail "implicit tap URL not derived"

echo "apps skip unreachable tap test passed"
