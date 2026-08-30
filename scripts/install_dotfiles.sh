#!/usr/bin/env bash

MODE="$1"

git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
cd ~/dotfiles/
git sparse-checkout set dank ghostty tmux zshrc omarchy nvim aerospace sketchybar zshrc-mac scripts wireplumber

stow -t ~ ghostty
stow -t ~ nvim
stow -t ~ tmux
stow -t ~ wireplumber
stow -t ~ scripts

# dank and omarchy both ship .config/hypr/scripts/laptop-display.sh, so only
# stow whichever one this run actually installed.
if [ "$MODE" = "dms" ]; then
  stow -t ~ dank
fi

if [ -f "$HOME/.zshrc" ]; then
  rm $HOME/.zshrc
  stow -t ~ zshrc
else
  stow -t ~ zshrc
fi

if [ "$MODE" = "omarchy" ]; then
  stow -t ~ omarchy
fi

# OS Specific
if [ "$(uname)" = "Darwin" ]; then
  stow -t ~ aerospace
  stow -t ~ sketchybar
  stow -t ~ zshrc-mac
fi
