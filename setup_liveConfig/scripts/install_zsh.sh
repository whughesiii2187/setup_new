#!/bin/sh

yay -S --noconfirm --needed zsh oh-my-posh

chsh -s $(which zsh)
