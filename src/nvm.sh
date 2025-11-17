#!/bin/bash

install_nvm() {
    local nvm_dir="$HOME/.nvm"

    if [ -d "$nvm_dir" ]; then
        echo "nvm already appears to be installed at $nvm_dir. Skipping reinstall."
        return 0
    fi

    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
}


load_nvm() {
    export NVM_DIR="$HOME/.nvm"

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # shellcheck disable=SC1090
        source "$NVM_DIR/nvm.sh"
        return 0
    fi

    echo "Unable to locate nvm script at $NVM_DIR/nvm.sh." >&2
    echo "Please verify the installation and re-run this script." >&2
    return 1
}

install_lts_node() {
    if ! command -v nvm >/dev/null 2>&1; then
        echo "nvm command not found. Unable to install Node.js LTS." >&2
        return 1
    fi

    echo "Installing latest Node.js LTS release via nvm..."
    nvm install --lts

    echo "Setting Node.js LTS as the default version..."
    nvm alias default 'lts/*'

    echo "Switching the current shell to use the Node.js LTS release..."
    nvm use --lts
}

install_nvm

if load_nvm; then
    install_lts_node
fi
