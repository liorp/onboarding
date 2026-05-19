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

ensure_macos_developer_tools
