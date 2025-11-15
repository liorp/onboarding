#!/bin/bash

configure_kubectl_tools() {
    echo "Installing kubectl krew plugins..."
    kubectl krew install ctx
    kubectl krew install ns
    echo -e "\n# Kubectl aliases and krew" >> ~/.zshrc
    echo 'alias k="kubectl"' >> ~/.zshrc
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.zshrc
}

configure_kubectl_tools
