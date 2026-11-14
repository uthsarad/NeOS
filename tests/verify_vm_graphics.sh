#!/bin/bash
# Run the real VM graphics setup against isolated sysfs and runtime trees.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import configparser
import json
import os
from pathlib import Path
import stat
import subprocess
import tempfile

script = Path("profile/airootfs/usr/local/bin/neos-vm-graphics").resolve()
unit = configparser.ConfigParser(interpolation=None)
unit.read("profile/airootfs/etc/systemd/system/neos-vm-graphics.service")
assert unit["Unit"]["ConditionVirtualization"] == "vm"
assert {"systemd-udevd.service", "systemd-modules-load.service"} <= set(unit["Unit"]["After"].split())
assert {"display-manager.service", "sddm.service"} <= set(unit["Unit"]["Before"].split())
assert "/run/udev" in unit["Service"]["ReadWritePaths"].split()
assert unit["Service"]["ProtectSystem"] == "strict"

with tempfile.TemporaryDirectory(prefix="neos-vm-graphics-") as temporary:
    scratch = Path(temporary)
    virt = scratch / "detect-virt"
    virt.write_text('''#!/bin/sh
case "$*" in
    "--vm -q") [ "$TEST_VM_KIND" = vm ] || [ "$TEST_VM_KIND" = container ] ;;
    "--container -q") [ "$TEST_VM_KIND" = container ] ;;
    *) exit 2 ;;
esac
''')
    virt.chmod(0o755)
    udev = scratch / "udevadm"
    udev.write_text('''#!/usr/bin/env python3
import json
import os
from pathlib import Path
import sys

root = Path(os.environ["NEOS_VM_GRAPHICS_ROOT"])
sysfs = Path(os.environ["NEOS_VM_GRAPHICS_SYSFS"])
with (root / "udev-calls.jsonl").open("a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
if sys.argv[1:] == ["settle", "--timeout=5"]:
    first = not (root / "settled").exists()
    (root / "settled").touch()
    mode = os.environ.get("TEST_UDEV_MODE", "")
    if mode == "busy":
        sys.exit(1)
    if first and mode == "late-drm":
        (sysfs / "class/drm/card0").mkdir()
    if first and mode == "late-driver":
        (sysfs / "bus/pci/devices/0000:00:02.0/driver").mkdir()
''')
    udev.chmod(0o755)

    def fixture(name, *, vm="vm", vendor="0x15ad", pci_class="0x030000", drm=False, bound=False, mode=""):
        root = scratch / name
        sysfs = root / "sys"
        for directory in (root / "etc", root / "run/udev", sysfs / "class/drm", sysfs / "bus/pci/devices"):
            directory.mkdir(parents=True)
        (root / "etc/environment").write_text("LANG=C.UTF-8\n")
        device = sysfs / "bus/pci/devices/0000:00:02.0"
        device.mkdir()
        (device / "vendor").write_text(vendor + "\n")
        (device / "class").write_text(pci_class + "\n")
        if drm:
            (sysfs / "class/drm/card0").mkdir()
        if bound:
            driver = sysfs / "drivers/vmwgfx"
            driver.mkdir(parents=True)
            (device / "driver").symlink_to(driver, target_is_directory=True)
        environment = dict(os.environ, NEOS_VM_GRAPHICS_ROOT=str(root),
                           NEOS_VM_GRAPHICS_SYSFS=str(sysfs), NEOS_VM_GRAPHICS_VIRT=str(virt),
                           NEOS_VM_GRAPHICS_UDEVADM=str(udev), TEST_VM_KIND=vm, TEST_UDEV_MODE=mode)
        return root, device, environment

    def run(environment, *, success=True):
        result = subprocess.run(["bash", str(script)], env=environment, text=True, capture_output=True)
        assert (result.returncode == 0) == success, result.stdout + result.stderr
        return result

    def calls(root):
        path = root / "udev-calls.jsonl"
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def rule(root):
        return root / "run/udev/rules.d/70-neos-vm-seat.rules"

    root, device, environment = fixture("unbound-vmware")
    run(environment)
    expected = ('SUBSYSTEM=="pci", KERNEL=="0000:00:02.0", ATTR{vendor}=="0x15ad", '
                'ATTR{class}=="0x030000", DRIVER=="", TAG+="seat", TAG+="master-of-seat"')
    assert expected in rule(root).read_text()
    assert calls(root) == [["settle", "--timeout=5"], ["control", "--reload-rules"],
                           ["trigger", "--action=change", str(device)], ["settle", "--timeout=5"]]
    assert stat.S_IMODE(rule(root).stat().st_mode) == 0o644
    assert stat.S_IMODE(rule(root).parent.stat().st_mode) == 0o755
    before = rule(root).read_bytes(), rule(root).stat().st_mtime_ns
    run(environment)
    assert (rule(root).read_bytes(), rule(root).stat().st_mtime_ns) == before
    assert (root / "etc/environment").read_text().count("LIBGL_ALWAYS_SOFTWARE=1") == 1
    assert list(rule(root).parent.iterdir()) == [rule(root)]
    print("[PASS] unbound VMware VGA gets a guarded runtime seat rule and targeted trigger; repeated runs are idempotent")

    for name, options in (("drm-present", {"drm": True}), ("driver-bound", {"bound": True}),
                          ("other-vendor", {"vendor": "0x1234"}), ("not-vga", {"pci_class": "0x020000"})):
        root, _, environment = fixture(name, **options)
        run(environment)
        assert not rule(root).exists() and not calls(root), name
        assert "LIBGL_ALWAYS_SOFTWARE=1" in (root / "etc/environment").read_text()
        print(f"[PASS] {name}: software rendering remains available without a seat override")

    for kind in ("bare-metal", "container"):
        root, _, environment = fixture(kind, vm=kind)
        run(environment)
        assert (root / "etc/environment").read_text() == "LANG=C.UTF-8\n"
        assert not rule(root).exists() and not calls(root)
        print(f"[PASS] {kind}: no configuration changes or udev commands")

    for mode in ("late-drm", "late-driver", "busy"):
        root, _, environment = fixture(mode, mode=mode)
        result = run(environment)
        assert not rule(root).exists()
        assert calls(root) == [["settle", "--timeout=5"]]
        if mode == "busy":
            assert "udev did not settle" in result.stderr
        print(f"[PASS] {mode}: recheck after bounded settling prevents an unsafe seat override")

    root, _, environment = fixture("preserve-environment")
    (root / "etc/environment").write_text("LIBGL_ALWAYS_SOFTWARE=0\nCUSTOM=value\n")
    run(environment)
    assert (root / "etc/environment").read_text() == "LIBGL_ALWAYS_SOFTWARE=0\nCUSTOM=value\n"
    print("[PASS] existing rendering preferences and unrelated environment are preserved")

    for name, location in (("symlink-environment", "etc/environment"),
                           ("symlink-rule", "run/udev/rules.d/70-neos-vm-seat.rules"),
                           ("symlink-rule-directory", "run/udev/rules.d")):
        root, _, environment = fixture(name)
        destination = root / location
        destination.parent.mkdir(parents=True, exist_ok=True)
        outside = root / "outside"
        if name == "symlink-rule-directory":
            outside.mkdir()
        else:
            outside.write_text("unchanged\n")
        destination.unlink(missing_ok=True)
        destination.symlink_to(outside, target_is_directory=outside.is_dir())
        result = run(environment, success=False)
        assert "refusing to write through symlink" in result.stderr
        assert not list(outside.iterdir()) if outside.is_dir() else outside.read_text() == "unchanged\n"
        assert all(command[0] == "settle" for command in calls(root))
        print(f"[PASS] {name}: refuses writes through a symlink")

print("[PASS] VM graphics fallback verified")
PY
