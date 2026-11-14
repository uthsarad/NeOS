# Version and documentation changes

- Synchronized `VERSION`, the live and installed `os-release`, and the Go, Ruby and C# tool version stamps to `2026.11.14`.
- Added a dated changelog entry for the missing graphical-seat fallback, live boot-probe false negative and separately reproduced SDDM primary-configuration precedence defect.
- Documented automatic startup behavior for an unbound VMware VGA adapter without a DRM device, direct desktop readiness checks, and the supported Wayland/X11 override mechanism. The live desktop still starts without a password or manual guest commands.
- Updated the architecture brief to match the final live-ISO scope. Installed-system recovery tooling remains deferred.
- The runtime investigation reproduced SDDM waiting on `CanGraphical=no` with VMware SVGA emulation and showed that an exact-device seat rule starts Xorg's VESA fallback. A standard-VGA boot reached a full desktop while the old readiness probe waited behind unrelated time-synchronization work. These observations are from checksum-verified Barracuda b501 under QEMU; they do not establish the identical failure on native VMware Workstation.
- Validation after the expanded documentation update: `bash tests/verify_version_stamp.sh`, `bash tests/verify_docs_links.sh` and `git diff --check` passed. Candidate-guest rendering and installer interaction checks are owned by the runtime investigation and are not claimed here.
