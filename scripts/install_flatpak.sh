#!/usr/bin/env bash

# Shared Flatpak bootstrap for both distros: install flatpak itself, point
# it at Flathub, install Gear Lever for AppImage handling, and grant every
# Flatpak app access to the common user folders. Runs once, early, before
# any run_step that calls flatpak_install (see install_all.sh).

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
  flatpak remote-delete fedora --force || true
fi

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak repair
flatpak update

### AppImage ###
if command -v dnf &>/dev/null; then
  sudo dnf install -y fuse-libs
fi
flatpak_install it.mijorus.gearlever

### User folder access ###
# Global grant, not a per-app allowlist: every Flatpak app gets read-write
# access to the folders files actually live in, matching how they behave
# outside the sandbox. Bitwarden's SSH agent needs its own extra handling
# on top of this — see install_bitwarden.sh.
flatpak override --user \
  --filesystem=xdg-documents \
  --filesystem=xdg-download \
  --filesystem=xdg-pictures \
  --filesystem=xdg-music \
  --filesystem=xdg-videos
