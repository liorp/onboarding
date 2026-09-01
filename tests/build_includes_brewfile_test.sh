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
EOF
chmod +x "$TEST_DIR/bin/makeself"

PATH="$TEST_DIR/bin:/usr/bin:/bin" bash "$REPO_ROOT/build.sh" test

echo "build Brewfile test passed"
