#!/usr/bin/env bash

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed vlc
# fi
#
# if command -v dnf &>/dev/null; then
#   sudo dnf install -y vlc
# fi

flatpak_install flathub org.videolan.VLC
