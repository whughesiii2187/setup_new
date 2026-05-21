#!/bin/sh

yay -S --noconfirm --needed zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

chsh -s $(which zsh)
