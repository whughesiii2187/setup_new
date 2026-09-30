#!/usr/bin/env bash

echo -e "\033[33mInstalling Zen Browser...\033[0m"
# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed zen-browser-bin
# fi

flatpak_install flathub app.zen_browser.zen
echo -e "\033[32mZen Browser installed successfully.\033[0m"
