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

# arch.install.sh lays down a bare base system with no sound server. Without
# pipewire-pulse, apps that talk PulseAudio (Spotify, Zoom, most Flatpaks)
# have no audio. wireplumber is named explicitly so --noconfirm doesn't have
# to pick a pipewire-session-manager provider on its own.
yay -S --noconfirm --needed pipewire pipewire-pulse wireplumber
