#!/bin/bash

set -euo pipefail

latest="${1:-}"

if [ -z "$latest" ]; then
    echo "v0.0.1"
    exit 0
fi

if [[ ! "$latest" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Invalid semantic version tag: $latest" >&2
    exit 1
fi

major="$((10#${BASH_REMATCH[1]}))"
minor="$((10#${BASH_REMATCH[2]}))"
patch="$((10#${BASH_REMATCH[3]} + 1))"

printf 'v%d.%d.%d\n' "$major" "$minor" "$patch"
