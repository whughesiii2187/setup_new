#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm proton-vpn-gtk-app
elif command -v dnf &> /dev/null; then
  REPO_DIR_URL="https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/"
  RELEASE_RPM="$(curl -fsSL "$REPO_DIR_URL" | grep -oE 'protonvpn-stable-release-[0-9.]+-[0-9]+\.noarch\.rpm' | sort -V | tail -n1)"
  if [ -n "$RELEASE_RPM" ]; then
    sudo dnf install -y "${REPO_DIR_URL}${RELEASE_RPM}"
    sudo dnf install -y --refresh proton-vpn-gnome-desktop
  else
    echo "!!  Could not find ProtonVPN release rpm at $REPO_DIR_URL; skipping ProtonVPN install" >&2
  fi
else
  echo "!!  Neither yay nor dnf found; skipping ProtonVPN install" >&2
fi
