#!/bin/sh

yay -S --noconfirm --needed hyprdynamicmonitors-bin

systemctl --user enable --now hyprdynamicmonitors-prepare.service
