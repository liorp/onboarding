#!/usr/bin/make -f
# MacBook Onboarding — Makefile
#
# Usage:
#   make              # Run full setup (same as 'make all')
#   make brew         # Install Homebrew only
#   make apps         # Install all brew casks & formulas
#   make <target>     # Run any individual target below
#   make clean        # Remove sentinel files to force re-run

SHELL       := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
DONE        := .done
ZSHRC       := $(or $(ZDOTDIR),$(HOME))/.zshrc
BREW_PREFIX := $(shell [ -d /opt/homebrew ] && echo /opt/homebrew || echo /usr/local)

# Shell helper — sourced at the top of recipes that modify .zshrc.
# Usage inside a recipe:  $(APPEND_ZSHRC_FN) append_zshrc 'some line' [true]
define APPEND_ZSHRC_FN
append_zshrc() { \
	local line="$$1"; \
	local leading="$${2:-false}"; \
	touch "$(ZSHRC)"; \
	grep -Fxq "$$line" "$(ZSHRC)" 2>/dev/null && return 0; \
	if [ "$$leading" = "true" ] && [ -s "$(ZSHRC)" ]; then printf '\n' >> "$(ZSHRC)"; fi; \
	printf '%s\n' "$$line" >> "$(ZSHRC)"; \
};
endef

