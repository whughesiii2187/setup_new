#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm ghostty
fi

if command -v dnf &> /dev/null; then
  sudo dnf copr enable -y scottames/ghostty
  sudo dnf install -y ghostty
fi
