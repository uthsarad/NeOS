# Validator report

STATUS: APPROVED

Reviewed the final live-boot graphics fallback, desktop readiness probe, SDDM primary-configuration correction and their regression coverage. No production-code blocking findings remain.

The VMware fallback is limited to actual VMs, excludes containers, requires the absence of any DRM card and a VMware VGA PCI device without a bound driver, waits for udev within a five-second bound, and rechecks both conditions. Its transient rule names the exact PCI address and still requires the device to be unbound when udev applies the rule. Existing DRM devices, bound drivers, other PCI vendors/classes, bare metal and containers retain normal detection. Root-owned runtime paths and refusal to write through symlinks keep the new writable service path scoped. Environment preferences remain intact.

The live probe now starts after SDDM and validates SDDM plus an active graphical live-user session and desktop process, independently of unrelated target-activation jobs. Its negative checks still reject failed SDDM, text consoles, inactive sessions and absent desktop processes. The expanded pending-target regression initially contained a standalone negated grep assertion; it now uses an explicit failure branch so errexit cannot silently skip that assertion.

The SDDM correction updates only existing managed primary keys in their proper INI sections. It preserves authentication/autologin identity, custom desktop choices, unrelated keys, ownership and permission mode; absent primary keys still inherit the generated drop-in. Duplicate managed keys agree, and repeat execution is idempotent. No CLI arguments, session names, override priorities or public API contracts changed.

Executed validation:

- `bash tests/verify_vm_graphics.sh`: passed targeted fallback, idempotence, normal-driver/no-op paths, nested-container exclusion, bounded busy/late-driver/late-DRM cases, preference preservation and symlink refusal.
- `bash tests/verify_desktop_readiness.sh`: passed seven successful/failed/pending-target cases after correcting the assertion.
- `bash tests/verify_boot_evidence.sh`, `bash tests/verify_session_select.sh`, `bash tests/verify_service_hardening.sh`, `bash tests/verify_live_graphical_target.sh` and `bash tests/verify_boot_gui.sh`: passed.
- Bash syntax validation and `git diff --check`: passed.
- Focused ShellCheck over all three modified runtime scripts and four affected shell regression gates: passed in the repository's configured development container.
- Selector tests ran under mawk 1.3.4; no nonportable AWK extensions were found.

The independently supplied runtime screenshot shows the Xfce live desktop and NeOS welcome window after the fallback. This review approves the narrowly reproduced startup correction; it does not establish identical kernel-driver failure or complete end-to-end behavior on native VMware Workstation. Rebuilt-image and native-host delivery checks remain separate obligations.
