#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  sudo dnf group install -y cosmic-desktop cosmic-desktop-apps
fi

if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed cosmic cosmic-greeter
  sudo systemctl enable cosmic-greeter
fi
