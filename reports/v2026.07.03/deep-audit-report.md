# NeOS Deep Audit Report — v2026.07.03

**Scope:** Full repository and build audit of the NeOS archiso profile, build scripts, airootfs overlay, Calamares installer configuration, CI workflow, tests, and tooling.
**Audit target:** The general desktop ISO as currently shipped (KDE Plasma 6 live installer, sub-2GB, Windows-migrant UX). This audit precedes a later "fit to project" tuning phase; no fixes are applied here.
**Method:** Findings were judged against the ArchWiki *Archiso* article (profile structure, users/passwords, systemd units, pacman hooks, boot loaders, build hygiene, QEMU testing) and the Ubuntu *LiveCDCustomization* community guide (image hygiene: host leakage, caches, machine-id, manifests, checksums/signing, boot-test matrix), translated to Arch equivalents. Every finding cites file:line evidence verifiable with grep.

---

## Severity summary

| Severity | Count | Headline |
|----------|-------|----------|
| Critical | 0 | — |
| High | 3 | Dormant kiosk installer path; weakened CI gates; secure-boot helper never shipped |
| Medium | 7 | Dead arch variants enforced by tooling; duplicated build logic; release/version decoupling; host-mutating build; duplicate liveuser creation; orphaned partition script; unsandboxed live service |
| Low | 6 | Dead workflow output; stale comments; branding drift; Qt5+Qt6 weight; snapshot hook race; fixed VM MAC |
| Info | 5 | Positive confirmations (see "Sound by design") |

---

## High

### H1. Dormant kiosk installer path — latent security regression
- **Evidence:** `profile/airootfs/etc/calamares/modules/liveuser-setup.conf`; `profile/airootfs/usr/local/bin/neos-install-identity:24-44`; `profile/airootfs/etc/calamares/settings.conf:27,40`
- **Problem:** The old kiosk-style installer module is orphaned but still present. `neos-install-identity` re-imposes a passwordless `liveuser`, SDDM empty-password login, and passwordless sudo **onto the installed disk** if its shellprocess instance is ever re-added to `settings.conf`. Both files' headers claim the Calamares `users` page was removed from the sequence — but `settings.conf:27,40` still uses it, so the comments describe a configuration that does not exist. `tests/verify_security_autologin.sh:35` guards against re-enabling, but the guard is weaker than deletion.
- **Guide basis:** ArchWiki users/passwords — empty password fields are acceptable only in the live environment, never on installed systems.
- **Recommendation:** Delete `liveuser-setup.conf`, `neos-install-identity`, and the contradictory comments; keep the regression test.

### H2. Weakened CI quality gates
- **Evidence:** `.github/workflows/build-iso.yml:53` (all `*iso*` tests skipped in the test job), `:59-61` (`verify_mkinitcpio.sh` and `verify_qml_enhancements.sh` run under `timeout 60s ... || true`)
- **Problem:** Two verification scripts can never fail the build, and every ISO-related test is excluded from the test job. Failures in mkinitcpio config or QML would merge silently.
- **Guide basis:** Ubuntu QA protocol — validation must be able to fail the pipeline.
- **Recommendation:** Remove `|| true`; if the scripts are flaky in the CI container, fix or skip them explicitly with a tracked reason. Run ISO-dependent tests in the build job after the ISO exists (some already run there — make coverage explicit).

### H3. `neos-secureboot-setup` never reaches the installed system
- **Evidence:** `profile/airootfs/usr/local/bin/neos-secureboot-setup` (header: "run on the installed system"); absent from `profile/airootfs/etc/calamares/neos-overlay.txt` (grep-verified)
- **Problem:** README advertises "user-initiated Secure Boot helpers", and `sbctl`/`mokutil` ship in `packages.x86_64:143-144`, but the helper script itself is only on the live ISO — the installed system gets the tools without the guided workflow.
- **Recommendation:** Add `usr/local/bin/neos-secureboot-setup` to `neos-overlay.txt`, or change its docs to live-only.

## Medium

### M1. Dead i686/aarch64 variants enforced by the audit tool
- **Evidence:** `profile/profiledef.sh:13` (`arch="x86_64"` only); `profile/packages.i686`, `profile/packages.aarch64`, `bootstrap_packages.{i686,aarch64}`; `tools/neos-profile-audit/src/main.rs:8,17-24,313-320`
- **Problem:** Arch dropped i686 in 2017; neither variant is ever built, yet the Rust audit *requires* both files to exist with ≥45 packages and forces a shared package set into them. Mandated maintenance of dead code; the lists already drift (i686 uses kernel `linux`, x86_64 uses `linux-lts`).
- **Recommendation:** Delete the i686 files outright; keep aarch64 only if a port is planned, otherwise delete. Update `main.rs` `PACKAGE_FILES`/`assert_arch_specific_expectations` accordingly.

