#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_bun() {
    if command -v bun >/dev/null 2>&1; then
        echo "Bun already installed at $(command -v bun). Skipping."
        return 0
    fi

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install Bun. Run the brew step first." >&2
        return 1
    fi

    echo "Installing Bun via Homebrew (oven-sh/bun)..."
    brew tap oven-sh/bun
    brew install bun
}

configure_bun_path() {
    append_zshrc_line "# Bun configuration" true
    append_zshrc_line "export BUN_INSTALL=\"\$HOME/.bun\""
    append_zshrc_line "export PATH=\"\$BUN_INSTALL/bin:\$PATH\""
}

install_bun
configure_bun_path
