#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

configure_kubectl_tools() {
    echo "Installing kubectl krew plugins..."
    kubectl krew install ctx
    kubectl krew install ns
    append_zshrc_line "# Kubectl aliases and krew" true
    append_zshrc_line 'alias k="kubectl"'
    append_zshrc_line 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'
}

configure_kubectl_tools
