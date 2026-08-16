#!/bin/sh

## Install pakcages I use ##
./install_ghostty.sh
./install_bitwarden.sh
./install_stow.sh
./install_brew.sh
./install_printer.sh
./install_zsh.sh
./install_vpn.sh

# Take care of some new Omarchy install prereqs
## Omarchy overrides ##
HYPR_VERSION="hyprland --version-json | jq '.version'"
if [ -d "$HOME/.config/omarchy" ]; then
  if [[ "$HYPR_VERSION" > "0.55.0" ]]; then
    echo "require(\"omarchy_overrides\")" >> ~/.config/hypr/hyprland.lua
  else
    echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf
  fi
fi

# Allow CUPS through firewall
sudo ufw allow 631/tcp

#debloat omarchy
# if [ -d "$HOME/.config/omarchy" ]; then
#   bash <(curl -fsSL https://raw.githubusercontent.com/DanielCoffey1/a-la-carchy/master/a-la-carchy.sh)
# fi

## Dotfiles
# Check that ~/.dotfiles doesn't exist first
rm -rf ~/.config/ghostty/ ~/.config/tmux ~/.config/tmux
# rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/ ~/.config/tmux
## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi

./install_tmux.sh
