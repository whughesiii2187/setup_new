#!/usr/bin/env bash
set -e

# Btrfs + Snapper setup, paired with the subvolume layout laid down by
# fedora.ks.cfg (LABEL=fedora, root/home subvolumes). Safe to re-run.

sudo dnf install -y snapper python3-dnf-plugin-snapper btrfs-progs

for cfg_pair in "root:/" "home:/home"; do
  cfg="${cfg_pair%%:*}"
  mountpoint="${cfg_pair#*:}"
  if [ ! -f "/etc/snapper/configs/$cfg" ]; then
    sudo snapper --no-dbus -c "$cfg" create-config "$mountpoint"
  fi
done

sudo mkdir -p /.snapshots /home/.snapshots
sudo chmod 750 /.snapshots /home/.snapshots

#
# Cap retained snapshots at 5 per config. Applies to timeline snapshots;
# pre/post transaction snapshots (via python3-dnf-plugin-snapper) are
# governed by NUMBER_LIMIT/NUMBER_LIMIT_IMPORTANT instead.
#
for cfg in root home; do
  sudo sed -i \
    -e 's/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY="5"/' \
    -e 's/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY="0"/' \
    -e 's/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY="0"/' \
    -e 's/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY="0"/' \
    -e 's/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY="0"/' \
    "/etc/snapper/configs/$cfg"
done

if ! grep -q '/.snapshots' /etc/fstab; then
  sudo tee -a /etc/fstab >/dev/null <<'EOF'
LABEL=fedora /.snapshots       btrfs subvol=root/.snapshots,compress=zstd:1 0 0
LABEL=fedora /home/.snapshots  btrfs subvol=home/.snapshots,compress=zstd:1 0 0
EOF
fi
sudo systemctl daemon-reload
sudo mount -a
sudo restorecon -R /.snapshots /home/.snapshots

root_id=$(sudo btrfs subvolume show / | awk '/Subvolume ID:/ {print $NF}')
sudo btrfs subvolume set-default "$root_id" /
sudo grubby --update-kernel=ALL --remove-args="rootflags=subvol=root"

if grep -q '^SNAPPER_CONFIGS=' /etc/sysconfig/snapper 2>/dev/null; then
  sudo sed -i 's/^SNAPPER_CONFIGS=.*/SNAPPER_CONFIGS="root home"/' /etc/sysconfig/snapper
else
  echo 'SNAPPER_CONFIGS="root home"' | sudo tee -a /etc/sysconfig/snapper >/dev/null
fi

#
# Enable automatic (timeline) snapshots
#
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# Baseline snapshot for both configs, so there's always a known-good
# restore point from the time setup ran.
sudo snapper --no-dbus -c root create --description "initial setup"
sudo snapper --no-dbus -c home create --description "initial setup"

#
# grub-btrfs: adds snapshot boot entries to the GRUB menu.
# Replace this with your preferred COPR.
#
sudo dnf -y copr enable pego-copr/grub-btrfs
sudo dnf -y install grub-btrfs
sudo systemctl enable --now grub-btrfsd.service

sudo grub2-mkconfig -o /boot/grub2/grub.cfg
