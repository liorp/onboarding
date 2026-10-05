#!/bin/bash
# shellcheck disable=SC2016  # expected zshrc text is matched literally

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/home" "$TEST_DIR/bin"

cat > "$TEST_DIR/bin/bun" <<'EOF'
#!/bin/bash
set -euo pipefail

printf '%s\n' "$*" >> "$BUN_ARGS_FILE"

if [ "$*" != "add --global cf" ]; then
    echo "unexpected bun invocation: $*" >&2
    exit 1
fi

mkdir -p "$HOME/.bun/bin"
printf '%s\n' '#!/bin/bash' 'echo cf-test' > "$HOME/.bun/bin/cf"
chmod +x "$HOME/.bun/bin/cf"
EOF
chmod +x "$TEST_DIR/bin/bun"

export BUN_ARGS_FILE="$TEST_DIR/bun-args"
export HOME="$TEST_DIR/home"
unset ZDOTDIR
export PATH="$TEST_DIR/bin:/usr/bin:/bin"

bash "$REPO_ROOT/src/cf.sh"
bash "$REPO_ROOT/src/cf.sh"

expected_line='export PATH="$HOME/.bun/bin:$PATH"'
if ! grep -Fx "$expected_line" "$HOME/.zshrc" >/dev/null; then
    echo "zshrc is missing the Bun global bin PATH line" >&2
    exit 1
fi

path_lines="$(grep -Fxc "$expected_line" "$HOME/.zshrc")"
if [ "$path_lines" -ne 1 ]; then
    echo "expected the PATH line once, found $path_lines" >&2
    exit 1
fi

if [ "$(wc -l < "$BUN_ARGS_FILE" | tr -d ' ')" -ne 1 ]; then
    echo "expected one bun install, got:" >&2
    cat "$BUN_ARGS_FILE" >&2
    exit 1
fi

if [ "$(cat "$BUN_ARGS_FILE")" != "add --global cf" ]; then
    echo "bun was not invoked as: bun add --global cf" >&2
    exit 1
fi

if ! grep -q 'source "$SCRIPT_DIR/cf.sh"' "$REPO_ROOT/src/init.sh"; then
    echo "init.sh does not run the Cloudflare CLI step" >&2
    exit 1
fi

if ! grep -q '^cf: apps' "$REPO_ROOT/Makefile"; then
    echo "Makefile cf target does not depend on apps" >&2
    exit 1
fi

echo "cf install test passed"
