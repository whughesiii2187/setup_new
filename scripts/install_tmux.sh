#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed tmux
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y tmux
fi

if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
