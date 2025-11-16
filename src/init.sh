#!/bin/bash
# shellcheck disable=SC1091

# MacBook Setup

# Source all initialization scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=src/omz.sh
# shellcheck source=src/nvm.sh
# shellcheck source=src/homebrew.sh
# shellcheck source=src/apps.sh
# shellcheck source=src/fzf.sh
# shellcheck source=src/kubectl.sh
# shellcheck source=src/starship.sh
# shellcheck source=src/codex.sh
# shellcheck source=src/projects.sh
# shellcheck source=src/pyenv.sh
# shellcheck source=src/manual_apps.sh
# shellcheck source=src/macos_settings.sh

# Make all scripts executable
echo "Making all scripts executable..."
chmod +x "$SCRIPT_DIR"/*.sh

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all           Run all configurations (default)"
    echo "  -o, --omz           Run Oh My Zsh setup"
    echo "  -n, --nvm           Run nvm setup"
    echo "  -b, --brew          Run Homebrew setup"
    echo "  -p, --apps          Run applications installation"
    echo "  -f, --fzf           Run fzf setup"
    echo "  -k, --kubectl       Run kubectl setup"
    echo "  -s, --starship      Run starship setup"
    echo "  -c, --codex         Run Codex config setup"
    echo "  -r, --projects      Create projects directory in home"
    echo "  -y, --pyenv         Run pyenv setup"
    echo "  -m, --manual        Run manual apps installation"
    echo "  -t, --macos-settings Apply macOS system settings"
    echo "  -h, --help          Display this help message"
    exit 1
}

# Ensure macOS developer tools are installed
ensure_macos_developer_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        echo "macOS developer tools already installed."
    else
        echo "macOS developer tools not found. Installing now..."
        if /usr/bin/xcode-select --install >/dev/null 2>&1; then
            echo "macOS developer tools installation started."
            echo "Complete the on-screen prompts, then re-run this script."
        else
            echo "Unable to start macOS developer tools installation. Please install them manually and re-run this script." >&2
        fi
        exit 0
    fi
}

# Install dev tools before doing anything else
ensure_macos_developer_tools

# Default to running all if no arguments provided
if [ $# -eq 0 ]; then
    RUN_ALL=true
else
    RUN_ALL=false
fi

# Parse command line arguments
while getopts "aonbpfkscrymth-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                all) RUN_ALL=true ;;
                omz) source "$SCRIPT_DIR/omz.sh" ;;
                nvm) source "$SCRIPT_DIR/nvm.sh" ;;
                brew) source "$SCRIPT_DIR/homebrew.sh" ;;
                apps) source "$SCRIPT_DIR/apps.sh" ;;
                fzf) source "$SCRIPT_DIR/fzf.sh" ;;
                kubectl) source "$SCRIPT_DIR/kubectl.sh" ;;
                starship) source "$SCRIPT_DIR/starship.sh" ;;
                codex) source "$SCRIPT_DIR/codex.sh" ;;
                projects) source "$SCRIPT_DIR/projects.sh" ;;
                pyenv) source "$SCRIPT_DIR/pyenv.sh" ;;
                manual) source "$SCRIPT_DIR/manual_apps.sh" ;;
                macos-settings) source "$SCRIPT_DIR/macos_settings.sh" ;;
                help) usage ;;
                *) echo "Invalid option: --${OPTARG}" >&2; usage ;;
            esac ;;
        a) RUN_ALL=true ;;
        o) source "$SCRIPT_DIR/omz.sh" ;;
        n) source "$SCRIPT_DIR/nvm.sh" ;;
        b) source "$SCRIPT_DIR/homebrew.sh" ;;
        p) source "$SCRIPT_DIR/apps.sh" ;;
        f) source "$SCRIPT_DIR/fzf.sh" ;;
        k) source "$SCRIPT_DIR/kubectl.sh" ;;
        s) source "$SCRIPT_DIR/starship.sh" ;;
        c) source "$SCRIPT_DIR/codex.sh" ;;
        r) source "$SCRIPT_DIR/projects.sh" ;;
        y) source "$SCRIPT_DIR/pyenv.sh" ;;
        m) source "$SCRIPT_DIR/manual_apps.sh" ;;
        t) source "$SCRIPT_DIR/macos_settings.sh" ;;
        h) usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Run all configurations if specified
if [ "$RUN_ALL" = true ]; then
    echo "Running all configurations..."
    source "$SCRIPT_DIR/omz.sh"
    source "$SCRIPT_DIR/nvm.sh"
    source "$SCRIPT_DIR/homebrew.sh"
    source "$SCRIPT_DIR/apps.sh"
    source "$SCRIPT_DIR/fzf.sh"
    source "$SCRIPT_DIR/kubectl.sh"
    source "$SCRIPT_DIR/starship.sh"
    source "$SCRIPT_DIR/codex.sh"
    source "$SCRIPT_DIR/projects.sh"
    source "$SCRIPT_DIR/pyenv.sh"
    source "$SCRIPT_DIR/manual_apps.sh"
    source "$SCRIPT_DIR/macos_settings.sh"
    echo "All applications installed or opened for manual installation."
fi 
