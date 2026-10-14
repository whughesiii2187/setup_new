#!/usr/bin/env bash
set -e

if command -v yay &>/dev/null; then
  yay -S --needed --noconfirm ufw
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y ufw

  # ufw replaces firewalld; don't let both manage the firewall
  sudo systemctl disable --now firewalld 2>/dev/null || true
fi

# Earlier versions opened CUPS to the network; local printing doesn't need it
sudo ufw delete allow 631/tcp 2>/dev/null || true

# Let VMs on libvirt's default network get DHCP leases and DNS
sudo ufw allow in on virbr0 to any port 67:68 proto udp
sudo ufw allow in on virbr0 to any port 53

# mDNS, so network printers and other services are discovered
sudo ufw allow in proto udp to 224.0.0.251 port 5353 comment 'mDNS'
sudo ufw allow in proto udp to ff02::fb port 5353 comment 'mDNS'

# LocalSend receives files on this port (TCP and UDP)
sudo ufw allow 53317 comment 'LocalSend'

# Allow forwarded traffic so libvirt's NAT network works behind ufw
sudo sed -i 's/^DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

sudo systemctl enable ufw
sudo ufw --force enable
