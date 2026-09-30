#!/usr/bin/env bash

if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed niri
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y niri
fi
