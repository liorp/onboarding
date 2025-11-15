#!/bin/bash

install_omz_and_plugins() {
    local omz_dir="$HOME/.oh-my-zsh"
    local zshrc="$HOME/.zshrc"
    local custom_dir="${ZSH_CUSTOM:-$omz_dir/custom}"
    local plugin_line="plugins=(kubectl zsh-autosuggestions zsh-syntax-highlighting)"

    echo "Installing Oh My Zsh..."
    if [ -d "$omz_dir" ]; then
        echo "Oh My Zsh already exists at $omz_dir. Skipping installation."
    else
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

    if [ -f "$zshrc" ]; then
        if grep -q '^plugins=(' "$zshrc"; then
            sed -i '' "s/^plugins=(.*)$/$plugin_line/" "$zshrc"
        else
            printf "\n%s\n" "$plugin_line" >> "$zshrc"
        fi
    else
        printf "%s\n" "$plugin_line" > "$zshrc"
    fi
}

install_omz_and_plugins
