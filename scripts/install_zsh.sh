#!/bin/sh

if command -v yay &> /dev/null; then
  yay -S --noconfirm --needed zsh
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y zsh
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

chsh -s $(which zsh)
