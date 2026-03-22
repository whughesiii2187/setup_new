#!/bin/sh

mkdir ~/dotfiles
cp -r ../dotfiles/.* ~/dotfiles/
cd ~/dotfiles
stow . --adopt
