#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/src/retry_version.sh"

input=$'v2.0.0\tManual release\nv1.4.3\tAutomatic release run 12345\nv9.0.0-rc.1\tAutomatic release run 12345\n'

actual="$(printf '%s' "$input" | bash "$SCRIPT" "12345")"
if [ "$actual" != "v1.4.3" ]; then
    echo "expected matching automatic retry tag v1.4.3, got '$actual'" >&2
    exit 1
fi

actual="$(printf '%s' "$input" | bash "$SCRIPT" "99999")"
if [ -n "$actual" ]; then
    echo "expected unrelated run to ignore all tags, got '$actual'" >&2
    exit 1
fi

echo "retry version test passed"
