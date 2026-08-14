#!/bin/sh

if [[ -d "/workspace" || -d ".devcontainer" ]]; then
  git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
  cd ~/dotfiles/
  git sparse-checkout set devc
  cd devc
  ./setup.sh
else
  git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
  cd ~/dotfiles/
  git sparse-checkout set default
  cd default
  stow -t ~ ghostty
  # stow -t ~ nvim
  stow -t ~ tmux

  if [ -f "$HOME/.zshrc" ]; then
    rm $HOME/.zshrc
    stow -t ~ zshrc
  fi
  if [ -d ~/.local/share/omarchy ]; then
    stow -t ~ omarchy
    rm -rf ~/.config/tmux
  fi
 
  # OS Specific
  if [ "$(uname)" = "Darwin" ]; then
    stow -t ~ aerospace
    stow -t ~ sketchybar
    stow -t ~ macoszshrc
  fi
fi

