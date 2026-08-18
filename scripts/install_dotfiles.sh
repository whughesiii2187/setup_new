#!/bin/sh

git clone --filter=blob:none --sparse https://github.com/whughesiii2187/dotfiles ~/dotfiles
cd ~/dotfiles/
git sparse-checkout set ghostty tmux zshrc omarchy nvim aerospace sketchybar zshrc-mac

stow -t ~ ghostty
stow -t ~ nvim
stow -t ~ tmux

if [ -f "$HOME/.zshrc" ]; then
  rm $HOME/.zshrc
  stow -t ~ zshrc
fi
stow -t ~ omarchy
# rm -rf ~/.config/tmux

# OS Specific
if [ "$(uname)" = "Darwin" ]; then
  stow -t ~ aerospace
  stow -t ~ sketchybar
  stow -t ~ zshrc-mac
fi
