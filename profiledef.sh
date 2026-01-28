#!/usr/bin/env bash
# NeOS archiso profile definition

iso_name="neos"
iso_label="NEOS_$(date +%Y%m)"
iso_publisher="NeOS Project <https://neos.example>"
iso_application="NeOS Linux"
iso_version="$(date +%Y.%m.%d)"
install_dir="neos"
buildmodes=("iso")
bootmodes=("bios.syslinux.mbr" "bios.syslinux.eltorito" "uefi-x64.systemd-boot.esp" "uefi-x64.systemd-boot.eltorito")
arch="x86_64"

file_permissions=(
  ["/etc/pacman.conf"]="0:0:644"
  ["/etc/sudoers.d/wheel"]="0:0:440"
)
