#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="neos"
iso_label="NEOS_$(date +%Y%m)"
iso_publisher="NeOS Project"
iso_application="NeOS Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="neos"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/root"]="0:0:750"
)
