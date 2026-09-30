#!/usr/bin/env bash

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed freetube-bin
# fi

flatpak_install flathub io.freetubeapp.FreeTube
