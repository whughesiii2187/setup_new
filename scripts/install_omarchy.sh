#!/bin/sh

## Install hyprdynamicmonitors
# if ! yay -Qi "hyprdynamicmonitors-bin" &>/dev/null; then
#   echo "hyprdynamicmonitors not installed, installing now..."
#   ./install_hyprdynamicmonitors.sh
# else
#   echo "hyprdynamicmonitors already installed"
# fi

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
