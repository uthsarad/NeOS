#!/usr/bin/env bash
# NeOS installation media profile definition
# shellcheck disable=SC2034

iso_name="neos"
iso_label="NEOS_ISO"
iso_publisher="NeOS Team <https://github.com/uthsarad>"
iso_application="NeOS Installation Media"
iso_version="$(date +%Y.%m.%d)"
install_dir="neos"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.grub.esp' 'uefi-x64.grub.esp' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_testing="false"

pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
# zstd instead of xz: xz has the slowest decompression of any squashfs codec, so
# every binary launch in the live session paid a CPU cost — painful in a VM on
# software rendering. zstd decompresses several times faster (snappier live
# desktop) at the same speed regardless of level, so we use the max level (22)
# to keep the image as small as possible and stay under the 2048 MiB release gate.
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '22' '-b' '1M')

file_permissions=(
  ["/root"]="0:0:750"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/neos-driver-manager"]="0:0:755"
  ["/usr/local/bin/neos-autoupdate.sh"]="0:0:755"
  ["/usr/local/bin/neos-installer-partition.sh"]="0:0:755"
  ["/usr/local/bin/neos-liveuser-setup"]="0:0:755"
  ["/usr/local/bin/neos-pacstrap"]="0:0:755"
  ["/usr/local/bin/neos-install-identity"]="0:0:755"
  ["/usr/local/bin/neos-welcome"]="0:0:755"
  ["/usr/local/bin/neos-welcome-app"]="0:0:755"
  ["/usr/local/bin/neos-desktop-setup"]="0:0:755"
  ["/usr/local/bin/neos-vm-graphics"]="0:0:755"
  ["/usr/local/bin/neos-accessibility"]="0:0:755"
  ["/usr/local/bin/neos-secureboot-setup"]="0:0:755"
)