### M2. Duplicated mirrorlist-injection logic (build.sh vs CI)
- **Evidence:** `build.sh:137-153` vs `.github/workflows/build-iso.yml:146-172`
- **Problem:** CI does not call `build.sh`; it re-implements pacman-build.conf generation. Two copies of security-relevant logic will drift.
- **Recommendation:** Make CI invoke `build.sh` (parameterize the interactive `work/` prompt via the existing `CI` check) or extract the shared logic to one sourced script.

### M3. Release tags decoupled from VERSION/CHANGELOG
- **Evidence:** `.github/workflows/build-iso.yml:339` (`V${{ github.run_number }}`)
- **Problem:** GitHub releases are tagged by CI run number; `VERSION` (date-based) and `CHANGELOG.md` entries never appear in the tag. Users cannot map a release to a changelog entry.
- **Recommendation:** Tag from `VERSION` (e.g. `v$(cat VERSION)` + run number suffix for rebuilds) and inject the matching CHANGELOG section as the release body (see L1).

### M4. Host-mutating, non-hermetic local build
- **Evidence:** `build.sh:81` (`pacman -Sy --noconfirm archlinux-keyring` on the host), `:87-109` (host keyring imports/lsigns)
- **Problem:** Building the ISO mutates the operator's system keyring and partially syncs pacman databases (`-Sy` without `-u` risks partial-upgrade state on the host).
- **Guide basis:** Ubuntu chroot-hygiene principle — build steps should not leak into the host.
- **Recommendation:** Document the mutation prominently, or move the build into a container/systemd-nspawn the way CI already does.

### M5. Duplicate liveuser creation with drifted attributes
- **Evidence:** `profile/airootfs/root/customize_airootfs.sh:23` (`useradd -m -u 1000 -g users -s /usr/bin/zsh` + 11 groups) vs `profile/airootfs/usr/local/bin/neos-liveuser-setup:23` (`-g users -G wheel,video,audio,storage,power -s /bin/zsh`)
- **Problem:** Two creation paths with different shells and group sets. Build-time wins (runtime is guarded by `id`), so the runtime branch is dead yet looks authoritative.
- **Recommendation:** Reduce `neos-liveuser-setup` to its runtime-only duties (sudoers drop-in, VM graphics) and delete its user-creation branch, or align attributes exactly.

### M6. Orphaned `neos-installer-partition.sh` with contradictory subvolume scheme
- **Evidence:** script referenced only by `build.sh:222` (exclusion) and tests; subvols `@ @home @var @snapshots` (`:141-144`) vs active `etc/calamares/modules/mount.conf:40-50` (`@ @home @cache @log @.snapshots`); writes `/run/neos-partition-progress` that nothing reads
- **Problem:** Dead code that documents a partition layout NeOS does not install — a trap for future contributors (note `@snapshots` vs `@.snapshots`).
- **Recommendation:** Delete the script and its test, or rewrite it to match `mount.conf` if it has a planned use.

### M7. Deliberately unsandboxed live service — comment-guarded only
- **Evidence:** `profile/airootfs/etc/systemd/system/neos-liveuser-setup.service:11-16`
- **Problem:** Sandboxing was removed because an upstream merge (bc64daa) re-adding `ProtectSystem=strict`/`NoNewPrivileges` broke live boot. Only a comment prevents recurrence.
- **Recommendation:** Add a test asserting the unit contains no sandboxing directives (mirror of `verify_service_hardening.sh` logic, inverted for this unit).

## Low

### L1. Dead release-body reference
- **Evidence:** `.github/workflows/build-iso.yml:348` (`body: ${{ steps.iso.outputs.body || '' }}`); the `iso` step (`:306-327`) never writes `body` to `$GITHUB_OUTPUT`
- **Recommendation:** Either populate it (CHANGELOG extract — pairs with M3) or drop the expression.

### L2. Stale/misleading pacman.conf comment
- **Evidence:** `profile/pacman.conf:5` claims installed systems "must override to DatabaseRequired"; `profile/airootfs/etc/pacman.conf:5-10` deliberately keeps `DatabaseOptional`, and `tools/neos-profile-audit/src/main.rs:124-126` *requires* `DatabaseOptional`
- **Recommendation:** Fix the comment to match the deliberate decision.

### L3. `LocalFileSigLevel = Optional`
- **Evidence:** `profile/pacman.conf:7`; `profile/airootfs/etc/pacman.conf:10`
- **Note:** Matches Arch stock default, but a hardened distro can require signatures for local installs. Deliberate-choice territory; document or tighten.

