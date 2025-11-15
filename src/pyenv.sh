#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/zshrc_helpers.sh
source "$SCRIPT_DIR/zshrc_helpers.sh"

install_pyenv() {
    echo "Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
    append_zshrc_line "# Pyenv configuration" true
    append_zshrc_line 'export PYENV_ROOT="$HOME/.pyenv"'
    append_zshrc_line '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    append_zshrc_line 'eval "$(pyenv init - zsh)"'
}

install_pyenv
