#!/bin/sh
yay -Rnc --noconfirm docker
yay -S --noconfirm --needed podman podman-docker podman-compose
