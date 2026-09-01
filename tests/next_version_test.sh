#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/src/next_version.sh"

assert_version() {
    local latest="$1"
    local expected="$2"
    local actual
    actual="$(bash "$SCRIPT" "$latest")"

    if [ "$actual" != "$expected" ]; then
        echo "latest $latest: expected $expected, got $actual" >&2
        exit 1
    fi
}

assert_version "" "v0.0.1"
assert_version "v1.1.11" "v1.1.12"
assert_version "v2.7.99" "v2.7.100"

if bash "$SCRIPT" "1.2.3" >/dev/null 2>&1; then
    echo "expected an invalid tag to fail" >&2
    exit 1
fi

echo "next version test passed"
