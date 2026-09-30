#!/usr/bin/env bash
set -e
if !command -v yay; then
  git clone https://aur.archlinux.org/yay-bin.git /tmp/git
  ./tmp/git/makepkg -si
fi

sudo pacman -Syu
yay -Syu
