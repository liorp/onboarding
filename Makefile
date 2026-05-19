#!/usr/bin/make -f
# MacBook Onboarding — Makefile
#
# Thin wrapper around the scripts in src/. Each target is `bash src/<name>.sh`
# plus a sentinel file in $(DONE) so re-running `make` skips completed steps.
# All install logic lives in src/*.sh — see those scripts for what each step does.
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
SRC         := src

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
	@echo "  codex           Install Codex + deploy config.toml"
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

# ─── Steps (each delegates to src/<name>.sh) ─────────────────────────
xcode: | $(DONE)
	@bash $(SRC)/xcode.sh
	@touch $(DONE)/$@

brew: xcode | $(DONE)
	@bash $(SRC)/homebrew.sh
	@touch $(DONE)/$@

apps: brew | $(DONE)
	@bash $(SRC)/apps.sh
	@touch $(DONE)/$@

omz: brew apps | $(DONE)
	@bash $(SRC)/omz.sh
	@touch $(DONE)/$@

nvm: | $(DONE)
	@bash $(SRC)/nvm.sh
	@touch $(DONE)/$@

bun: brew | $(DONE)
	@bash $(SRC)/bun.sh
	@touch $(DONE)/$@

uv: brew | $(DONE)
	@bash $(SRC)/uv.sh
	@touch $(DONE)/$@

pyenv: | $(DONE)
	@bash $(SRC)/pyenv.sh
	@touch $(DONE)/$@

fzf: brew apps | $(DONE)
	@bash $(SRC)/fzf.sh
	@touch $(DONE)/$@

kubectl: brew apps | $(DONE)
	@bash $(SRC)/kubectl.sh
	@touch $(DONE)/$@

starship: | $(DONE)
	@bash $(SRC)/starship.sh
	@touch $(DONE)/$@

codex: | $(DONE)
	@bash $(SRC)/codex.sh
	@touch $(DONE)/$@

projects: | $(DONE)
	@bash $(SRC)/projects.sh
	@touch $(DONE)/$@

vscode: | $(DONE)
	@bash $(SRC)/vscode.sh
	@touch $(DONE)/$@

manual-apps: | $(DONE)
	@bash $(SRC)/manual_apps.sh
	@touch $(DONE)/$@

macos-settings: | $(DONE)
	@bash $(SRC)/macos_settings.sh
	@touch $(DONE)/$@
