#!/bin/bash

install_apps() {
    local -a cask_apps=(
        brave-browser
        visual-studio-code
        codex
        codexbar
        codex-app
        claude-code@latest
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
        warp
        yazinsai/openoats/openoats
        docker-desktop
        wispr-flow
        ollama-app
        gcloud-cli
    )

    local -a brew_formulas=(
        vim
        tmux
        node
        jq
        awscli
        azure-cli
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
        pulumi/tap/pulumi
        oven-sh/bun/bun
        rtk
        typescript-language-server
    )

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install apps. Run the brew step first." >&2
        return 1
    fi

    # Install GUI applications
    for app in "${cask_apps[@]}"; do
        if brew list --cask "${app##*/}" >/dev/null 2>&1; then
            echo "$app already installed. Skipping."
            continue
        fi
        echo "Installing $app..."
        brew install --cask "$app"
    done

    # Install CLI tools
    for formula in "${brew_formulas[@]}"; do
        if brew list --formula "${formula##*/}" >/dev/null 2>&1; then
            echo "$formula already installed. Skipping."
            continue
        fi
        echo "Installing $formula..."
        brew install "$formula"
    done
}

install_apps
