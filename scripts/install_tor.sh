#!/usr/bin/env bash

echo -e "\033[34mStarting Tor browser install\033[0m"
# tor itself is a system daemon with no Flathub package, so it stays native.
if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed tor
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y tor
fi

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed torbrowser-launcher
# fi

sleep 5
flatpak_install flathub org.torproject.torbrowser-launcher
echo -e "\033[32mFinished Tor browser install\033[0m"
