#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine --noautoremove
  sudo dnf -y install dnf-plugins-core
  if command -v dnf4 &>/dev/null; then

    sudo dnf4 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  else

    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  fi
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

sudo systemctl enable --now docker
sudo systemctl enable --now containerd
sudo groupadd docker
sudo usermod -aG docker "$USER"
rm -rf "$HOME/.docker"
