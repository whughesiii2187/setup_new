#!/usr/bin/env bash

echo -e "\033[33mInstalling Firefox...\033[0m"
if command -v dnf &>/dev/null; then
  dnf install -y firefox
fi
echo -e "\033[32mFirefox installed successfully.\033[0m"
