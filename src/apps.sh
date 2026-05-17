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
        rectangle-pro
        iterm2
        maccy
        google-chrome
        heynote
        fork
        linear-linear
        chatgpt-atlas
        vlc
        zoom
        karabiner-elements
        notion
        whatsapp
        yazinsai/openoats/openoats
    )

    local -a brew_formulas=(
        vim
        tmux
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
        ollama
        shellcheck
        zsh-autosuggestions
        zsh-syntax-highlighting
        uv
        pnpm
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
