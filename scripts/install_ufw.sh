#!/bin/sh

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm ufw
fi

if command -v dnf &> /dev/null; then
  sudo dnf install -y ufw

  # Fedora ships firewalld enabled by default, and it conflicts with ufw on
  # the nftables backend (ufw's iptables-restore/ip6tables-restore calls fail
  # with "ERROR: problem running" while firewalld still owns the nftables
  # tables). They can't run at the same time, so disable firewalld first.
  if systemctl is-active --quiet firewalld; then
    sudo systemctl disable --now firewalld
  fi
fi

# Allow CUPS through firewall
sudo ufw allow 631/tcp
sudo ufw allow in on virbr0 to any port 67:68 proto udp
sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
