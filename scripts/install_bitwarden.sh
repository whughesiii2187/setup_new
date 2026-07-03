#!/bin/sh

if [ -d "$HOME/.config/omarchy/" ]; then 
  yay -Rncs 1password-beta 1password-cli
fi

yay -S --noconfirm --needed bitwarden
