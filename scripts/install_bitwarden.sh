#!/usr/bin/env bash

# native fallback, disabled in favor of flatpak
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed bitwarden
# fi
#
# if command -v dnf &>/dev/null; then
#   sudo dnf install -y snap
#   sudo snap wait system seed.loaded
#   sudo snap install bitwarden
# fi

flatpak_install flathub com.bitwarden.desktop || exit 1

./setup_bitwarden_ssh.sh
