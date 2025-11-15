#!/bin/bash

install_fzf_and_prompt() {
    echo "Installing fzf..."
    "$(brew --prefix)/opt/fzf/install"
    echo -e "\n# Initialize Starship prompt" >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
}

install_fzf_and_prompt
