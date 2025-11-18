#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_bun() {
    if command -v bun >/dev/null 2>&1; then
        echo "Bun already installed at $(command -v bun). Skipping."
        return 0
    fi

    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
}

configure_bun_path() {
    append_zshrc_line "# Bun configuration" true
    append_zshrc_line "export BUN_INSTALL=\"\$HOME/.bun\""
    append_zshrc_line "export PATH=\"\$BUN_INSTALL/bin:\$PATH\""
}

install_bun
configure_bun_path
