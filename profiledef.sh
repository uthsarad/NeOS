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
  bootmodes=("uefi.grub")
elif [ "$arch" == "i686" ]; then
  bootmodes=("bios.syslinux")
elif [ "$arch" == "aarch64" ]; then
  bootmodes=("uefi.grub")
else
  bootmodes=("uefi.grub")
fi

# ⚡ Bolt: Use EROFS with LZ4HC compression for faster boot and app launch times.
# This improves random read performance compared to SquashFS while maintaining good compression.
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc')

# Performance-focused kernel parameters
kernel_parameters+=(
  "nowatchdog"              # Disable hardware watchdog unless specifically needed
  "mce=ignore_ce"           # Ignore corrected errors to reduce log noise
  "intel_pstate=enable"     # Intel CPU power management
    "amd_pstate=active"       # AMD CPU power management
  "quiet"                   # Reduce boot verbosity for faster boot
  "splash"                  # Show splash screen instead of boot messages
  "rd.systemd.show_status=false"  # Hide systemd status during boot
  "rd.udev.log_level=3"     # Reduce udev logging level
  "vt.global_cursor_default=0"    # Hide cursor during boot
)

file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/etc/pacman.conf"]="0:0:644"
  ["/etc/sudoers.d/wheel"]="0:0:440"
  ["/etc/systemd/zram-generator.conf"]="0:0:644"
  ["/usr/local/bin/neos-driver-manager"]="0:0:755"
  ["/usr/local/bin/neos-performance-tweaks"]="0:0:755"
  ["/usr/local/bin/neos-autoupdate.sh"]="0:0:755"
  ["/usr/local/bin/neos-installer-partition.sh"]="0:0:755"
  ["/usr/local/bin/neos-liveuser-setup"]="0:0:755"
)
