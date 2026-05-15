#!/bin/bash
# shellcheck disable=SC2016  # single-quoted strings are written verbatim into .zshrc for later expansion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_fzf_and_prompt() {
    append_zshrc_line "# Initialize Starship prompt" true
    append_zshrc_line 'eval "$(starship init zsh)"'
    append_zshrc_line 'source <(fzf --zsh)'
}

install_fzf_and_prompt
