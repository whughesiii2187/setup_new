#!/usr/bin/env bash

# System Upgrade
echo -e "\033[34mPerforming system upgrade... This may take a while...\033[0m"
sudo dnf upgrade -y

# System Config
# Optimize DNF package manager for faster downloads and efficient updates
# Back up the original once, so reruns don't overwrite it with an edited copy
[ -f /etc/dnf/dnf.conf.bak ] || sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bak
sudo dnf -y install dnf-plugins-core

# Set key=value in dnf.conf, replacing an existing line instead of appending
# a duplicate on every run
set_dnf_opt() {
  if grep -q "^$1=" /etc/dnf/dnf.conf; then
    sudo sed -i "s/^$1=.*/$1=$2/" /etc/dnf/dnf.conf
  else
    echo "$1=$2" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
  fi
}
set_dnf_opt gpgcheck True
set_dnf_opt installonly_limit 3
set_dnf_opt clean_requirements_on_remove True
set_dnf_opt best True
set_dnf_opt max_parallel_downloads 10
set_dnf_opt fastestmirror True
set_dnf_opt defaultyes True

### RPM Fusion ###
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf update @core -y

### Media Codecs ###
if command -v dnf4 &>/dev/null; then
  sudo dnf4 group install -y multimedia
else
  sudo dnf group install -y multimedia
fi
sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing                                                  # Switch to full FFMPEG.
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video                                                               # Installs useful Sound and Video complementary packages.

### H/W Video Acceleration ###
# Only install the drivers for the GPU(s) actually present
sudo dnf install -y pciutils ffmpeg-libs libva libva-utils
GPUS="$(lspci -nn | grep -Ei 'vga|3d|display')"

if grep -qi intel <<<"$GPUS"; then
  sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing
  sudo dnf install -y libva-intel-driver
fi

if grep -Eq 'Advanced Micro Devices|AMD\/ATI' <<<"$GPUS"; then
  sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
  sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing
fi

if grep -qi nvidia <<<"$GPUS"; then
  # akmod builds the kernel module after install; with Secure Boot on, the
  # module's signing key must be enrolled (mokutil) before it will load
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver
fi

sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

# Install virtualization tools to enable virtual machines and containerization
sudo dnf install -y @virtualization

### Optimizations ###
sudo systemctl disable NetworkManager-wait-online.service
if [ -f /usr/share/applications/org.gnome.Software.desktop ]; then
  mkdir -p ~/.config/autostart
  cp /usr/share/applications/org.gnome.Software.desktop ~/.config/autostart/
  echo "X-GNOME-Autostart-enabled=false" >>~/.config/autostart/org.gnome.Software.desktop
  dconf write /org/gnome/desktop/search-providers/disabled "['org.gnome.Software.desktop']"
fi
