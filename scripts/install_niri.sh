#!/usr/bin/env bash

if command -v yay &>/dev/null; then
  # niri uses the GNOME portal for screencasting and screen sharing; on Arch
  # it's only an optional dependency, so it isn't pulled in automatically.
  yay -S --noconfirm --needed niri xdg-desktop-portal-gnome
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y niri
fi
