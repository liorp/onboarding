#!/bin/bash

install_fzf_and_prompt() {
    echo -e "\n# Initialize Starship prompt" >> ~/.zshrc
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    echo 'source <(fzf --zsh)' >> ~/.zshrc
}

install_fzf_and_prompt
