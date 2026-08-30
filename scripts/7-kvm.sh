#!/usr/bin/env bash
# ------------------------------------------------------
# Install Script for Libvirt
# ------------------------------------------------------

read -p "Do you want to start? " s
echo "START KVM/QEMU/VIRT MANAGER INSTALLATION..."

# ------------------------------------------------------
# Install Packages
# ------------------------------------------------------
if command -v yay &>/dev/null; then
  yay -S --needed libvirt virt-manager virt-viewer qemu-full vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf swtpm
fi

if command -v dnf &>/dev/null; then
  sudo dnf install -y libvirt virt-manager virt-viewer qemu-kvm ebtables iptables-nft nftables dnsmasq bridge-utils edk2-ovmf swtpm #vde2
fi

# ------------------------------------------------------
# Edit libvirtd.conf
# ------------------------------------------------------
# TODO: Use sed to remove the #
echo "Manual steps required:"
echo "Open sudo nvim /etc/libvirt/libvirtd.conf:"
echo 'Remove # at the following lines: unix_sock_group = "libvirt" and unix_sock_rw_perms = "0770"'
read -p "Press any key to open libvirtd.conf: " c
sudo nvim /etc/libvirt/libvirtd.conf
sudo echo 'log_filters="3:qemu 1:libvirt"' >>/etc/libvirt/libvirtd.conf
sudo echo 'log_outputs="2:file:/var/log/libvirt/libvirtd.log"' >>/etc/libvirt/libvirtd.conf

# ------------------------------------------------------
# Add user to the group
# ------------------------------------------------------
sudo usermod -a -G kvm,libvirt $(whoami)

# ------------------------------------------------------
# Enable services
# ------------------------------------------------------
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# ------------------------------------------------------
# Edit qemu.conf
# ------------------------------------------------------
# TODO: Investigate using the defaults and adding users to the qemu group
echo "Manual steps required:"
echo "Open sudo nvim /etc/libvirt/qemu.conf"
echo "Uncomment and add your user name to user and group."
echo 'user = "your username"'
echo 'group = "your username"'
read -p "Press any key to open qemu.conf: " c
sudo nvim /etc/libvirt/qemu.conf

# ------------------------------------------------------
# Restart Services
# ------------------------------------------------------
sudo systemctl restart libvirtd

# ------------------------------------------------------
# Autostart Network
# ------------------------------------------------------
sudo virsh net-autostart default

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
if command -v docker &>/dev/null; then
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
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now docker-user-virbr0.service
fi

echo "Please restart your system with reboot."
