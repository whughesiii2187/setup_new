#!/usr/bin/env bash

if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed neovim
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y neovim
fi
