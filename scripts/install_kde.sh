#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  sudo dnf group install -y "KDE Plasma Workspaces"
fi

if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed plasma-meta kde-applications-meta sddm
  sudo systemctl enable sddm
fi
