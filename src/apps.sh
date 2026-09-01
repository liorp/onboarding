#!/bin/bash

install_apps() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local brewfile="$script_dir/../Brewfile"

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install apps. Run the brew step first." >&2
        return 1
    fi

    if [ ! -f "$brewfile" ]; then
        echo "Brewfile not found at $brewfile." >&2
        return 1
    fi

    brew bundle --file="$brewfile"
}

install_apps
