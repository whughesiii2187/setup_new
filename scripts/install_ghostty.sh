#!/bin/sh

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm ghostty
fi

if command -v dnf &> /dev/null; then
  sudo dnf copr enable scottames/ghostty
  sudo dnf install ghostty
fi
