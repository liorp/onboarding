#!/bin/bash

install_codex() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install Codex. Run the brew step first." >&2
        return 1
    fi

    if brew list --cask codex >/dev/null 2>&1; then
        echo "Codex already installed. Skipping."
        return 0
    fi

    echo "Installing Codex via Homebrew..."
    brew install --cask codex
}

configure_codex() {
    echo "Configuring Codex..."

    local script_dir
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local config_source="$script_dir/codex/config.toml"
    local config_target_dir="$HOME/.config/codex"

    mkdir -p "$config_target_dir"
    cp "$config_source" "$config_target_dir/config.toml"
}

install_codex
configure_codex
