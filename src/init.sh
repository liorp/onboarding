#!/bin/bash

# MacBook Setup

# Source all initialization scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make all scripts executable
echo "Making all scripts executable..."
chmod +x "$SCRIPT_DIR"/*.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all           Run all configurations (default)"
    echo "  -o, --omz           Run Oh My Zsh setup"
    echo "  -b, --brew          Run Homebrew setup"
    echo "  -p, --apps          Run applications installation"
    echo "  -f, --fzf           Run fzf setup"
    echo "  -k, --kubectl       Run kubectl setup"
    echo "  -s, --starship      Run starship setup"
    echo "  -c, --codex         Run Codex config setup"
    echo "  -y, --pyenv         Run pyenv setup"
    echo "  -m, --manual        Run manual apps installation"
    echo "  -h, --help          Display this help message"
    exit 1
}

# Default to running all if no arguments provided
if [ $# -eq 0 ]; then
    RUN_ALL=true
else
    RUN_ALL=false
fi

# Parse command line arguments
while getopts "abcfkmopstvwyh-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                all) RUN_ALL=true ;;
                omz) source "$SCRIPT_DIR/omz.sh" ;;
                brew) source "$SCRIPT_DIR/homebrew.sh" ;;
                apps) source "$SCRIPT_DIR/apps.sh" ;;
                fzf) source "$SCRIPT_DIR/fzf.sh" ;;
                kubectl) source "$SCRIPT_DIR/kubectl.sh" ;;
                starship) source "$SCRIPT_DIR/starship.sh" ;;
                codex) source "$SCRIPT_DIR/codex.sh" ;;
                pyenv) source "$SCRIPT_DIR/pyenv.sh" ;;
                manual) source "$SCRIPT_DIR/manual_apps.sh" ;;
                help) usage ;;
                *) echo "Invalid option: --${OPTARG}" >&2; usage ;;
            esac ;;
        a) RUN_ALL=true ;;
        o) source "$SCRIPT_DIR/omz.sh" ;;
        b) source "$SCRIPT_DIR/homebrew.sh" ;;
        p) source "$SCRIPT_DIR/apps.sh" ;;
        f) source "$SCRIPT_DIR/fzf.sh" ;;
        k) source "$SCRIPT_DIR/kubectl.sh" ;;
        s) source "$SCRIPT_DIR/starship.sh" ;;
        c) source "$SCRIPT_DIR/codex.sh" ;;
        y) source "$SCRIPT_DIR/pyenv.sh" ;;
        m) source "$SCRIPT_DIR/manual_apps.sh" ;;
        h) usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Run all configurations if specified
if [ "$RUN_ALL" = true ]; then
    echo "Running all configurations..."
    source "$SCRIPT_DIR/omz.sh"
    source "$SCRIPT_DIR/homebrew.sh"
    source "$SCRIPT_DIR/apps.sh"
    source "$SCRIPT_DIR/fzf.sh"
    source "$SCRIPT_DIR/kubectl.sh"
    source "$SCRIPT_DIR/starship.sh"
    source "$SCRIPT_DIR/codex.sh"
    source "$SCRIPT_DIR/pyenv.sh"
    source "$SCRIPT_DIR/manual_apps.sh"
    echo "All applications installed or opened for manual installation."
fi 
