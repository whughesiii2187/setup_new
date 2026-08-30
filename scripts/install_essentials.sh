#!/usr/bin/env bash

echo -e "\033[33mInstalling essential applications...\033[0m"
if command -v dnf &>/dev/null; then
  dnf install -y btop inxi unzip unrar git wget curl
fi
echo -e "\033[32mEssential applications installed successfully.\033[0m"
