# VMware live desktop startup diagnosis

- Reproduce the clarified live-ISO problem with the checksum-verified Barracuda b501 release (`c4ae859`), using a disposable QEMU guest and test-only debug serial console. Keep native VMware Workstation verification separate from VMware SVGA emulation.
- Restore graphical-seat detection only for a detected VM's unbound VMware VGA adapter when no DRM card exists after bounded udev initialization. Generate an exact-device rule under `/run/udev/rules.d` so SDDM can start Xorg's VESA fallback; retain normal detection when the driver binds or a DRM card exists.
- Measure desktop readiness directly through SDDM, the active graphical live-user session and its desktop process. Do not depend on completion of unrelated `graphical.target` jobs; retain failure checks for a TTY, inactive session, failed SDDM and missing desktop process.
- Correct the separately reproduced SDDM precedence defect with section-aware updates to managed keys in `/etc/sddm.conf`. Preserve authentication, unrelated sections, custom desktop choices and supported Wayland/X11 overrides.
- Verify runtime behavior and independent code quality in parallel, including scoped no-op paths and configuration idempotence. Defer installed-system recovery tooling, require a rebuilt ISO for delivery, and record unexecuted native VMware checks explicitly.
