#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed stow
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y stow
fi
