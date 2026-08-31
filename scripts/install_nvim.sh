#!/usr/bin/env bash

if command -v yay &>/dev/null; then
  sudo yay -S --no-confirm --needed neovim
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y neovim
fi
