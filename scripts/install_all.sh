#!/bin/sh

## Install pakcages I use ##
./install_ghostty.sh
./install_bitwarden.sh
./install_stow.sh
./install_brew.sh
./install_printer.sh
./install_zsh.sh

# Take care of some new Omarchy install prereqs
## Omarchy overrides ##
if [ -d "$HOME/.config/omarchy" ]; then
  echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf
  echo "source = ~/.config/hypr/omarchy_keybind_overrides.conf" >> ~/.config/hypr/hyprland.conf
fi

# Allow CUPS through firewall
sudo ufw allow 631/tcp

#debloat omarchy
if [ -d "$HOME/.config/omarchy" ]; then
  bash <(curl -fsSL https://raw.githubusercontent.com/DanielCoffey1/a-la-carchy/master/a-la-carchy.sh)
fi

## Dotfiles
# Check that ~/.dotfiles doesn't exist first
rm -rf ~/.config/ghostty/ ~/.config/nvim/ ~/.config/tmux ~/.local/state/nvim/ ~/.local/share/nvim/ ~/.config/tmux
## Clone and Stow Dotfiles ##
if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles appear to be installed already, skipping"
else
  ./install_dotfiles.sh
fi

./install_tmux.sh
# ./install_vpn.sh
# ./install_gazelle.sh
