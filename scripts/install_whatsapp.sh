#!/usr/bin/env bash

echo -e "\033[33mInstalling Whatsie...\033[0m"
flatpak install -y flathub com.ktechpit.whatsie >/dev/null 2>&1
echo -e "\033[32mWhatsie installed successfully.\033[0m"
