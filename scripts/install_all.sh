#!/bin/sh

## Install pakcages I use ##
if ! yay -Qi "ghostty" &>/dev/null; then
  echo "Ghostty terminal not installed, installing now"
  ./install_ghostty.sh
else
  echo "Ghostty terminal already installed, skipping"
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
  ./install_podman.sh
else
  echo "Podman already installed, skipping"
fi

if ! yay -Qi "tmux" &>/dev/null; then
  echo "TMUX not installed, installing now..."
  ./install_tmux.sh
else
  echo "TMUX already installed, skipping"
fi

# Take care of some new Omarchy install prereqs
# ./install_omarchy.sh

## Clone and Stow Dotfiles ##
if [ -d ~/.dotfiles/.config ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi

## Omarchy overrides ##
echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf

## Screensaver text I hate that ugly Omarcy one ###
# cp ../omarchy/screensaver.txt ~/.config/omarchy/branding/

## Dotfiles
# Check that ~/.dotfiles doesn't exist first
rm -rf ~/.config/kitty/ ~/.config/nvim/ ~/.local/state/nvim/ ~/.local/share/nvim/

#Install Themes
omarchy-theme-install https://github.com/JJDizz1L/aetheria.git
omarchy-theme-install https://github.com/HANCORE-linux/omarchy-sapphire-theme.git

## Setup VPN ##
./install_vpn.sh
