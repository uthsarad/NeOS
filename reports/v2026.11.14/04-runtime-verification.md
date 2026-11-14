# Live desktop failure and verification

The reproduced failure is fixed in the repository and in a disposable guest using the corrected source files. No guest password was required. A newly rebuilt release ISO and native VMware Workstation remain unverified; the published Barracuda b501 artifact was not changed.

## Release and reproduction

- Release: `Barracuda-b501-testing`, source commit `c4ae859d405b67999a4770acac8f1fc928bb4a4d`.
- Downloaded ISO: `neos-Barracuda-Beta-testing-x86_64.iso`, 3,035,201,536 bytes. Its SHA512 matched the release checksum: `5acbeaf2817f01a8d22eee083150408d1fd267be271ea99d3e96f75379e237d2aa8f3926c0e086da00475f5d531e18bcdaa9e1bbeddc10ec00f1f5d55f17610a`.
- Inspected the actual SquashFS: liveuser is present, the current logo/dots splash is present, and the kernel is `6.18.63-2-lts`. The supplied recording shows an earlier kernel and a different boot menu; the user clarified that the current failure affects the live ISO, so testing used the exact named release.
- Ran QEMU TCG with standard VGA and VMware SVGA II, including real BIOS/ISO bootloader boots. A diagnostic copy changed only the boot command lines to enable a test-only root serial shell. It was not published.

## Graphics failure

With VMware SVGA II, the kernel rejected the adapter (`vmwgfx` reported an unsupported hypervisor/no pitchlock and returned error -38). No DRM card or framebuffer existed. Logind reported `CanGraphical=no`; SDDM stayed running at `Logind interface found` without starting Xorg. [Before screenshot](screenshots/vmware-before.png).

This is the emulated failure condition, not proof that native VMware Workstation produces the same kernel error. It demonstrates why choosing X11 and software rendering alone cannot handle a missing graphical seat.

For source verification, stopped SDDM, removed the experimental seat rule and cleared its device tags. Asserted `CanGraphical=no`, installed the current graphics helper/unit, session selector and boot probe/unit, then reloaded systemd and restarted the real graphics service under its normal sandbox. The service succeeded and generated the exact PCI-address, vendor, VGA-class and unbound-driver rule. Logind changed to `CanGraphical=yes`; SDDM started Xorg's VESA fallback and automatically logged in liveuser. The probe confirmed an active X11 session and a visible welcome window. [Machine-readable source validation](vmware-source-validation.json). All five guest source files matched the repository's [SHA256 hashes](vmware-source-hashes.json).

Used synthetic X11 mouse input to click the real Install NeOS button. A visible 1024x520 NeOS Installer window belonged to the actual Calamares process. [Interaction result](vmware-installer-validation.json) and [installer screenshot](screenshots/vmware-installer-after.png). USB tablet mapping was not retested. The VM had no installation disk and no usable network; no partition or installation operation was performed.

## Readiness failure

The unmodified release reached a usable desktop with standard VGA, but its boot probe stayed queued behind `graphical.target`. That target waited indefinitely for time synchronization through other boot jobs. Replacing only the probe script and unit made the real probe exit successfully and emit `NEOS-BOOT-OK live desktop ready`, while the unrelated target/time jobs remained pending. [Standard VGA result](std-probe-validation.json).

The corrected probe also succeeded in the VMware source-validation guest. Time synchronization, package initialization and signature verification were not changed.

## Source checks

Independent validator and tester reports approve the final source. All 12 focused gates pass, including the new VM fallback cases and full ShellCheck. Broad audit evidence plus dependency/Arch reruns establishes 67 passing gates. Actionlint remains unavailable (workflow static scan passed), and the two gates requiring a newly built ISO were not run against a fresh source build. See [tester report](02-tester-report.md) for exact coverage and logs.
