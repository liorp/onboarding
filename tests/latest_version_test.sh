#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/src/latest_version.sh"

assert_latest() {
    local expected="$1"
    local tags="$2"
    local actual
    actual="$(printf '%s' "$tags" | bash "$SCRIPT")"

    if [ "$actual" != "$expected" ]; then
        echo "expected latest '$expected', got '$actual'" >&2
        exit 1
    fi
}

assert_latest "" $'release\nv1.0'
assert_latest "v1.1.11" $'v1.1.9\nv2.0.0-rc.1\nv1.1.11\ninvalid'
assert_latest "v10.2.3" $'v2.99.99\nv10.2.3\nv10.2.3-beta'

echo "latest version test passed"
