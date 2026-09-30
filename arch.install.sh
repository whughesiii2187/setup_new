#!/usr/bin/env bash
#
# Arch Linux Personal Workstation
# Encrypted Btrfs + Snapper — this is Arch's equivalent of fedora.ks.cfg,
# built to lay down the EXACT SAME disk layout (label + subvolume names)
# so scripts/install_snapper.sh works identically on either distro.
#
# Run this from the Arch ISO's live environment (as root).
# Replace every occurrence of "nvme0n1" with the actual target disk if needed.
#
# THIS ERASES THE TARGET DISK. Test in a VM before running on real hardware.
#
# Snapper/grub-btrfs setup is handled post-boot by scripts/install_arch.sh
# and scripts/install_snapper.sh (this project's post-install scripts), not
# here, since they don't need to happen during the install itself.

set -euo pipefail

DISK=/dev/nvme0n1
LABEL=linux
TIMEZONE=America/Chicago

EFI_PART="${DISK}p1"
BOOT_PART="${DISK}p2"
BTRFS_PART="${DISK}p3"

echo "==> This will ERASE ALL DATA on $DISK. Ctrl+C now to abort."
sleep 10

## Partition (GPT, UEFI) ##
sgdisk --zap-all "$DISK"
sgdisk -n1:0:+600MiB -t1:ef00 -c1:EFI "$DISK"
sgdisk -n2:0:+1024MiB -t2:8300 -c2:boot "$DISK"
sgdisk -n3:0:0 -t3:8300 -c3:btrfs "$DISK"
partprobe "$DISK"

## Encrypt the Btrfs partition (matches fedora.ks.cfg's luks-version=luks2) ##
cryptsetup luksFormat --type luks2 "$BTRFS_PART"
cryptsetup open "$BTRFS_PART" cryptroot

## Filesystems ##
mkfs.fat -F32 -n EFI "$EFI_PART"
mkfs.ext4 -L boot "$BOOT_PART"
mkfs.btrfs -L "$LABEL" /dev/mapper/cryptroot

## Subvolumes — same names as fedora.ks.cfg ##
mount /dev/mapper/cryptroot /mnt
for sv in root home var_log var_cache var_tmp var_lib_containers var_lib_libvirt; do
  btrfs subvolume create "/mnt/$sv"
done
umount /mnt

## Mount everything ##
mount -o subvol=root,compress=zstd:1 /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache,var/tmp,var/lib/containers,var/lib/libvirt/images}
mount "$BOOT_PART" /mnt/boot
mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi
mount -o subvol=home,compress=zstd:1               /dev/mapper/cryptroot /mnt/home
mount -o subvol=var_log,compress=zstd:1            /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=var_cache,compress=zstd:1          /dev/mapper/cryptroot /mnt/var/cache
mount -o subvol=var_tmp,compress=zstd:1            /dev/mapper/cryptroot /mnt/var/tmp
mount -o subvol=var_lib_containers,compress=zstd:1 /dev/mapper/cryptroot /mnt/var/lib/containers
mount -o subvol=var_lib_libvirt,compress=zstd:1    /dev/mapper/cryptroot /mnt/var/lib/libvirt/images

## Base install ##
pacstrap -K /mnt base linux linux-firmware btrfs-progs grub efibootmgr \
  networkmanager iwd curl git tar gzip inotify-tools sudo

genfstab -U /mnt >>/mnt/etc/fstab

BTRFS_PART_UUID=$(blkid -s UUID -o value "$BTRFS_PART")

read -rp "Username to create (added to the wheel group): " USERNAME

arch-chroot /mnt /bin/bash <<CHROOT
set -euo pipefail

ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

systemctl enable NetworkManager

# LUKS unlock at boot: /boot is a plain unencrypted partition (same split as
# fedora.ks.cfg), so only the initramfs + kernel cmdline need to know about
# the encrypted root.
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

echo "cryptroot UUID=$BTRFS_PART_UUID none luks" >/etc/crypttab

sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$BTRFS_PART_UUID:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=root\"|" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# wheel group gets sudo (matches Fedora's default admin-via-sudo setup)
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

useradd -m -G wheel -s /bin/bash "$USERNAME"

echo "==> Set the password for $USERNAME:"
passwd "$USERNAME"

echo "==> Set the root password:"
passwd
CHROOT

echo "==> Base install complete. Reboot into the new system, then run scripts/install_arch.sh."
