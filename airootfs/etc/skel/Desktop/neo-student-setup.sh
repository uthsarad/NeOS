#!/bin/bash

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.libreoffice.LibreOffice org.videolan.VLC org.gimp.GIMP
