#!/bin/bash

install_apps() {
    local -a cask_apps=(
        brave-browser
        cursor
        codex
        figma
        slack
        postman
        jetbrains-toolbox
        sublime-text
        mongodb-compass
        firefox
        obsidian
        chatgpt
        docker
        rectangle-pro
        iterm2
        tmux
        maccy
        chatgpt
        google-chrome
        heynote
        fork
        linear-linear
        chatgpt-atlas
        vlc
        slack
        zoom
    )

    local -a brew_formulas=(
        vim
        node
        jq
        awscli
        kubectl
        krew
        sops
        fzf
        starship
        helm
        gh
        glab
        bun
        ollama
        shellcheck
        zsh-autosuggestions
        zsh-syntax-highlighting
        uv
    )

    # Install GUI applications
    for app in "${cask_apps[@]}"; do
        echo "Installing $app..."
        brew install --cask "$app"
    done

    # Install CLI tools
    for formula in "${brew_formulas[@]}"; do
        echo "Installing $formula..."
        brew install "$formula"
    done
}

install_apps
