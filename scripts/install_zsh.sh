#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed zsh which
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y zsh which
fi

OMZ_INSTALLER="$(mktemp)"
if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
  bash "$OMZ_INSTALLER" "" --unattended
else
  echo "!!  Failed to download oh-my-zsh installer" >&2
fi
rm -f "$OMZ_INSTALLER"

ZSH_PATH="$(command -v zsh)"
if [ -n "$ZSH_PATH" ]; then
  sudo chsh -s "$ZSH_PATH" "$USER"
else
  echo "!!  zsh not found on PATH, skipping shell change" >&2
fi
