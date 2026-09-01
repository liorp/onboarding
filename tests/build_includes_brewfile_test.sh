#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/bin"

cat > "$TEST_DIR/bin/makeself" <<'EOF'
#!/bin/bash
set -euo pipefail

stage_dir="$2"
if [ ! -f "$stage_dir/Brewfile" ]; then
    echo "self-extracting installer is missing its Brewfile" >&2
    exit 1
fi

output="$3"
tar -cf "$output" -C "$stage_dir" .
EOF
chmod +x "$TEST_DIR/bin/makeself"

PATH="$TEST_DIR/bin:/usr/bin:/bin" bash "$REPO_ROOT/build.sh" test

artifact="$REPO_ROOT/dist/onboarding-test.run"
if ! tar -tf "$artifact" | grep -Fx './Brewfile' >/dev/null; then
    echo "built artifact does not contain its Brewfile" >&2
    exit 1
fi

echo "build Brewfile test passed"
