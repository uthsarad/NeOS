# VM Startup Modules

[← Back to Documentation Index](../README.md#documentation)

NeOS ships a conservative set of modules to improve boot reliability in common VM environments. The list is included in the initramfs via `mkinitcpio.conf` for early boot and loaded via `modules-load.d` once the root filesystem is available.

## Included modules
- **Virtio (QEMU/KVM):** `virtio`, `virtio_pci`, `virtio_blk`, `virtio_scsi`, `virtio_net`, `virtio_console`, `virtio_balloon`
- **VMware:** `vmw_vsock_vmci_transport`
- **Hyper-V:** `hv_vmbus`, `hv_storvsc`, `hv_netvsc`, `hv_utils`
- **VirtualBox:** `vboxguest`, `vboxsf`, `vboxvideo`

## Configuration source
The modules are defined in `airootfs/etc/mkinitcpio.conf` and `airootfs/etc/modules-load.d/neos-vm.conf`. Update these files to add or remove drivers based on the intended VM target.
