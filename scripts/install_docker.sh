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

# A ~/.docker created by an earlier `sudo docker ...` is owned by root and
# breaks the docker CLI for this user; fix ownership instead of deleting it,
# which would also throw away saved registry logins.
if [ -d "$HOME/.docker" ]; then
  sudo chown -R "$USER:$(id -gn)" "$HOME/.docker"
fi

# ------------------------------------------------------
# Allow virbr0 forwarding through Docker's DOCKER-USER chain
# ------------------------------------------------------
# Docker sets the iptables/nftables FORWARD chain policy to DROP and only
# accepts traffic on interfaces it manages itself, which silently blocks
# libvirt's virbr0 NAT traffic even though libvirt's own rules allow it.
# DOCKER-USER is Docker's documented extension chain for exactly this case
# (https://docs.docker.com/engine/network/packet-filtering-firewalls/), but
# Docker can rebuild its managed tables on restart, so the rule needs to be
# reapplied by something ordered after docker.service rather than inserted
# once by hand.
sudo tee /etc/systemd/system/docker-user-virbr0.service >/dev/null <<'EOF'
[Unit]
Description=Allow forwarded traffic on virbr0 through Docker's DOCKER-USER chain
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'iptables -C DOCKER-USER -i virbr0 -j ACCEPT 2>/dev/null || iptables -I DOCKER-USER -i virbr0 -j ACCEPT'
ExecStart=/bin/sh -c 'iptables -C DOCKER-USER -o virbr0 -j ACCEPT 2>/dev/null || iptables -I DOCKER-USER -o virbr0 -j ACCEPT'
ExecStop=/bin/sh -c 'iptables -D DOCKER-USER -i virbr0 -j ACCEPT 2>/dev/null || true'
ExecStop=/bin/sh -c 'iptables -D DOCKER-USER -o virbr0 -j ACCEPT 2>/dev/null || true'

[Install]
WantedBy=docker.service
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now docker-user-virbr0.service
