#!/bin/sh

##  TODO: If install var = omarchy, then do this. 
# ./install_omarchy.sh

## Install pakcages I use ##
if ! yay -Qi "zen-browser-bin" &>/dev/null; then
  echo "Zen Browser not installed, installing now..."
   ./install_zen.sh
else
  echo "Zen Browser already installed, skipping"
fi

if ! yay -Qi "kitty" &>/dev/null; then
  echo "Kitty terminal not installed, installing now"
  ./install_kitty.sh
else
  echo "Kitty terminal already installed, skipping"
fi

if ! yay -Qi "bitwarden" &>/dev/null; then
  echo "Bitwarden not installed, installing now..."
  ./install_bitwarden.sh
else
  echo "Bitwarden alraedy installed,"
fi

if ! yay -Qi "stow" &>/dev/null; then
  echo "Stow not installed, installing now..."
  ./install_stow.sh
else
  echo "Stow already installed, skipping"
fi

if ! yay -Qi "zsh" &>/dev/null; then
  echo "ZSH not installed, installing now..."
  ./install_zsh.sh
else
  echo "ZSH already installed, skipping"
fi

if ! yay -Qi "podman" &>/dev/null; then
  echo "Podman and tools not installed, installing now..."
else
  ./install_podman.sh
fi

## Clone and Stow Dotfiles ##
if [ -d ~/.dotfiles/.config ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi
