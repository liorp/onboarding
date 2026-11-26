#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

# Short aliases for the AI coding CLIs installed by the apps step.
configure_ai_cli_aliases() {
    echo "Adding AI CLI aliases to .zshrc..."
    append_zshrc_line "# AI CLI aliases" true
    append_zshrc_line 'alias c="claude"'
    append_zshrc_line 'alias co="codex"'
    append_zshrc_line 'alias cu="cursor-agent"'
    append_zshrc_line 'alias g="grok"'
}

configure_ai_cli_aliases
