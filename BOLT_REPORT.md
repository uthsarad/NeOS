# BOLT_REPORT

## ⚡ Optimization: Smart PCI Scanning in `neos-driver-manager`

### 💡 What
Modified `get_pci_devices` (formerly `get_all_pci_devices`) in `neos-driver-manager` to accept a `class_prefixes` filter.
- **Before:** The function always scanned *all* PCI devices in `/sys/bus/pci/devices`, opening `vendor`, `device`, and `class` files for every device (3 reads per device).
- **After:** The function now reads the `class` file first. If a filter is provided and the class doesn't match, it skips reading `vendor` and `device` files.
- **Caching:** Implemented a smart caching strategy where filtered scans do *not* populate the global cache (to prevent partial data), but *can* read from a pre-existing full cache.

### 🎯 Why
The `neos-driver-manager` runs during boot or installation. On modern systems, the PCI bus is populated with many devices (bridges, USB controllers, audio, storage, etc.) that are irrelevant to GPU or Network driver management.
Reading `vendor` and `device` files for every single device is redundant I/O overhead.
On a system with ~30 PCI devices, where we only care about 1 GPU and 1 Network card:
- **Old:** ~90 file opens.
- **New:** ~32 file opens (30 classes + 2 details).
**Reduction:** ~64% fewer syscalls for the PCI scan.

### 📊 Impact
- **I/O Reduction:** Directly reduces filesystem operations during hardware detection.
- **Scalability:** The benefit scales with the number of PCI devices on the system.
- **Safety:** Logic ensures that the global cache is never poisoned with partial results, maintaining correctness for subsequent calls.

### 🔬 Measurement
Verified using `tests/verify_pci_io.py`, which mocks the filesystem and asserts that `open()` is NOT called for `vendor`/`device` files of non-matching classes.
Passes existing regression tests in `tests/verify_pci_optimization.py`.