### L4. Branding/publisher drift
- **Evidence:** `profile/profiledef.sh:7` (publisher `github.com/uthsarad`) vs `os-release`/`branding.desc` (`github.com/NimuthuGanegoda/NeOS`); `branding.desc:19` static `productVersion 2026.07` vs date-based `iso_version`; GRUB `timeout=0` vs syslinux `TIMEOUT 5` (0.5 s)
- **Recommendation:** Single source of truth for URLs/version strings; align boot timeouts or note the syslinux `TIMEOUT 0`=forever constraint (already commented in `archiso_head.cfg`).

### L5. Pacman post-snapshot hook pairing race
- **Evidence:** `profile/airootfs/usr/share/neos/hooks/99-neos-snapshot-post.hook:11` — derives `PRE_NUMBER` as "latest snapshot of any type"
- **Problem:** Under concurrent snapper activity (timeline snapshot, autoupdate pre/post), the post snapshot can link to the wrong pre. Harmless for restore correctness, confusing for snapshot browsing.
- **Recommendation:** Match on the specific pre-snapshot description written by the pre hook.

### L6. Fixed MAC in VM template
- **Evidence:** `profile/vm/neos.vbox:26` (`MACAddress="080027ADDEBE"`)
- **Problem:** Every generated VirtualBox appliance shares the MAC unless regenerated; two NeOS VMs on one LAN segment collide.
- **Recommendation:** Randomize the MAC in `tools/gen-vm-appliance.sh` alongside the UUID rewrite.

### L7. Latent broken branding QML
- **Evidence:** `profile/airootfs/etc/calamares/branding/neos/neos-restore-module.qml:11` — uses a `Process {}` QML type with only `import QtQuick 2.15`; no import provides `Process`
- **Problem:** Errors immediately if ever wired into Calamares. Currently unreferenced. (Related: `verify_qml_enhancements.sh` is one of the `|| true` gates in H2.)
- **Recommendation:** Delete or fix before wiring.

## Compliance matrix

### ArchWiki Archiso checklist

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `profiledef.sh` valid modes/bootmodes | PASS | BIOS syslinux + UEFI GRUB (ia32+x64), `profiledef.sh:12` |
| `file_permissions` covers custom scripts, `/root` 0750 | PASS | `profiledef.sh:25-40` |
| `/etc/shadow`/`gshadow` perms entries | N/A | No custom passwd/shadow shipped; users baked via `customize_airootfs.sh` |
| Package list: 1/line, no dupes | PASS | 123 packages, dupes checked; Rust audit also enforces charset+dupes |
| Custom repo keys via signed keyring | PASS | chaotic-keyring downloaded + signature-verified, `build.sh:111-130` |
| systemd units via literal symlinks | PASS | `etc/systemd/system/*.target.wants/` populated correctly |
| Setup hooks marked `# remove from airootfs!` | PASS (n/a pattern) | Snapshot hooks under `usr/share/neos/hooks` are intentional runtime hooks, not build-time |
| mkinitcpio fallback suppressed | CHECK | Not verified this pass — confirm no fallback initramfs is built (size lever) |
| `cow_spacesize` set | PASS | `cow_spacesize=4G` in GRUB and syslinux kernel lines |
| Secure Boot signed path | PARTIAL | Tools shipped; helper live-only (H3); no shim-signing pipeline |
| Workdir hygiene (`-r`, findmnt warning) | PARTIAL | `build.sh` prompts/`rm -rf`s `work/` without a findmnt bind-mount check |
| QEMU test (`run_archiso`) | PARTIAL | CI installs qemu and runs smoketest scripts; no interactive boot matrix |

### Ubuntu image-hygiene checklist (Arch-translated)

| Criterion | Status | Evidence |
|-----------|--------|----------|
| machine-id empty | PASS | `etc/machine-id` empty; `systemd-firstboot` masked |
| No shell histories / tmp residue in overlay | PASS | none found in airootfs |
| No build-time repo leakage into image | PASS | build `pacman-build.conf` generated outside profile; live image has own `etc/pacman.conf` |
| Package cache cleaned | PASS (delegated) | mkarchiso handles airootfs cache cleanup |
| Manifests generated | PASS | `neos-packages.txt` + `neos-overlay.txt` generated per build (`build.sh:165-226`) — but exclusion regex list is fragile |
| Checksums / GPG signing of ISO | FAIL | CI uploads ISO without checksums or signature files |
| Boot-test matrix (BIOS/UEFI/SB + install test) | PARTIAL | Smoke tests only; no Secure Boot or full Calamares install test in CI |

## Sound by design (positive confirmations)

