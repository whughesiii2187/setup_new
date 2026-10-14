#!/usr/bin/env bash
set -e

# Btrfs + Snapper setup, paired with the subvolume layout laid down by
# fedora.ks.cfg / arch.install.sh (root/home subvolumes). Safe to re-run.

. /etc/os-release

case "$ID" in
fedora) sudo dnf install -y snapper python3-dnf-plugin-snapper btrfs-progs ;;
arch) yay -S --noconfirm --needed snapper snap-pac btrfs-progs grub-btrfs inotify-tools ;;
*)
  echo "!!  install_snapper.sh supports Fedora and Arch only (found $ID)" >&2
  exit 1
  ;;
esac

if [ "$(findmnt -no FSTYPE /)" != "btrfs" ]; then
  echo "!!  / isn't Btrfs; skipping Snapper setup" >&2
  exit 1
fi

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
# pre/post transaction snapshots (python3-dnf-plugin-snapper / snap-pac)
# are governed by NUMBER_LIMIT/NUMBER_LIMIT_IMPORTANT instead.
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

# Use the filesystem's UUID rather than a label, so this works whatever
# label the installer gave the filesystem
if ! grep -q '/.snapshots' /etc/fstab; then
  fs_uuid=$(findmnt -no UUID /)
  sudo tee -a /etc/fstab >/dev/null <<EOF
UUID=$fs_uuid /.snapshots       btrfs subvol=root/.snapshots,compress=zstd:1 0 0
UUID=$fs_uuid /home/.snapshots  btrfs subvol=home/.snapshots,compress=zstd:1 0 0
EOF
fi
sudo systemctl daemon-reload
sudo mount -a

if [ "$ID" = "fedora" ]; then
  sudo restorecon -R /.snapshots /home/.snapshots

  root_id=$(sudo btrfs subvolume show / | awk '/Subvolume ID:/ {print $NF}')
  sudo btrfs subvolume set-default "$root_id" /
  sudo grubby --update-kernel=ALL --remove-args="rootflags=subvol=root"

  snapper_sysconfig=/etc/sysconfig/snapper
else
  snapper_sysconfig=/etc/conf.d/snapper
fi

if grep -q '^SNAPPER_CONFIGS=' "$snapper_sysconfig" 2>/dev/null; then
  sudo sed -i 's/^SNAPPER_CONFIGS=.*/SNAPPER_CONFIGS="root home"/' "$snapper_sysconfig"
else
  echo 'SNAPPER_CONFIGS="root home"' | sudo tee -a "$snapper_sysconfig" >/dev/null
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
# Fedora: replace this with your preferred COPR. Arch: installed above.
#
if [ "$ID" = "fedora" ]; then
  sudo dnf -y copr enable pego-copr/grub-btrfs
  sudo dnf -y install grub-btrfs
fi
sudo systemctl enable --now grub-btrfsd.service

if [ "$ID" = "fedora" ]; then
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
else
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
