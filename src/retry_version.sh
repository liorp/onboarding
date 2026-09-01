#!/bin/bash

set -euo pipefail

run_id="${1:-}"
if [[ ! "$run_id" =~ ^[0-9]+$ ]]; then
    echo "Invalid GitHub run ID: $run_id" >&2
    exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
marker="Automatic release run $run_id"

while IFS=$'\t' read -r tag subject; do
    if [ "$subject" = "$marker" ]; then
        echo "$tag"
    fi
done | bash "$script_dir/latest_version.sh"