# PlistBuddy helper — creates a symbolic hotkey entry.
# Usage: $(SET_HOTKEY_FN) set_hotkey <id> <key_code> <modifier_flags> <char_code>
PLIST_FILE := $(HOME)/Library/Preferences/com.apple.symbolichotkeys.plist
PB         := /usr/libexec/PlistBuddy
define SET_HOTKEY_FN
set_hotkey() { \
	local id="$$1" kc="$$2" mf="$$3" cc="$$4"; \
	$(PB) -c "Delete :AppleSymbolicHotKeys:$$id" "$(PLIST_FILE)" 2>/dev/null || true; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id dict"                           "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:enabled bool true"              "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:value dict"                     "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:value:type string standard"     "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:value:parameters array"         "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:value:parameters:0 integer $$cc" "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:value:parameters:1 integer $$kc" "$(PLIST_FILE)"; \
	$(PB) -c "Add :AppleSymbolicHotKeys:$$id:value:parameters:2 integer $$mf" "$(PLIST_FILE)"; \
};
endef

# ─── Phony targets ───────────────────────────────────────────────────
.PHONY: all clean help xcode brew apps omz nvm bun uv pyenv fzf \
        kubectl starship codex projects vscode manual-apps macos-settings

all: xcode brew apps omz nvm bun uv pyenv fzf kubectl starship codex \
     projects vscode manual-apps macos-settings
	@echo ""
	@echo "All onboarding steps complete."
	@echo "Restart your terminal (or run 'exec zsh') to pick up all changes."

help:
	@echo "Targets:"
	@echo "  all             Full setup (default)"
	@echo "  xcode           Ensure Xcode CLI tools are present"
	@echo "  brew            Install / update Homebrew"
	@echo "  apps            Install cask & formula apps via Homebrew"
	@echo "  omz             Install Oh My Zsh + plugins"
	@echo "  nvm             Install nvm + Node LTS"
	@echo "  bun             Install Bun runtime"
	@echo "  uv              Install uv (Python package manager)"
	@echo "  pyenv           Install pyenv"
	@echo "  fzf             Configure fzf + starship shell init"
	@echo "  kubectl         Install krew plugins + aliases"
	@echo "  starship        Deploy starship.toml config"
	@echo "  codex           Deploy Codex config.toml"
	@echo "  projects        Create ~/projects directory"
	@echo "  vscode          Configure VS Code autosave"
	@echo "  manual-apps     Open URLs for manual-install apps"
	@echo "  macos-settings  Apply macOS system preferences"
	@echo "  clean           Remove sentinel files to force re-run"

clean:
	rm -rf $(DONE)

# ─── Sentinel directory ──────────────────────────────────────────────
$(DONE):
	@mkdir -p $(DONE)

# ─── Xcode CLI Tools ─────────────────────────────────────────────────
xcode: | $(DONE)
	@if xcode-select -p >/dev/null 2>&1; then \
		echo "Xcode CLI tools already installed."; \
	else \
		echo "Xcode CLI tools not found — launching installer..."; \
		/usr/bin/xcode-select --install || true; \
		echo "Complete the on-screen prompt, then re-run make."; \
		exit 1; \
	fi
	@touch $(DONE)/$@

# ─── Homebrew ─────────────────────────────────────────────────────────
brew: xcode | $(DONE)
	@$(APPEND_ZSHRC_FN) \
	if command -v brew >/dev/null 2>&1; then \
		echo "Homebrew already installed at $$(command -v brew). Skipping."; \
	else \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		append_zshrc '# Add Homebrew to PATH' true; \
		append_zshrc 'eval "$$($(BREW_PREFIX)/bin/brew shellenv)"'; \
		eval "$$($(BREW_PREFIX)/bin/brew shellenv)"; \
		brew update; \
	fi
	@touch $(DONE)/$@

# ─── Cask & Formula apps ─────────────────────────────────────────────
CASK_APPS := brave-browser cursor codex figma slack postman \
             jetbrains-toolbox sublime-text mongodb-compass firefox \
             obsidian chatgpt rectangle-pro iterm2 maccy google-chrome \
             heynote fork linear-linear chatgpt-atlas vlc zoom \
             karabiner-elements notion

BREW_FORMULAS := vim tmux node jq awscli kubectl krew sops fzf \
                 starship helm gh glab ollama shellcheck \
                 zsh-autosuggestions zsh-syntax-highlighting uv pnpm \
                 pulumi/tap/pulumi

apps: brew | $(DONE)
	@echo "Installing cask apps..."
	@for app in $(CASK_APPS); do \
		if brew list --cask "$${app##*/}" >/dev/null 2>&1; then \
			echo "  -> $$app already installed, skipping."; \
		else \
			echo "  -> $$app"; \
			brew install --cask "$$app" 2>/dev/null || true; \
		fi; \
	done
	@echo "Installing brew formulas..."
	@for formula in $(BREW_FORMULAS); do \
		if brew list --formula "$${formula##*/}" >/dev/null 2>&1; then \
			echo "  -> $$formula already installed, skipping."; \
		else \
			echo "  -> $$formula"; \
			brew install "$$formula" 2>/dev/null || true; \
		fi; \
	done
	@touch $(DONE)/$@

# ─── Oh My Zsh ───────────────────────────────────────────────────────
omz: brew apps | $(DONE)
	@$(APPEND_ZSHRC_FN) \
	if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo "Installing Oh My Zsh..."; \
		RUNZSH=no KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	else \
		echo "Oh My Zsh already installed."; \
	fi; \
	append_zshrc 'source $(BREW_PREFIX)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'; \
	append_zshrc 'source $(BREW_PREFIX)/share/zsh-autosuggestions/zsh-autosuggestions.zsh'; \
	if grep -q '^plugins=(' "$(ZSHRC)" 2>/dev/null; then \
		sed -i '' 's/^plugins=(.*)$$/plugins=(kubectl zsh-autosuggestions zsh-syntax-highlighting)/' "$(ZSHRC)"; \
	else \
		printf '\nplugins=(kubectl zsh-autosuggestions zsh-syntax-highlighting)\n' >> "$(ZSHRC)"; \
	fi
	@touch $(DONE)/$@

# ─── nvm + Node LTS ──────────────────────────────────────────────────
nvm: | $(DONE)
	@if [ ! -d "$$HOME/.nvm" ]; then \
		echo "Installing nvm..."; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash; \
	else \
		echo "nvm already installed."; \
	fi
	@export NVM_DIR="$$HOME/.nvm"; \
	if [ -s "$$NVM_DIR/nvm.sh" ]; then \
		. "$$NVM_DIR/nvm.sh"; \
		echo "Installing Node LTS..."; \
		nvm install --lts; \
		nvm alias default 'lts/*'; \
		nvm use --lts; \
	else \
		echo "nvm installed but nvm.sh not found — restart shell and re-run."; \
	fi
	@touch $(DONE)/$@

# ─── Bun ──────────────────────────────────────────────────────────────
bun: brew | $(DONE)
	@$(APPEND_ZSHRC_FN) \
	if command -v bun >/dev/null 2>&1; then \
		echo "Bun already installed."; \
	else \
		echo "Installing Bun via Homebrew (oven-sh/bun)..."; \
		brew tap oven-sh/bun; \
		brew install bun; \
	fi; \
	append_zshrc '# Bun configuration' true; \
	append_zshrc 'export BUN_INSTALL="$$HOME/.bun"'; \
	append_zshrc 'export PATH="$$BUN_INSTALL/bin:$$PATH"'
	@touch $(DONE)/$@

# ─── uv (Python) ─────────────────────────────────────────────────────
uv: brew | $(DONE)
	@if ! command -v uv >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			echo "Installing uv via Homebrew..."; \
			brew install uv; \
		else \
			echo "Installing uv via official script..."; \
			curl -LsSf https://astral.sh/uv/install.sh | sh; \
		fi; \
	else \
		echo "uv already installed."; \
	fi
	@command -v uv >/dev/null 2>&1 && uv tool update-shell || true
	@touch $(DONE)/$@

# ─── pyenv ────────────────────────────────────────────────────────────
pyenv: | $(DONE)
	@$(APPEND_ZSHRC_FN) \
	if [ ! -d "$$HOME/.pyenv" ]; then \
		echo "Installing pyenv..."; \
		curl -fsSL https://pyenv.run | bash; \
	else \
		echo "pyenv already installed."; \
	fi; \
	append_zshrc '# Pyenv configuration' true; \
	append_zshrc 'export PYENV_ROOT="$$HOME/.pyenv"'; \
	append_zshrc '[[ -d $$PYENV_ROOT/bin ]] && export PATH="$$PYENV_ROOT/bin:$$PATH"'; \
	append_zshrc 'eval "$$(pyenv init - zsh)"'
	@touch $(DONE)/$@

# ─── fzf + shell init ────────────────────────────────────────────────
fzf: brew apps | $(DONE)
	@$(APPEND_ZSHRC_FN) \
	append_zshrc '# Initialize Starship prompt' true; \
	append_zshrc 'eval "$$(starship init zsh)"'; \
	append_zshrc 'source <(fzf --zsh)'
	@touch $(DONE)/$@

# ─── kubectl krew plugins ────────────────────────────────────────────
kubectl: brew apps | $(DONE)
	@echo "Installing krew plugins..."
	@kubectl krew install ctx 2>/dev/null || true
	@kubectl krew install ns  2>/dev/null || true
	@$(APPEND_ZSHRC_FN) \
	append_zshrc '# Kubectl aliases and krew' true; \
	append_zshrc 'alias k="kubectl"'; \
	append_zshrc 'export PATH="$${KREW_ROOT:-$$HOME/.krew}/bin:$$PATH"'
	@touch $(DONE)/$@

# ─── Starship config ─────────────────────────────────────────────────
starship: | $(DONE)
	@mkdir -p "$$HOME/.config"
	@cp src/starship.toml "$$HOME/.config/starship.toml"
	@echo "Starship config deployed."
	@touch $(DONE)/$@

# ─── Codex config ────────────────────────────────────────────────────
codex: | $(DONE)
	@mkdir -p "$$HOME/.config/codex"
	@cp src/codex/config.toml "$$HOME/.config/codex/config.toml"
	@echo "Codex config deployed."
	@touch $(DONE)/$@

# ─── Projects directory ──────────────────────────────────────────────
projects: | $(DONE)
	@mkdir -p "$$HOME/projects"
	@echo "~/projects directory ready."
	@touch $(DONE)/$@

# ─── VS Code settings ────────────────────────────────────────────────
vscode: | $(DONE)
	@settings_dir="$$HOME/Library/Application Support/Code/User"; \
	settings_file="$$settings_dir/settings.json"; \
	mkdir -p "$$settings_dir"; \
	[ -f "$$settings_file" ] || echo '{}' > "$$settings_file"; \
	SETTINGS_FILE="$$settings_file" python3 -c ' \
import json, os; from pathlib import Path; \
p = Path(os.environ["SETTINGS_FILE"]); \
d = json.loads(p.read_text()) if p.stat().st_size else {}; \
changed = False; \
if d.get("files.autoSave") != "afterDelay": d["files.autoSave"] = "afterDelay"; changed = True; \
if d.get("files.autoSaveDelay") != 1000: d["files.autoSaveDelay"] = 1000; changed = True; \
if changed: p.write_text(json.dumps(d, indent=4)); print("Updated VS Code settings."); \
else: print("VS Code autosave already configured."); \
'
	@touch $(DONE)/$@

# ─── Manual apps (opens URLs) ────────────────────────────────────────
manual-apps: | $(DONE)
	@echo "Opening Elasticvue Chrome extension page..."
	@open -a "Google Chrome" "https://chrome.google.com/webstore/detail/elasticvue/hkedbapjpblbodpgbajblpnlpenaebaa" || true
	@echo "Opening Time Out download page..."
	@open "https://www.dejal.com/timeout/" || true
	@touch $(DONE)/$@

# ─── macOS system preferences ────────────────────────────────────────
macos-settings: | $(DONE)
	@echo "Applying macOS settings..."
	@# Tap to click
	@defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
	@defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	@defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	@defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	@# App Expose gesture
	@defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
	@defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
	@defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -int 2
	@# iCloud sync Desktop & Documents
	@defaults write com.apple.finder FXICloudDriveDesktop -bool true
	@defaults write com.apple.finder FXICloudDriveDocuments -bool true
	@# Show hidden files
	@defaults write com.apple.finder AppleShowAllFiles -bool true
	@killall Finder 2>/dev/null || true
	@# Dock auto-hide + disable space rearrange
	@defaults write com.apple.dock autohide -bool true
	@defaults write com.apple.dock mru-spaces -bool false
	@killall Dock 2>/dev/null || true
	@# Cursor size
	@defaults write NSGlobalDomain com.apple.cursor.size -float 1.5
	@# Night Shift sunset to sunrise
	@defaults -currentHost write com.apple.CoreBrightness CBBlueReductionStatus -dict \
		BlueReductionEnabled -bool true \
		BlueReductionMode -int 1 \
		BlueReductionSunScheduleAllowed -bool true \
		AutoBlueReductionEnabled -bool true
	@# Function keys require Fn
	@defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false
	@# Keyboard shortcuts
	@echo "Setting keyboard shortcuts..."
	@[ -f "$(PLIST_FILE)" ] || defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict
	@$(SET_HOTKEY_FN) \
	set_hotkey 60 49 1048576 32; \
	set_hotkey 64 49 524288 32; \
	set_hotkey 33 125 262144 65535
	@echo "macOS settings applied. Logout/login may be required for some changes."
	@touch $(DONE)/$@
