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

if ! yay -Qi "hyprdynamicmonitors-bin" &>/dev/null; then
  echo "hyprdynamicmonitors not installed, installing now..."
  ./install_hyprdynamicmonitors.sh
else
  echo "hyprdynamicmonitors already installed"
fi

# Take care of some new Omarchy install prereqs

## Omarchy overrides ##
echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf

## Dotfiles
# Check that ~/.dotfiles doesn't exist first
rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.local/state/nvim/ ~/.local/share/nvim/ ~/.config/omarchy/branding/screensaver.txt

#Install Themes
omarchy-theme-install https://github.com/JJDizz1L/aetheria.git
omarchy-theme-install https://github.com/HANCORE-linux/omarchy-sapphire-theme.git

## Clone and Stow Dotfiles ##
if [ -d ~/.dotfiles/.config ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi

# Install better wifi tui
if ! yay -Qi "gazelle-tui" &>/dev/null; then
  echo "Gazelle-tui not installed, installing now"
  ./install_gazelle.sh
else
  echo "Gazelle-tui already installed, skipping"
fi

## Setup VPN ##
./install_vpn.sh
