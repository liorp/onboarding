#!/bin/bash
# shellcheck disable=SC2016  # single-quoted strings are written verbatim into .zshrc for later expansion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

# `bun add --global` links binaries here. Homebrew's bun formula does not.
bun_global_bin="$HOME/.bun/bin"

configure_bun_path() {
    export PATH="$bun_global_bin:$PATH"
    append_zshrc_line "# Bun global binaries" true
    append_zshrc_line 'export PATH="$HOME/.bun/bin:$PATH"'
}

install_cloudflare_cli() {
    if ! command -v bun >/dev/null 2>&1; then
        echo "Bun is required to install the Cloudflare CLI. Run the apps step first." >&2
        return 1
    fi

    if [ -x "$bun_global_bin/cf" ]; then
        echo "Cloudflare CLI already installed at $bun_global_bin/cf. Skipping."
        return 0
    fi

    echo "Installing Cloudflare CLI (cf) via Bun..."
    bun add --global cf

    if [ ! -x "$bun_global_bin/cf" ]; then
        echo "Cloudflare CLI install finished, but $bun_global_bin/cf is missing." >&2
        return 1
    fi

    echo "Cloudflare CLI installed. Sign in later with: cf auth login"
}

configure_bun_path
install_cloudflare_cli
