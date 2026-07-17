#!/bin/sh

if [ -d "$HOME/.config/omarchy/" ]; then 
  yay -Rncs 1password-beta 1password-cli
fi

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed bitwarden
fi

if command -v dnf &> /dev/null; then
  sudo dnf install snap
  sudo snap wait system seed.loaded
  sudo snap install bitwarden
fi
