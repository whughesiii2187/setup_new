#!/usr/bin/env bash

echo -e "\033[34mStarting Tor browser install\033[0m"
# tor itself is a system daemon with no Flathub package, so it stays native.
if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed tor
fi

# dnf can't install onto an ostree/bootc system's read-only /usr; there,
# tor has to come from the image instead.
if command -v dnf &>/dev/null && [ ! -f /run/ostree-booted ]; then
  sudo dnf install -y tor
fi

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed torbrowser-launcher
# fi

sleep 5
flatpak_install flathub org.torproject.torbrowser-launcher || exit 1
echo -e "\033[32mFinished Tor browser install\033[0m"
