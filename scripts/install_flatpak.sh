#!/usr/bin/env bash

# Shared Flatpak bootstrap for both distros: install flatpak itself, point
# it at Flathub and install Gear Lever for AppImage handling. Runs once,
# early, before any run_step that calls flatpak_install (see install_all.sh).
# Folder access is granted per app in Flatseal, not globally.

### Flatpak ###
if command -v dnf &>/dev/null; then
  sudo dnf install -y flatpak
fi

if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed flatpak
fi

# Fedora (traditional dnf installs AND Atomic/ostree images alike) ships
# its own Flatpak remote by default — replace it with Flathub for better
# package management and app stability. `command -v dnf` is false on
# Atomic (no dnf on the host there), so check for ostree too.
if command -v dnf &>/dev/null || [ -f /run/ostree-booted ]; then
  sudo systemctl disable flatpak-add-fedora-repos.service 2>/dev/null || true
  sudo flatpak remote-delete --system fedora --force 2>/dev/null || true
fi

# --system: flatpak_install installs system-wide from this remote
sudo flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak repair
sudo flatpak update --system -y

### AppImage ###
if command -v dnf &>/dev/null; then
  sudo dnf install -y fuse-libs
fi
flatpak_install flathub it.mijorus.gearlever
flatpak_install flathub com.github.tchx84.Flatseal
