#!/usr/bin/env bash
set -e

if command -v dnf &>/dev/null; then
  sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine --noautoremove
  sudo dnf -y install dnf-plugins-core
  if command -v dnf4 &>/dev/null; then

    sudo dnf4 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  else

    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  fi
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif command -v yay &>/dev/null; then
  yay -S --noconfirm --needed docker docker-compose docker-buildx
fi

if ! command -v docker &>/dev/null; then
  echo "!!  docker not found on PATH after install step, skipping enable/group setup" >&2
  exit 1
fi

sudo systemctl enable --now docker
sudo systemctl enable --now containerd
getent group docker &>/dev/null || sudo groupadd docker
sudo usermod -aG docker "$USER"
rm -rf "$HOME/.docker"
