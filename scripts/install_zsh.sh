#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed zsh which
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y zsh which
fi

# The oh-my-zsh installer exits non-zero if it's already installed
if [ -d ~/.oh-my-zsh ]; then
  echo "oh-my-zsh already installed, skipping"
else
  OMZ_INSTALLER="$(mktemp)"
  if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$OMZ_INSTALLER"; then
    bash "$OMZ_INSTALLER" "" --unattended
  else
    echo "!!  Failed to download oh-my-zsh installer" >&2
  fi
  rm -f "$OMZ_INSTALLER"
fi

ZSH_PATH="$(command -v zsh)"
if [ -z "$ZSH_PATH" ]; then
  echo "!!  zsh not found on PATH, skipping shell change" >&2
elif [ "$(getent passwd "$USER" | cut -d: -f7)" = "$ZSH_PATH" ]; then
  echo "Login shell is already $ZSH_PATH, skipping"
else
  sudo chsh -s "$ZSH_PATH" "$USER"
fi
