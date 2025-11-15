#!/bin/bash


install_or_update_plugin() {
    local repo_url="$1"
    local dest="$2"

    if [ -d "$dest/.git" ]; then
        echo "Updating existing plugin in $dest..."
        git -C "$dest" pull --ff-only
    elif [ -d "$dest" ]; then
        echo "Directory $dest exists but is not a git repo. Skipping clone to avoid overwriting."
    else
        git clone "$repo_url" "$dest"
    fi
}

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

    mkdir -p "$custom_dir/plugins"
    
    install_or_update_plugin "https://github.com/zsh-users/zsh-autosuggestions" "$custom_dir/plugins/zsh-autosuggestions"
    install_or_update_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$custom_dir/plugins/zsh-syntax-highlighting"

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
