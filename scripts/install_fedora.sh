#!/usr/bin/env bash

# System Upgrade
echo -e "\033[34mPerforming system upgrade... This may take a while...\033[0m"
sudo dnf upgrade -y

# System Config
# Optimize DNF package manager for faster downloads and efficient updates
sudo cp "/etc/dnf/dnf.conf" "/etc/dnf/dnf.conf.bak"
sudo dnf -y install dnf-plugins-core
echo "gpgcheck=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
echo "installonly_limit=3" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
echo "clean_requirements_on_remove=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
echo "best=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null

### RPM Fusion ###
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf update @core -y

### Flatpak ###
# Replace Fedora Flatpak Repo with Flathub for better package management and apps stability
sudo dnf install -y flatpak
sudo systemctl disable flatpak-add-fedora-repos.service
flatpak remote-delete fedora --force || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak repair
flatpak update

### AppImage ###
sudo dnf install -y fuse-libs
flatpak_install it.mijorus.gearlever

### Media Codecs ###
if command -v dnf4 &>/dev/null; then
  sudo dnf4 group install -y multimedia
else
  sudo dnf group install -y multimedia
fi
sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing                                                  # Switch to full FFMPEG.
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video                                                               # Installs useful Sound and Video complementary packages.

### H/W Video Acceleration
sudo dnf install -y ffmpeg-libs libva libva-utils
sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing
sudo dnf install -y libva-intel-driver

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
