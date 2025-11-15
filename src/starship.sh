#!/bin/bash

install_starship_config() {
    echo "Creating starship config directory..."
    mkdir -p ~/.config

    # Get the directory where this script is located
    local script_dir
    script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Copy the starship configuration
    cp "$script_dir/starship.toml" ~/.config/starship.toml
}

install_starship_config
