#!/bin/sh

yay -S --noconfirm --needed plymouth-theme-optimus-git

sudo plymouth-set-default-theme optimus -R
