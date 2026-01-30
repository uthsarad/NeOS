# VM Startup Modules

[← Back to Documentation Index](../README.md#documentation)

NeOS ships a conservative set of modules to improve boot reliability in common VM environments. The list is loaded via `modules-load.d` during early boot and can be adjusted for a given platform or hypervisor.

## Included modules
- **Virtio (QEMU/KVM):** `virtio`, `virtio_pci`, `virtio_blk`, `virtio_scsi`, `virtio_net`, `virtio_console`, `virtio_balloon`
- **VMware:** `vmw_vsock_vmci_transport`
- **Hyper-V:** `hv_vmbus`, `hv_storvsc`, `hv_netvsc`, `hv_utils`
- **VirtualBox:** `vboxguest`, `vboxsf`, `vboxvideo`

## Configuration source
The modules are defined in `airootfs/etc/modules-load.d/neos-vm.conf`. Update this file to add or remove drivers based on the intended VM target.
