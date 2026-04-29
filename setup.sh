#!/bin/sh

if [ -f "/workspace" ]; then
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
  stow -t ~ nvim
  stow -t ~ tmux
  stow -t ~ zshrc
  if [ -d ~/.local/share/omarchy ]; then
    stow -t ~ omarchy
  fi
  if [ "$(uname)" = "Darwin" ]; then
    stow -t ~ aerospace
    stow -t ~ sketchybar
    stow -t ~ macoszshrc
  fi
fi

