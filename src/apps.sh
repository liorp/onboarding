#!/bin/bash

# List of applications to install via Homebrew Cask
apps=(
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
)

# Install applications
for app in "${apps[@]}"; do
    echo "Installing $app..."
    brew install --cask $app
done 