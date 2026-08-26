#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  echo -e "\033[33mInstalling Firefox...\033[0m"
  dnf install -y firefox >/dev/null 2>&1
  echo -e "\033[32mFirefox installed successfully.\033[0m"
fi
