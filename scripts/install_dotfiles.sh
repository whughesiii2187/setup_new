#!/usr/bin/env bash

git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
cd ~/dotfiles/
git sparse-checkout set dank ghostty tmux zshrc omarchy nvim aerospace sketchybar zshrc-mac scripts wireplumber

stow -t ~ ghostty
stow -t ~ nvim
stow -t ~ tmux
stow -t ~ wireplumber
stow -t ~ scripts
stow -t ~ dank

if [ -f "$HOME/.zshrc" ]; then
  rm $HOME/.zshrc
  stow -t ~ zshrc
else
  stow -t ~ zshrc
fi

stow -t ~ omarchy

# OS Specific
if [ "$(uname)" = "Darwin" ]; then
  stow -t ~ aerospace
  stow -t ~ sketchybar
  stow -t ~ zshrc-mac
fi
