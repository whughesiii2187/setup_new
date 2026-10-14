#!/usr/bin/env bash

# Everyday desktop apps from Flathub, shared by install_all.sh and
# install_atomic_fedora.sh. ProtonVPN is handled per path (install_vpn.sh
# on traditional installs, the Flatpak on Atomic).

APPS=(
  us.zoom.Zoom
  org.localsend.localsend_app
  me.proton.Pass
  org.chromium.Chromium
  com.github.PintaProject.Pinta
  org.gnome.seahorse.Application # manage gnome-keyring passwords and keys
)

failed=0
for app in "${APPS[@]}"; do
  if flatpak info "$app" &>/dev/null; then
    echo "$app already installed, skipping"
  else
    flatpak_install flathub "$app" || failed=1
  fi
done
exit "$failed"
