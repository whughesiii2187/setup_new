#!/usr/bin/env bash

# https://docs.noctalia.dev/noctalia/getting-started/installation/
if command -v pacman &>/dev/null; then
  sudo pacman -S --noconfirm --needed noctalia
elif command -v dnf &>/dev/null; then
  . /etc/os-release
  if [ "${VERSION_ID%%.*}" -ge 44 ] 2>/dev/null; then
    sudo dnf install -y noctalia
  else
    sudo dnf copr enable -y lionheartp/hyprland
    sudo dnf install -y noctalia-git
  fi
fi
