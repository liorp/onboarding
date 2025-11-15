#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_homebrew() {
    echo "Installing Homebrew..."

    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        append_zshrc_line "# Add Homebrew to PATH" true
        append_zshrc_line 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    brew update
}

install_homebrew
