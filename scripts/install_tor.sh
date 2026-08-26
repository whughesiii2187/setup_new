#!/usr/bin/env bash

echo -e "\033[34mStarting Tor browser install\033[0m"
if command -v dnf &>/dev/null; then
  sudo dnf install -y tor >/dev/null 2>&1
  sleep 5 >/dev/null 2>&1
  flatpak install -y flathub org.torproject.torbrowser-launcher >/dev/null 2>&1
fi
echo -e "\033[32mFinished Tor browser install\033[0m"
