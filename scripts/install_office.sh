#!/usr/bin/env bash

# native fallback, disabled in favor of flatpak — see install_flatpak.sh
# if command -v yay &>/dev/null; then
#   yay -S --noconfirm --needed libreoffice-fresh onlyoffice-bin
# fi

if command -v dnf &>/dev/null; then
  # Fedora ships LibreOffice by default; remove it so the Flatpak build owns
  # the "libreoffice" name instead of the two colliding.
  sudo dnf remove -y libreoffice*
fi

flatpak_install flathub org.libreoffice.LibreOffice
flatpak_install --reinstall org.freedesktop.Platform.Locale
flatpak_install --reinstall org.libreoffice.LibreOffice.Locale
flatpak_install flathub org.onlyoffice.desktopeditors
