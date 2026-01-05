#!/bin/sh

## Install theme ##
if ! omarchy-theme-list | grep "Neovoid" &>/dev/null; then
  echo "Installing Neovoid theme"
  ./install_neovoid.sh
else
  echo "Neovoid theme already installed, skipping"
fi

if ! yay -Qi "gazelle-tui" &>/dev/null; then
  echo "Gazelle-tui not installed, installing now..."
  ./install_gazelle.sh
else
  echo "Gazelle-tui already installed"
fi

## Install Optimus Boot Theme ##
./install_optimus.sh

## Omarchy overrides ##
#check that file doesn't exist and that entry to hyprland.conf doesn't exist
cp ../omarchy/omarchy_overrides.conf ~/.config/hypr/
echo "source = ~/.config/hypr/omarchy_overrides.conf" >> ~/.config/hypr/hyprland.conf

## VPN Toggle ##
# check that file doesn't exist first
cp ../omarchy/omarchy-toggle-vpn ~/.local/share/omarchy/bin/
cp ../omarchy/omarchy-fix-hyprlock ~/.local/share/omarchy/bin/

## Dotfiles
# Check that ~/.dotfiles doesn't exist first
rm -rf ~/.config/kitty/ ~/.config/nvim/ ~/.local/state/nvim/ ~/.local/share/nvim/

