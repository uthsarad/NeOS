#!/usr/bin/env bash
# NeOS archiso profile definition

iso_name="neos"
_iso_date="$(date +%Y%m%d)"
iso_label="NEOS_LIVE"
iso_publisher="NeOS Project <https://neos.example>"
iso_application="NeOS Linux"
iso_version="${_iso_date:0:4}.${_iso_date:4:2}.${_iso_date:6:2}"
unset _iso_date
install_dir="neos"
buildmodes=("iso")
pacman_conf="pacman.conf"
if [ -z "$arch" ]; then
  arch="x86_64"
fi

if [ "$arch" == "x86_64" ]; then
  bootmodes=("bios.syslinux" "uefi.grub")
elif [ "$arch" == "i686" ]; then
  bootmodes=("bios.syslinux")
elif [ "$arch" == "aarch64" ]; then
  bootmodes=("uefi.grub")
else
  bootmodes=("uefi.grub")
fi

# Use squashfs with xz compression to keep the ISO under GitHub's 2 GiB release asset limit.
# xz with BCJ filter provides the best compression ratio for x86_64 binaries.
airootfs_image_type="squashfs"
if [ "$arch" == "x86_64" ] || [ "$arch" == "i686" ]; then
  airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
else
  airootfs_image_tool_options=('-comp' 'xz' '-b' '1M' '-Xdict-size' '1M')
fi

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/etc/pacman.conf"]="0:0:644"
  ["/etc/sudoers.d/wheel"]="0:0:440"
  ["/etc/systemd/zram-generator.conf"]="0:0:644"
  ["/usr/local/bin/neos-driver-manager"]="0:0:755"
  ["/usr/local/bin/neos-autoupdate.sh"]="0:0:755"
  ["/usr/local/bin/neos-installer-partition.sh"]="0:0:755"
  ["/usr/local/bin/neos-liveuser-setup"]="0:0:755"
  ["/etc/skel/Desktop/neo-student-setup.sh"]="0:0:755"
)
