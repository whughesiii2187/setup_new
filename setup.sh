#!/bin/sh

if [ "$(uname)" = "Darwin" ]; then
  git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
  cd ~/dotfiles/
  git sparse-checkout set macos
  cd macos
  stow -t ~ aerospace
  stow -t ~ ghostty
  stow -t ~ nvim
  stow -t ~ tmux
  stow -t ~ zshrc
elif [ -f "/.dockerenv" ]; then
  git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
  cd ~/dotfiles/
  git sparse-checkout set devc
  cd devc
  ./setup.sh
elif [ $(uname) = "Linux" ]; then
  git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
  cd ~/dotfiles/
  git sparse-checkout set linux
  cd linux
  stow -t ~ ghostty 
  stow -t ~ nvim
  stow -t ~ tmux
  stow -t ~ zshrc
  if [ -d ~/.local/share/omarchy ]; then
    stow -t ~ omarchy
  fi
fi

