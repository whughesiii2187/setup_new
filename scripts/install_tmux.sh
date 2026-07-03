#!/bin/sh

yay -S --noconfirm --needed tmux 

if [ -d "$HOME/.config/omarchy" ]; then
  rm -rf ~/.config/tmux
fi 

git clone https://github.com/tmux-plugins/tpm ~/dotfiles/default/tmux/.tmux/plugins/tpm
