#!/usr/bin/env bash
# NeOS archiso profile definition

iso_name="neos"
_iso_date="$(date +%Y%m%d)"
iso_label="NEOS_${_iso_date:0:6}"
iso_publisher="NeOS Project <https://neos.example>"
iso_application="NeOS Linux"
iso_version="${_iso_date:0:4}.${_iso_date:4:2}.${_iso_date:6:2}"
unset _iso_date
install_dir="neos"
buildmodes=("iso")
bootmodes=("bios.syslinux.mbr" "bios.syslinux.eltorito" "uefi-x64.systemd-boot.esp" "uefi-x64.systemd-boot.eltorito")
arch="x86_64"
airootfs_image_type="erofs"

file_permissions=(
  ["/etc/pacman.conf"]="0:0:644"
  ["/etc/sudoers.d/wheel"]="0:0:440"
)
