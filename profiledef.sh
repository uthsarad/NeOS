#!/usr/bin/env bash
# NeOS CLI Netinstaller profile definition

iso_name="neos"
iso_label="NEOS_ISO"
iso_publisher="NeOS Team <https://github.com/uthsarad>"
iso_application="NeOS CLI Netinstaller"
iso_version="$(date +%Y.%m.%d)"
install_dir="neos"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.grub.esp' 'uefi-x64.grub.esp' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_testing="false"

pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M')

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/usr/local/bin/neos-driver-manager"]="0:0:755"
  ["/usr/local/bin/neos-autoupdate.sh"]="0:0:755"
  ["/usr/local/bin/neos-installer-partition.sh"]="0:0:755"
  ["/usr/local/bin/neos-liveuser-setup"]="0:0:755"
)
