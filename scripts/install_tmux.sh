#!/bin/sh

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed tmux
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y tmux
fi

git clone https://github.com/tmux-plugins/tpm ~/dotfiles/default/tmux/.tmux/plugins/tpm
