#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew update

brew install neovim fzf lazygit zsh tmux claude-code font-0xproto-nerd-font gcc clipboard ripgrep tree-sitter-cli stow devcontainer
