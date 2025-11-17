#!/bin/bash

if ! declare -F append_zshrc_line >/dev/null 2>&1; then
    append_zshrc_line() {
        local line="$1"
        local leading_blank="${2:-false}"
        local zshrc="${ZDOTDIR:-$HOME}/.zshrc"

        touch "$zshrc"

        if ! grep -Fxq "$line" "$zshrc"; then
            if [ "$leading_blank" = "true" ] && [ -s "$zshrc" ]; then
                printf "\n%s\n" "$line" >> "$zshrc"
            else
                printf "%s\n" "$line" >> "$zshrc"
            fi
        fi
    }
fi
