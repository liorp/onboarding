#!/bin/bash

ensure_macos_developer_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        echo "macOS developer tools already installed."
        return 0
    fi

    echo "macOS developer tools not found. Launching installer..."
    /usr/bin/xcode-select --install >/dev/null 2>&1 || true
    echo "Complete the on-screen prompt, then re-run." >&2
    exit 1
}

# Homebrew refuses to build formulae from third-party taps with outdated
# Command Line Tools, so update them before `brew bundle` runs.
update_outdated_developer_tools() {
    local label

    echo "Checking for Command Line Tools updates..."
    label="$(softwareupdate --list 2>/dev/null \
        | sed -nE 's/^[[:space:]]*\* Label: (Command Line Tools.*)$/\1/p' \
        | tail -n 1)"

    if [ -z "$label" ]; then
        echo "Command Line Tools are up to date."
        return 0
    fi

    if [ -t 0 ]; then
        echo "Installing update: $label (requires your password)..."
        if sudo softwareupdate --install "$label"; then
            return 0
        fi
    fi

    echo "WARNING: Command Line Tools are outdated; some Homebrew installs will fail." >&2
    echo "Update them with:" >&2
    echo "  sudo softwareupdate --install \"$label\"" >&2
}

ensure_macos_developer_tools
update_outdated_developer_tools
