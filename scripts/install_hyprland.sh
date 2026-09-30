#!/usr/bin/env bash

if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed hyprland
fi

if command -v dnf &>/dev/null; then
  # Fedora's official repos lag upstream; lionheartp/hyprland tracks current releases.
  # https://discussion.fedoraproject.org/t/lionheartp-hyprland/172445 (Fedora 42+, x86_64 only)
  sudo dnf copr enable -y lionheartp/hyprland
  sudo dnf install -y hyprland
fi