- **No `SigLevel Never`/`TrustAll` anywhere**; global `Required DatabaseOptional` with correct rationale.
- **Live-only credential posture correctly contained:** passwordless liveuser, `zz-live-wheel` NOPASSWD, SDDM AllowEmptyPassword+autologin all excluded from the installed system via `neos-overlay.txt`; installed sudoers requires password (`etc/sudoers.d/wheel`).
- **sshd hardened and not enabled** (`PermitEmptyPasswords no`, `PermitRootLogin no`).
- **UFW enabled** live and installed; **sysctl hardening** (`90-neos-security.conf`) thorough, no conflict with the performance drop-in.
- **Chaotic keyring signature-verified before use** in both build.sh and CI.
- **Plymouth cat theme complete:** 32 frames present, `neos.script:15` `n_frames=32` matches.
- **`neos-autoupdate.timer` not enabled on the live ISO** — installed-system only via `services-systemd.conf:9`.

## Verified-false leads (do not rediscover)

- `softprops/action-gh-release@v3` **does exist** upstream (tags `v3`, `v3.0.0`, `v3.0.1` confirmed via GitHub API on 2026-07-03). The workflow reference at `build-iso.yml:342` is valid.
- Empty `etc/machine-id` is correct for images, not a defect.
- Four parallel VM guest stacks (vbox/vmware/qemu/spice) are an intentional breadth decision, not accidental duplication.

## Fix backlog (effort × impact order)

| # | Fix | Finding | Effort | Status |
|---|-----|---------|--------|--------|
| 1 | Delete kiosk installer remnants (`liveuser-setup.conf`, `neos-install-identity`) | H1 | S | ✅ applied |
| 2 | Ship `neos-secureboot-setup` in the overlay manifest | H3 | S | ✅ applied (via regenerated manifest) |
| 3 | Remove `\|\| true` from CI test gates; make ISO-test coverage explicit | H2 | S | ✅ applied |
| 4 | Fix stale pacman.conf comment; drop dead `outputs.body` / populate from CHANGELOG | L1, L2 | S | ✅ applied (`body_path` from CHANGELOG) |
| 5 | Delete i686 + aarch64 package files + relax Rust audit | M1 | M | ✅ applied (both deleted) |
| 6 | Tag releases from `VERSION`; changelog as release body | M3 | M | ✅ applied (`v<VERSION>-b<run>`) |
| 7 | Deduplicate build-conf/manifest logic between build.sh and CI | M2 | M | ✅ applied (`tools/gen-build-conf.sh`, `tools/gen-manifests.sh`) |
| 8 | Remove dead liveuser-creation branch from `neos-liveuser-setup` | M5 | S | ✅ applied (fails loudly if build-time user missing) |
| 9 | Delete or rewrite `neos-installer-partition.sh` | M6 | S | ✅ applied (deleted, incl. test) |
| 10 | Add no-sandbox regression test for `neos-liveuser-setup.service` | M7 | S | ✅ applied (in `verify_service_hardening.sh`) |
| 11 | Ship ISO checksums (+ optional GPG signature) from CI | hygiene FAIL | M | ✅ SHA256SUMS shipped; GPG signing still open |
| 12 | Randomize VM template MAC; align branding URLs/versions | L4, L6 | S | ✅ applied (MAC + publisher URL; productVersion left static) |
| 13 | Containerize or document host-mutating build steps | M4 | M/L | ✅ documented in build.sh; containerization still open |
| 14 | Verify/suppress mkinitcpio fallback image | matrix CHECK | S | ✅ applied (`etc/mkinitcpio.d/linux-lts.preset`, live-only) |

## Remediation addendum (same day)

All 14 backlog items were applied (see table). During remediation one **new High finding** surfaced and was fixed:

- **CI shipped stale netinstall manifests.** The workflow never ran build.sh's manifest generation, so CI-built ISOs carried the committed `neos-overlay.txt`/`neos-packages.txt` from an old commit — systems installed from CI ISOs silently missed every overlay file added since (the secure-boot helper, snapshot pacman hooks, Plymouth logo, and more). Fixed by extracting generation into `tools/gen-manifests.sh`, calling it from both build.sh and a new CI step, and refreshing the committed copies.
- The regenerated manifest also exposed that `root/customize_airootfs.sh` would have entered the manifest — a file mkarchiso deletes from the finished ISO, so the Calamares overlay rsync (`--files-from`) would have failed the install. `root/*`, `pacman-init.service`, `etc-pacman.d-gnupg.mount`, and `etc/mkinitcpio.d/` are now explicitly excluded as live-only.

Verification: shellcheck clean over all shell scripts; workflow YAML parses; full non-ISO test suite passes (`tests/verify_*.sh`, 28 scripts). The Rust profile audit and ISO-dependent tests run in CI (no cargo/mkarchiso on this host).

Still open (deliberate): GPG-signing of release artifacts, containerizing the local build, full boot-test matrix (BIOS/UEFI/Secure Boot + Calamares install test) in CI.
