#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine --noautoremove >/dev/null 2>&1
  dnf -y install dnf-plugins-core >/dev/null 2>&1
  if command -v dnf4 &>/dev/null; then
    >/dev/null 2>&1
    dnf4 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo >/dev/null 2>&1
  else
    >/dev/null 2>&1
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo >/dev/null 2>&1
  fi >/dev/null 2>&1
  dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1
fi

systemctl enable --now docker >/dev/null 2>&1
systemctl enable --now containerd >/dev/null 2>&1
groupadd docker >/dev/null 2>&1
usermod -aG docker $ACTUAL_USER >/dev/null 2>&1
rm -rf $ACTUAL_HOME/.docker >/dev/null 2>&1
