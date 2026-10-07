#!/usr/bin/env bash
set -euo pipefail

source_path=$(chezmoi source-path)

for command_name in brew chezmoi nvim node npm; do
  command -v "$command_name" >/dev/null 2>&1 || {
    printf 'Missing command: %s\n' "$command_name" >&2
    exit 1
  }
done

chezmoi verify ~/.zshrc ~/.config/nvim
brew bundle check --no-upgrade --file="$source_path/docs/migration/Brewfile"
brew bundle check --no-upgrade --file="$source_path/docs/migration/npm-global.Brewfile"
nvim --headless '+qa'

printf 'Chezmoi, Homebrew manifests, Node/npm, and Neovim checks passed.\n'
