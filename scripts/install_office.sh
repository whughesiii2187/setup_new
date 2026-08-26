#!/usr/bin/env bash

if command -v dnf &>/dev/null; then
  dnf remove -y libreoffice* >/dev/null 2>&1
  flatpak install -y flathub org.libreoffice.LibreOffice >/dev/null 2>&1
  flatpak install -y --reinstall org.freedesktop.Platform.Locale/x86_64/24.08 >/dev/null 2>&1
  flatpak install -y --reinstall org.libreoffice.LibreOffice.Locale >/dev/null 2>&1
  flatpak install -y flathub org.onlyoffice.desktopeditors >/dev/null 2>&1
fi
