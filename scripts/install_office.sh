#!/usr/bin/env bash

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed libreoffice-fresh onlyoffice-bin
# fi

if command -v dnf &>/dev/null; then
  # Fedora ships LibreOffice by default; remove it so the Flatpak build owns
  # the "libreoffice" name instead of the two colliding.
  sudo dnf remove -y 'libreoffice*'
fi

flatpak_install flathub org.libreoffice.LibreOffice
# Reinstall the locale extensions so they pick up the system languages. The
# runtime's Locale needs the exact branch LibreOffice uses, or flatpak can't
# tell which of the installed runtime versions is meant.
LO_RUNTIME="$(flatpak info --system --show-runtime org.libreoffice.LibreOffice)" # e.g. org.freedesktop.Platform/x86_64/25.08
flatpak_install --reinstall flathub "org.freedesktop.Platform.Locale//${LO_RUNTIME##*/}"
flatpak_install --reinstall flathub org.libreoffice.LibreOffice.Locale
flatpak_install flathub org.onlyoffice.desktopeditors
