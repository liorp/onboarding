#!/bin/bash

echo "Configuring Codex..."

# Directory containing this script and the Codex config
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CODEX_CONFIG_SOURCE="$SCRIPT_DIR/codex/config.toml"
CODEX_CONFIG_TARGET_DIR="$HOME/.config/codex"

mkdir -p "$CODEX_CONFIG_TARGET_DIR"
cp "$CODEX_CONFIG_SOURCE" "$CODEX_CONFIG_TARGET_DIR/config.toml"
