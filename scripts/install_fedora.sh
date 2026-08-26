#!/usr/bin/env bash

# System Upgrade
echo -e "\033[34mPerforming system upgrade... This may take a while...\033[0m"
dnf upgrade -y >/dev/null 2>&1

# System Config
# Optimize DNF package manager for faster downloads and efficient updates
sudo backup_file "/etc/dnf/dnf.conf" >/dev/null 2>&1
sudo dnf -y install dnf-plugins-core >/dev/null 2>&1
sudo echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf >/dev/null
sudo echo "fastestmirror=True" | tee -a /etc/dnf/dnf.conf >/dev/null
sudo echo "defaultyes=True" | tee -a /etc/dnf/dnf.conf >/dev/null

### RPM Fusion ###
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm >/dev/null 2>&1
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm >/dev/null 2>&1
sudo dnf update @core -y

### Flatpak ###
# Replace Fedora Flatpak Repo with Flathub for better package management and apps stability
sudo dnf install -y flatpak >/dev/null 2>&1
flatpak remote-delete fedora --force || true >/dev/null 2>&1
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1
sudo flatpak repair >/dev/null 2>&1
flatpak update >/dev/null 2>&1

### AppImage ###
sudo dnf install fuse-libs
flatpak install it.mijorus.gearlever

### Media Codecs ###
sudo dnf4 group install multimedia >/dev/null 2>&1
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing >/dev/null 2>&1                                                  # Switch to full FFMPEG.
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin >/dev/null 2>&1 # Installs gstreamer components. Required if you use Gnome Videos and other dependent applications.
sudo dnf group install -y sound-and-video >/dev/null 2>&1                                                            # Installs useful Sound and Video complementary packages.

### H/W Video Acceleration
sudo dnf install ffmpeg-libs libva libva-utils
sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing
sudo dnf install libva-intel-driver

sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

# Install virtualization tools to enable virtual machines and containerization
sudo dnf install -y @virtualization >/dev/null 2>&1

# Install essential applications
dnf install -y btop inxi unzip unrar git wget curl gnome-tweaks >/dev/null 2>&1

# Install Coding and DevOps applications
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
systemctl enable --now docker >/dev/null 2>&1
systemctl enable --now containerd >/dev/null 2>&1
groupadd docker >/dev/null 2>&1
usermod -aG docker $ACTUAL_USER >/dev/null 2>&1
rm -rf $ACTUAL_HOME/.docker >/dev/null 2>&1

### Optimizations ###
sudo systemctl disable NetworkManager-wait-online.service
mkdir -p ~/.config/autostart
cp /usr/share/applications/org.gnome.Software.desktop ~/.config/autostart/
echo "X-GNOME-Autostart-enabled=false" >>~/.config/autostart/org.gnome.Software.desktop
dconf write /org/gnome/desktop/search-providers/disabled "['org.gnome.Software.desktop']"
