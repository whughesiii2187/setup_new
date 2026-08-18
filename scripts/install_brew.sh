#!/bin/bash
set -e

if [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  # Fetch to a file and check curl's own exit status first: piping a failed
  # curl straight into `bash -c "$(...)"` silently becomes `bash -c ""`,
  # which "succeeds" while doing nothing, masking the real failure.
  BREW_INSTALLER="$(mktemp)"
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$BREW_INSTALLER"
  /bin/bash "$BREW_INSTALLER"
  rm -f "$BREW_INSTALLER"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew update

brew install neovim fzf lazygit zsh tmux claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli stow devcontainer
