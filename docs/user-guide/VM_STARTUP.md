# VM Startup Modules

[← Back to Documentation Index](../README.md#documentation)

NeOS ships a conservative set of modules to improve boot reliability in common VM environments. The list is included in the initramfs via `mkinitcpio.conf` for early boot and loaded via `modules-load.d` once the root filesystem is available, alongside filesystem modules for Btrfs and ZFS when configured.

## Boot the live installer in VMware

1. Power off the VM. Open **VM Settings → CD/DVD (SATA) → Use ISO image file**
   and select the NeOS ISO. Enable **Connect at power on**.
2. Choose **VM → Power → Power On to Firmware**, then select the virtual
   CD/DVD drive in the firmware boot menu. This also works when the virtual
   hard disk already contains an installation.
3. Choose **Try or Install NeOS (Live Desktop)**. The live session signs in
   automatically and opens the welcome window. Choose **Try NeOS** to explore
   or **Install NeOS** to open the graphical installer.

A menu containing only **NeOS Linux** and **Advanced options for NeOS Linux**
belongs to the installed hard disk, not the live ISO. A `NeOS login:` text prompt
is not the live installer. Boot the CD/DVD drive using the steps above.

The current live image uses the NeOS logo and progress dots during boot. If you
still see the old cat animation, check that the VM is booting a newly built ISO;
updating this repository does not replace an ISO or an existing VM installation.
After installation, disconnect the ISO and boot the virtual hard disk.

The live login manager waits for live-user setup. If an image is missing the
prebuilt live account, startup creates it before attempting automatic login.
The ISO boot check requires an active live-user graphical session and its
desktop process; reaching a TTY or only the boot splash does not pass.
No username, password or shell commands are needed to start the live desktop.

## Graphical startup fallback

In VMs, NeOS selects the Xfce desktop on X11 and uses software rendering. If a
VMware VGA adapter has no bound driver and exposes no DRM device, logind may
report that the machine has no graphical seat. SDDM then waits instead of
starting Xorg, even when Xorg's VESA driver can display the desktop.

NeOS waits briefly for udev and driver initialization, then applies a runtime-only
seat rule to that specific unbound VMware adapter. This allows SDDM to start
Xorg's fallback. The rule is not written into the installed system's persistent
configuration, and does not match once a graphics driver binds the adapter.
Adapters with a DRM device continue using normal graphics detection. The rule
is applied automatically before the login manager starts.

The live boot probe checks SDDM and the actual live-user desktop directly. It
does not wait for unrelated `graphical.target` jobs, so offline time
synchronization cannot hide an already usable desktop from the boot check.

Both cases were reproduced with the checksum-verified Barracuda b501 ISO under
QEMU, including its VMware SVGA emulation. This does not establish the identical
failure on VMware Workstation; verification on that host remains separate.
A rebuilt ISO is required to include these startup changes.

## Included modules
- **Virtio (QEMU/KVM):** `virtio`, `virtio_pci`, `virtio_blk`, `virtio_scsi`, `virtio_net`, `virtio_console`, `virtio_balloon`
- **VMware:** `vmw_vsock_vmci_transport`
- **Hyper-V:** `hv_vmbus`, `hv_storvsc`, `hv_netvsc`, `hv_utils`
- **VirtualBox:** `vboxguest`, `vboxsf`, `vboxvideo`

## Configuration source
The modules are defined in `airootfs/etc/mkinitcpio.conf` and `airootfs/etc/modules-load.d/neos-vm.conf`. Update these files to add or remove drivers based on the intended VM target.

## VirtualBox mouse input

Use **USB Tablet** as the VM's pointing device (Settings → System → Motherboard),
and leave **Input → Mouse Integration** enabled in the running VM. The supplied
`profile/vm/neos.vbox` template already selects USB Tablet. Mouse Integration is
a host setting; NeOS cannot enable it from inside the guest. When it is disabled,
VirtualBox captures relative mouse input, so clicking inside the VM to capture
the pointer and using the Host key to release it is expected.

On X11, NeOS synchronizes tablet coordinates with the active display rotation.
If input remains misaligned, run `neos-display-sync --sync` in the live session.
If **Install NeOS** fails, the welcome window stays open for another attempt;
check `~/.cache/neos-installer.log` and `/var/log/Calamares.log` for details.
