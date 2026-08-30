#!/usr/bin/env bash

echo -e "\033[34mStarting Tor browser install\033[0m"
if command -v dnf &>/dev/null; then
  sudo dnf install -y tor
  sleep 5
  flatpak install -y flathub org.torproject.torbrowser-launcher
fi
echo -e "\033[32mFinished Tor browser install\033[0m"
