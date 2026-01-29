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

# ⚡ Bolt: Use EROFS with LZ4HC compression for faster boot and app launch times.
# This improves random read performance compared to SquashFS while maintaining good compression.
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc')

file_permissions=(
  ["/etc/pacman.conf"]="0:0:644"
)
