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

if ! yay -Qi "brew" &>/dev/null; then
  echo "Brew not installed, installing now..."
  ./install_brew.sh
else
  echo "Brew already installed, skipping"
fi

# Take care of some new Omarchy install prereqs

## Omarchy overrides ##
echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf
echo "source = ~/.config/hypr/omarchy_keybind_overrides.conf" >> ~/.config/hypr/hyprland.conf

## Dotfiles
# Check that ~/.dotfiles doesn't exist first
rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/ ~/.config/omarchy/branding/screensaver.txt

if ! yay -Qi "zsh" &>/dev/null; then
  echo "ZSH not installed, installing now..."
  ./install_zsh.sh
else
  echo "ZSH already installed, skipping"
fi

## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi

# Allow CUPS through firewall
sudo ufw allow 631/tcp

#debloat omarchy
bash <(curl -fsSL https://raw.githubusercontent.com/DanielCoffey1/a-la-carchy/master/a-la-carchy.sh)
