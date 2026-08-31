#!/usr/bin/env bash

if command -v yay &> /dev/null; then
  yay -S --needed --noconfirm proton-vpn-gtk-app
elif command -v dnf &> /dev/null; then
  REPO_BASE="https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/"
  RELEASE_RPM_URL="$(dnf --repofrompath "protonvpn-tmp,${REPO_BASE}" --setopt="protonvpn-tmp.gpgcheck=0" -y repoquery --repo protonvpn-tmp --latest-limit=1 --queryformat "%{location}" protonvpn-stable-release 2>/dev/null)"
  if [ -n "$RELEASE_RPM_URL" ]; then
    sudo dnf install -y "$RELEASE_RPM_URL"
    if ! sudo dnf install -y --refresh proton-vpn-gnome-desktop; then
      sleep 3
      if rpm -q proton-vpn-daemon proton-vpn-gnome-desktop &>/dev/null && \
         systemctl is-active --quiet me.proton.vpn.split_tunneling.service; then
        echo "ProtonVPN packages installed and the daemon is running; ignoring the transient posttrans scriptlet failure." >&2
      else
        echo "!!  ProtonVPN install failed for a reason other than the known posttrans race" >&2
        exit 1
      fi
    fi
  else
    echo "!!  Could not resolve latest ProtonVPN release rpm from $REPO_BASE; skipping ProtonVPN install" >&2
  fi
else
  echo "!!  Neither yay nor dnf found; skipping ProtonVPN install" >&2
fi
