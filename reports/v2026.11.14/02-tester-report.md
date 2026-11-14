# Runtime verification report

STATUS: APPROVED for the tested source changes. Native VMware Workstation and a freshly rebuilt ISO remain unverified.

## Focused final checks

Executed the real shell helpers against isolated configuration/sysfs trees using `/workspace/neos-environment/run`. All 12 final focused gates passed: `verify_vm_graphics.sh`, `verify_session_select.sh`, `verify_desktop_readiness.sh`, `verify_boot_evidence.sh`, `verify_service_hardening.sh`, `verify_live_graphical_target.sh`, `verify_live_services.sh`, `verify_shellcheck.sh`, `verify_docs_links.sh`, `verify_version_stamp.sh`, `verify_manifest_drift.sh`, and `verify_security_autologin.sh`.

- The VM fallback covers an unbound VMware VGA device without DRM, exact-device runtime rule and trigger, idempotence, existing environment settings, normal DRM/driver paths, other devices, bare metal, nested containers, late DRM/driver initialization, busy udev, and symlink refusal.
- Session-selection checks cover hardware choices, explicit overrides, effective SDDM primary-configuration precedence, duplicate keys, section isolation, authentication preservation, custom sessions, original permissions and repeated boots.
- Desktop readiness rejects failed SDDM, TTY-only, inactive and missing-desktop cases; it accepts active X11/Wayland sessions while unrelated jobs still hold `graphical.target` inactive.
- Initial final ShellCheck caught SC2251 in the new pending-target assertion: standalone `! grep` did not enforce failure under errexit. The validator changed it to an explicit conditional with `exit 1`; both the desktop-readiness gate and CI-aligned full ShellCheck passed on rerun.

Logs: `/workspace/scratch/final-focused/`; the original result table retains the initial ShellCheck failure, and `rechecks.tsv` plus the replacement gate logs record its resolution. Earlier selector verification also passed boot GUI, SDDM theme and Qt headless render checks; SDDM, all six installer slides, and live/installed welcome layouts rendered cleanly. No UI layout was changed, so mobile/tablet website screenshots are inapplicable.

## Broader repository checks

The retained broad audit at `/workspace/scratch/final-audit/summary.json` contains 69 checks: 63 passed, two failed due to missing test tools, two incomplete, and two ISO-dependent skips. Subsequent retained runs resolve three of these:

- `verify_audit_tools.sh` and `verify_sourceforge_upload.sh` passed after jq and openssh-client were available in the disposable tools container; log: `/workspace/scratch/selector-verification/rechecked-audit-tools.log` (9 and 7 tests, respectively).
- The Arch-only `verify_install_repo.sh` ran with actual Arch tools and passed; log: `/workspace/scratch/selector-verification/arch-install-repo.log`. Its empty-package fixture deliberately produces a repo-add warning; this is not validation of the complete offline package closure.
- Adding the newly executed VM graphics gate gives 67 gates with passing evidence across the broad and follow-up runs. `verify_workflow_security.sh` has only its static scan because actionlint is unavailable. The two built-ISO gates were not executed against a new ISO in this task; they remain unrun.

The broad audit predates the last focused source edits; the 12 relevant gates were rerun after those edits rather than claiming a new full-suite run.

## Guest evidence and limits

Inspected retained runtime evidence from the checksum-verified Barracuda b501 release in QEMU. The standard-VGA guest had an active X11 live-user desktop while the old boot probe waited behind `systemd-time-wait-sync`; the revised probe exited successfully while those unrelated jobs remained pending (`/workspace/scratch/vm-repro/std-probe-validation.json`). An X11 XTest click opened a visible Calamares main window owned by the detected Calamares process (`std-xtest-installer-validation.json`); this synthetic-input check does not validate physical USB-tablet mapping.

The VMware SVGA emulation evidence shows vmwgfx rejecting the emulated adapter. Inspected the subsequent final-source validation in `reports/v2026.11.14/vmware-source-validation.json`: the manual seat tags were first cleared, returning the guest to `CanGraphical=no`; restarting the actual updated `neos-vm-graphics.service` under its systemd sandbox succeeded, installed the exact-device guarded runtime rule, and changed the seat to `CanGraphical=yes`. SDDM then started an active X11 desktop with a visible full welcome window. The updated boot-probe service also exited successfully while `graphical.target` remained inactive. This validates the final script and unit permissions, beyond the earlier manual-rule experiment.

Inspected `reports/v2026.11.14/vmware-installer-validation.json`: an X11 XTest click on **Install NeOS** opened a visible 1024×520 **NeOS Installer** main window owned by Calamares (PID 3751); the recorded result is PASS. The corresponding capture is `reports/v2026.11.14/screenshots/vmware-installer-after.png`. This is a synthetic X11 input check and does not establish physical USB-tablet mapping.

These guest checks used a patched running Barracuda b501 release under QEMU VMware SVGA emulation. A new ISO build and native VMware Workstation boot are still unverified; do not claim the user's exact live environment has been repaired before those delivery checks.
