# Repository Guidelines

## Project Structure & Module Organization
All automation lives in `src/`. `init.sh` is the entry point: it marks scripts executable, ensures Xcode CLT is present, and sources task-specific modules such as `homebrew.sh`, `apps.sh`, `kubectl.sh`, and `macos_settings.sh`. Supporting installers (for Oh My Zsh, nvm, pyenv, etc.) sit alongside the orchestrator, and `starship.toml` contains the prompt configuration that the `starship.sh` script deploys. Keep new modules self-contained under `src/` and expose them through `init.sh` so they can be run either individually or via the `--all` flag.

## First-Time Setup

Run `make` from the repo root. Every target is idempotent — safe to re-run. If Xcode CLI tools are missing, the `xcode` target triggers the macOS installer GUI and exits; re-run `make` after the prompt completes. Targets that open URLs (`manual-apps`) or restart system processes (`macos-settings`) may need user interaction.

## Build, Test, and Development Commands
- `make` or `make all` — execute the full onboarding flow.
- `make <target>` — run any individual step (e.g., `make brew`, `make nvm`). Run `make help` for the full list.
- `make clean` — remove sentinel files to force re-run.
- `shellcheck src/*.sh` — lint all shell scripts locally; treat warnings as failing tests.

## Coding Style & Naming Conventions
Shell scripts must target Bash (`#!/bin/bash`) and use four-space indentation for blocks, as seen throughout `init.sh`. Name functions with lowercase snake_case (`install_homebrew`) and keep option flags aligned with their long-form counterparts. Quote variable expansions (`"$SCRIPT_DIR"`) and guard external commands with `command -v` checks to keep reruns idempotent. When adding files, default to `.sh`, mark them executable, and source them from `init.sh` using `source "$SCRIPT_DIR/<name>.sh"`.

## Testing Guidelines
Before committing, run `bash -n src/<script>.sh` for syntax validation, lint with `shellcheck`, and dry-run the relevant `init.sh` flag on a disposable macOS user profile. Prefer verifying installers are no-ops when rerun, and document any manual follow-up required (e.g., GUI prompts) inside the script output.

## Commit & Pull Request Guidelines
This repo follows Conventional Commits (`feat:`, `fix:`, etc.) as seen in `git log`. Keep subject lines under ~50 characters, include scope when useful (`feat: add kubectl addon`), and describe motivation plus validation steps in the body. Pull requests should summarize the change, list the exact commands executed for verification, note any manual steps left for the reviewer, and attach screenshots for UI-facing tweaks (such as `starship.toml` prompt changes).
