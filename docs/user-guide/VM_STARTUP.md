# VM Startup Modules

[← Back to Documentation Index](../README.md#documentation)

NeOS ships a conservative set of modules to improve boot reliability in common VM environments. The list is included in the initramfs via `mkinitcpio.conf` for early boot and loaded via `modules-load.d` once the root filesystem is available, alongside filesystem modules for Btrfs and ZFS when configured.

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
