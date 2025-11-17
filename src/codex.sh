#!/bin/bash

configure_codex() {
    echo "Configuring Codex..."

    local script_dir
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local config_source="$script_dir/codex/config.toml"
    local config_target_dir="$HOME/.config/codex"

    mkdir -p "$config_target_dir"
    cp "$config_source" "$config_target_dir/config.toml"
}

configure_codex
