#!/bin/sh
sudo systemctl disable --now avahi-daemon

yay -S --needed --noconfirm hplip
