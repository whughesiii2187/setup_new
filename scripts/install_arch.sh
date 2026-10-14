#!/usr/bin/env bash
set -e

# base-devel and git are needed to build yay; every other Arch step in this
# project installs through yay.
sudo pacman -Syu --noconfirm --needed base-devel git

if ! command -v yay &>/dev/null; then
  build_dir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
  (cd "$build_dir/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$build_dir"
fi

yay -Syu --noconfirm
