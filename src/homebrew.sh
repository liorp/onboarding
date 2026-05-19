#!/bin/bash
# shellcheck disable=SC2016  # single-quoted strings are written verbatim into .zshrc for later expansion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew already installed at $(command -v brew). Skipping."
        return 0
    fi

    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    append_zshrc_line "# Add Homebrew to PATH" true
    append_zshrc_line 'eval "$(/opt/homebrew/bin/brew shellenv)"'
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew update
}

install_homebrew
