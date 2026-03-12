#!/bin/sh
yay -Rnc --noconfirm docker docker-compose docker-buildx
yay -S --noconfirm --needed podman podman-docker podman-compose podman-desktop
