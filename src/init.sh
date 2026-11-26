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
# shellcheck source=src/vscode.sh
# shellcheck source=src/uv.sh
# shellcheck source=src/cf.sh
# shellcheck source=src/aliases.sh

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
    echo "  -v, --vscode        Configure VS Code settings"
    echo "  -U, --uv            Run uv setup"
    echo "  -C, --cf            Install Cloudflare CLI (cf)"
    echo "  -A, --aliases       Add AI CLI aliases (c, co, cu, g)"
    echo "  -t, --macos-settings Apply macOS system settings"
    echo "  -h, --help          Display this help message"
    exit 1
}

# Install dev tools before doing anything else
source "$SCRIPT_DIR/xcode.sh"

# Run one step, remembering it if it fails so the run can report it at the end
# instead of claiming success.
FAILED_STEPS=()
run_step() {
    # shellcheck disable=SC1090
    source "$SCRIPT_DIR/$1.sh" || FAILED_STEPS+=("$1")
}

# Default to running all if no arguments provided
if [ $# -eq 0 ]; then
    RUN_ALL=true
else
    RUN_ALL=false
fi

# Parse command line arguments
while getopts "aonbpfkscrvyUmthCA-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                all) RUN_ALL=true ;;
                omz) run_step omz ;;
                nvm) run_step nvm ;;
                brew) run_step homebrew ;;
                apps) run_step apps ;;
                fzf) run_step fzf ;;
                kubectl) run_step kubectl ;;
                starship) run_step starship ;;
                codex) run_step codex ;;
                projects) run_step projects ;;
                pyenv) run_step pyenv ;;
                manual) run_step manual_apps ;;
                vscode) run_step vscode ;;
                uv) run_step uv ;;
                cf) run_step cf ;;
                aliases) run_step aliases ;;
                macos-settings) run_step macos_settings ;;
                help) usage ;;
                *) echo "Invalid option: --${OPTARG}" >&2; usage ;;
            esac ;;
        a) RUN_ALL=true ;;
        o) run_step omz ;;
        n) run_step nvm ;;
        b) run_step homebrew ;;
        p) run_step apps ;;
        f) run_step fzf ;;
        k) run_step kubectl ;;
        s) run_step starship ;;
        c) run_step codex ;;
        r) run_step projects ;;
        y) run_step pyenv ;;
        m) run_step manual_apps ;;
        v) run_step vscode ;;
        U) run_step uv ;;
        C) run_step cf ;;
        A) run_step aliases ;;
        t) run_step macos_settings ;;
        h) usage ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    esac
done

# Run all configurations if specified
if [ "$RUN_ALL" = true ]; then
    echo "Running all configurations..."
    run_step homebrew
    run_step apps
    run_step omz
    run_step nvm
    run_step cf
    run_step uv
    run_step fzf
    run_step kubectl
    run_step aliases
    run_step starship
    run_step codex
    run_step projects
    run_step pyenv
    run_step manual_apps
    run_step vscode
    run_step macos_settings
fi

if [ "${#FAILED_STEPS[@]}" -gt 0 ]; then
    echo "" >&2
    echo "Onboarding finished with failures in these steps:" >&2
    printf '  - %s\n' "${FAILED_STEPS[@]}" >&2
    echo "Scroll up for details, fix them, then re-run just those steps." >&2
    exit 1
fi

if [ "$RUN_ALL" = true ]; then
    echo "All applications installed or opened for manual installation."
fi 
