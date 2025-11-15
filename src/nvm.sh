#!/bin/bash

install_nvm() {
    local nvm_dir="$HOME/.nvm"

    if [ -d "$nvm_dir" ]; then
        echo "nvm already appears to be installed at $nvm_dir. Skipping reinstall."
        return
    fi

    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
}

install_nvm
