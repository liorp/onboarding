#!/bin/bash

# List of GUI applications to install via Homebrew Cask
cask_apps=(
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
)

# List of CLI tools to install via regular Homebrew formulae
brew_formulas=(
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
