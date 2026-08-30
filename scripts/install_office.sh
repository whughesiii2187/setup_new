#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  dnf remove -y libreoffice*
  flatpak install -y flathub org.libreoffice.LibreOffice
  flatpak install -y --reinstall org.freedesktop.Platform.Locale
  flatpak install -y --reinstall org.libreoffice.LibreOffice.Locale
  flatpak install -y flathub org.onlyoffice.desktopeditors
fi
