#!/bin/bash

echo "Creating starship config directory..."
mkdir -p ~/.config

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy the starship configuration
cp "$SCRIPT_DIR/starship.toml" ~/.config/starship.toml 