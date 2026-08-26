#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  echo -e "\033[33mInstalling essential applications...\033[0m"
  dnf install -y btop inxi unzip unrar git wget curl >/dev/null 2>&1
  echo -e "\033[32mEssential applications installed successfully.\033[0m"
fi
