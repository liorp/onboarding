#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_uv() {
    if command -v uv >/dev/null 2>&1; then
        echo "uv already installed at $(command -v uv). Skipping installation."
        return 0
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "Installing uv via Homebrew..."
        brew install uv
        return 0
    fi

    echo "Homebrew not found. Installing uv via official script..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

update_uv_shell() {
    if ! command -v uv >/dev/null 2>&1; then
        echo "uv command not found. Unable to update shell configuration for uv tools." >&2
        return 1
    fi

    echo "Ensuring uv tool executables are available on PATH..."
    uv tool update-shell
}

install_uv
update_uv_shell
