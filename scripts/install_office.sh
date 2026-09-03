#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  dnf remove -y libreoffice*
  flatpak_install flathub org.libreoffice.LibreOffice
  flatpak_install --reinstall org.freedesktop.Platform.Locale
  flatpak_install --reinstall org.libreoffice.LibreOffice.Locale
  flatpak_install flathub org.onlyoffice.desktopeditors
fi
