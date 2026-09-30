#!/usr/bin/env bash

MODE="$1"
SHELL_ARG="$2"

git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
cd ~/dotfiles/
git sparse-checkout set dank ghostty tmux zshrc nvim aerospace sketchybar zshrc-mac scripts wireplumber hypr niri

stow -t ~ ghostty
stow -t ~ nvim
stow -t ~ tmux
stow -t ~ wireplumber
stow -t ~ scripts

if [ "$SHELL_ARG" = "dms" ]; then
  stow -t ~ dank
fi

if [ "$MODE" = "niri" ]; then
  stow -t ~ niri
elif [ "$MODE" = "hypr" ]; then
  stow -t ~ hypr
fi

if [ -f "$HOME/.zshrc" ]; then
  rm $HOME/.zshrc
  stow -t ~ zshrc
else
  stow -t ~ zshrc
fi

# OS Specific
if [ "$(uname)" = "Darwin" ]; then
  stow -t ~ aerospace
  stow -t ~ sketchybar
  stow -t ~ zshrc-mac
fi
