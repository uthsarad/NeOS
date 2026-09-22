# Changelog

All notable changes to this project will be documented in this file.

## [2026.09.22] - 2026-09-22

This entry covers the two commits that landed after the 2026.09.18 metadata sync
(`523a269`, `4fab136` — neither had a CHANGELOG entry) plus the follow-up work in
`reports/v2026.09.22/UPDATES_NEEDED.md`. That report is the authoritative list of what
was found; the items below are what changed. Open items are listed at the end.

### Changed
- **Install/print memory spikes trimmed** (`523a269`, previously undocumented): printing is now socket/path-activated (`cups.socket` + `cups.path` enabled instead of `cups.service`, so `cupsd` starts and holds RAM only on first print), the live session disables Discover's update notifier and Baloo indexing through per-user overrides in `neos-liveuser-setup` (installed systems keep both defaults), and the derived install manifest dropped the extra packages it had been re-declaring — the desktop suite (`firefox`, `discover`, `cups`, `fwupd`, `flatpak`, `dkms`, `linux-lts-headers`, `packagekit-qt6`, `broadcom-wl-dkms`) is inherited from `profile/packages.x86_64` instead, with `nvidia-open-lts` (prebuilt, for `linux-lts`) replacing the `nvidia-open-dkms` entry. That closes the 2026.09.18 audit's M1 duplication; `tests/verify_pacstrap.sh` now rejects duplicates outright.
- **ISO size limit retired in the release path** (`4fab136`, previously undocumented): `tests/verify_iso_size.sh` is gone and the CI size step with it — the ISO is published via SourceForge, which has no per-asset limit, and the 2 GiB budget no longer described reality. `README.md`, `profile/profiledef.sh`, `docs/decisions/0006-…` and `docs/architecture/PERFORMANCE.md` now describe size as a design target (download time, USB writing, live-session RAM), and the 2026.09.18 audit report carries a banner marking H1/M5/O1 as superseded-by-removal rather than resolved-by-enforcement.
- **CI and local builds now share one entrypoint** (2026.09.18 C2/O2): `build.sh` gained `--ci` and `--no-offline-repo`, and `build-iso.yml` calls `bash build.sh --ci --no-offline-repo` instead of re-implementing the build inline. The offline install repo (and its xorriso step) is explicitly a local-build feature; published ISOs install from the network, as the README already said. The duplicated "Validate ISO" step is gone because `build.sh` runs those gates itself.
- **`build.sh` is non-interactive-safe** (M8): the work-directory prompt is skipped when stdin is not a TTY (a bare `read` at EOF aborted the build through the `ERR` trap), `--ci` always clears a stale `work/`, and a partially written `*-with-repo.iso` is removed on exit/failure instead of being left for the next first-glob consumer to pick up (M5).
- **CI gates can no longer pass by skipping** (H3/O3): the `test` job installs `ruby`, `go`, `dotnet-sdk` and `pacman-contrib` and exports `REQUIRE_TOOLS=1`, so `verify_ruby_tasks.sh`, `verify_go_neosctl.sh` and `verify_csharp_diagnostics.sh` fail rather than degrading to static greps when a toolchain is missing; `verify_rust_profile_audit.sh` additionally runs `cargo test`; the .NET gate rolls forward across majors (`DOTNET_ROLL_FORWARD=Major`) so a newer SDK does not mask a real failure. Toolchain tests get a 420s budget instead of 120s.
- **Pull requests now run the gate suite and the ISO build**: `build-iso.yml` gained a `pull_request` trigger for `testing`/`main`. The `test` job previously ran only on pushes to `testing` and on manual dispatch, so the gates it enforces could not gate a change before it landed. The `build` job runs on PRs too, because publishing is already impossible from one — every release step is gated on `github.ref` being `refs/heads/{main,testing}`, and on a pull request that ref is `refs/pull/<n>/merge`. That is what lets a PR prove the image builds before it reaches `testing`; the first merge that ran the pipeline found a build failure instead (see "Fixed" below).
- **Third-party actions pinned to commit SHAs** (M4), resolved from the upstream tags through the GitHub API (not transcribed): `actions/checkout@fbc6f399…` (v5), `softprops/action-gh-release@efb35369…` (v3), `actions/labeler@b8dd2d9b…` (v6), `actions/ai-inference@a7805884…` (v2). Dependabot now keeps those pins current and its header explains the change.
- **`jules-auto-merge` lost its `--admin` fallback** (M3): a PR that cannot merge under branch protection or failing checks is left for a human, with an explanatory comment on the PR, instead of bypassing required checks.
- **Version sources synchronised**: `VERSION`, `tools/neosctl`, `tools/NeosDiagnostics` and `tools/neos_tasks.rb` all move to 2026.09.22. `neos-welcome-app` no longer hardcodes a version string (`'v2026.09'`, stale the moment it shipped) but derives it from the running system's `/etc/os-release`. Calamares' `productVersion`/`versionedName` no longer assert `2026.07`; they now carry the `Beta` release-channel label. Nothing yet stamps `VERSION` into the image — see the open items.

### Fixed
- **Shipped support URLs pointed at a fork whose Issues are disabled** (UPDATES_NEEDED §3): `/etc/os-release` (`SUPPORT_URL`, `BUG_REPORT_URL`, `HOME_URL`, `DOCUMENTATION_URL`), the Calamares branding (`supportUrl`, `knownIssuesUrl`, `productUrl`, `releaseNotesUrl`) and `iso_publisher` now name the canonical `uthsarad/NeOS`, matching the README and HANDBOOK. Every bug-report link inside an installed system previously led nowhere.
- **Boot verification is real, not decorative** (H4): the live ISO boots with `console=tty0 console=ttyS0,115200` on all six BIOS/UEFI entries, and ships `neos-boot-probe.service`, which runs only once `graphical.target` is active and writes a marker to `/dev/ttyS0`. `tests/verify_iso_smoketest.sh` was rewritten: it no longer treats a QEMU timeout (124/137) as a pass — it requires the marker within `BOOT_TIMEOUT` (default 300s), fails on panic/emergency/mount errors, and corroborates the result with a QMP screendump whose framebuffer must not be blank (distinct-colour and brightness analysis, no image libraries). KVM is used when available. The probe is excluded from the installed-system overlay manifest.
- **`tools/gen-install-repo.sh` accounting runs on every invocation**: the cached/missing calculation sat inside the download branch, so `--skip-download` could not exercise it and nothing in automation ever ran the script (the C1 regression class was only reachable from a real `sudo ./build.sh`). It now runs unconditionally and reports `--skip-download` explicitly.
- **Documentation drift**: the HANDBOOK no longer claims Calamares starts automatically (the welcome app does; Install launches Calamares) and every `airootfs/`, `grub/`, `packages.x86_64` reference is correctly rooted under `profile/`, including the wallpaper path; `docs/architecture/BOOTSTRAP.md` no longer claims `bootstrap_packages.x86_64` is consulted (nothing reads it — `buildmodes=('iso')` only); `docs/TROUBLESHOOTING.md` no longer warns about a `DatabaseRequired` setting the profile deliberately does not use.
- **`docs/README.md` restored as the documentation index**: five documents linked to `../README.md#documentation`, which resolved to a file that did not exist.
- **`CLAUDE.md` pointed at eight documents that were never committed** (`docs/orchestrator/*`, `docs/policies/DOMAIN_PACK_SPEC.md`, `docs/AGENT_MODEL_SELECTION.md`) plus a `skills/` tree; the references now point at files this repository actually contains, and state that skills/agents live in the orchestrator runtime.
- **Stale `reports/v2026.09.11/` claim made true**: the 2026.09.11 CHANGELOG said the root-level agent reports were moved into `reports/v2026.09.11/`, but the report directory did not exist on `testing` while the files sat at the repository root asserting a "Strategic Pause — do not write production code" that the project had long since ignored. The nine reports now live under `reports/v2026.09.11/` (taken from the commit where they were relocated) and the root duplicates are gone; `jules-auto-merge.yml` and `tools/neosctl` reference the real paths.

### Added
- **`tests/verify_iso_smoketest.sh` graphical-boot gate** (H4 — described under Fixed) and **`tests/verify_boot_evidence.sh`**: fails if the probe unit, its enablement symlink, the marker contract, the serial-console boot parameters or the overlay exclusion drift apart again.
- **`tests/verify_install_repo.sh`**: runs the offline-repo generator in a scratch directory with a planted cached package and a stale package, asserting the cached/missing accounting, the cleanup pass and a zero exit status — the first automated execution of that script (Arch-only, skips elsewhere).
- **`tests/verify_repo_urls.sh`**: shipped `os-release`/branding/publisher URLs must name the canonical repository and must not name the fork.
- **`tests/verify_docs_links.sh`**: every relative link in every tracked markdown file must resolve.
- **Manifest duplicate check and installer-job dedup**: `tests/verify_pacstrap.sh` now rejects duplicate entries inside `neos-packages.txt` and `profile/packages.x86_64` (the derived manifest was never checked at all). The `neospacstrap` Calamares job existed as two byte-identical hand-maintained copies — Calamares searches `/usr/lib/calamares/modules` before `/etc/calamares/modules`, so a fix applied to the first copy would silently not be the one that ran. The module now lives once in `/usr/lib` (the copy `profiledef.sh` grants `0:0:755`), with the `/etc` entries demoted to relative symlinks; the test fails if a divergent second copy reappears.
- `profile/install-repo/` is gitignored — the offline repo is build scratch and was previously left untracked-but-visible inside the tree on failure.

### Fixed (found by the first CI run that executed `build.sh`)
- **`build.sh` aborted at the end of every successful build** — `yes "" | mkarchiso` under `set -o pipefail`: when mkarchiso exits it stops reading, `yes` dies of SIGPIPE (141), and the pipeline's status became the script's. The `ERR` trap then failed the build moments after mkarchiso had finished. The pre-unification CI build worked around this with `set +e +o pipefail` + `${PIPESTATUS[1]}`; `build.sh` never had that, and nobody noticed because CI was not running the script at all. This is the first defect surfaced *by* the C2 unification — the tested artefact and the developer artefact are the same file now, so a bug in it is visible.
- **Smoke-test timeout now scales with the accelerator**: `BOOT_TIMEOUT` defaults to 300s with KVM but 900s without it, because CI runners fall back to QEMU's TCG interpreter, where a full Plasma live boot takes several times longer. The 300s assumption (and the comment claiming GitHub runners expose `/dev/kvm`) would have reported a slow-but-healthy boot as a dead one.
### Open items (unchanged, deliberately not decided here)
- **Display version** (M10): `VERSION` is the single release version, but nothing reads it at build time — `/etc/os-release` carries no `VERSION_ID` (upstream behaviour, unchanged) and the Calamares branding carries a channel label, so `neos-welcome-app` falls back to `PRETTY_NAME` and shows "NeOS" rather than a number. Stamping `VERSION` into the image (os-release and/or branding) needs the build to write into a profile copy, which is real build-path work and cannot be verified here without a toolchain.
- **UFW rule set** (M6) and **installed-system repository trust verification** (M7) need a maintainer decision about which services (mDNS, network printing, KDE Connect) an installed NeOS should allow by default.
- **Unattended end-to-end Calamares install test** (O4): CI now proves the live desktop renders, but no automated test installs to a disk image yet.
- **`graphify-out/` is a 2026-09-18 snapshot** and has not been regenerated: it is missing 43 files that exist in the tree and still references the report paths that moved. Regenerate it with the graphify tool before treating it as current.

## [2026.09.18] - 2026-09-18

### Changed
- **Release metadata synchronized**: bumped the project version and the embedded versions reported by the Go CLI and .NET diagnostics tool to `2026.09.18`.
- **Architecture documentation corrected**: clarified that NeOS supports x86_64 only, matching the shipped profile and architecture audit.
- **Security and CI maintenance**: documented the recent hardening, release-tagging, and SourceForge publishing updates.
- **Documentation drift corrected**: README and CONTRIBUTING no longer claim CI builds on `main` (it triggers on `testing`), the README's offline-install claim now states the condition under which it holds, ADR 0006 names the shipped `nvidia-open-dkms` package and points at the real size gate, and the Handbook's clone URL, build command and `profile/` paths were corrected.
- **Archived audits marked superseded**: `docs/archive/DEEP_AUDIT.md` and `docs/archive/ISO_BUILD_FIX.md` carry banners noting that their `DatabaseRequired` claim no longer matches the shipped configuration.
- **CI permissions scoped per job** (`build-iso.yml`): the workflow is read-only by default and the `build` job opts into `contents: write` only for release creation.
- **ShellCheck coverage widened**: scripts are selected by shebang rather than `*.sh`, so the extensionless privileged scripts in `profile/airootfs/usr/local/bin/` are now linted (67 scripts, up from 51).

### Fixed
- **`tools/gen-install-repo.sh` aborted every local build**: `((CACHED_COUNT++))`, `((REUSED_COUNT++))` and `((CLEANED++))` were standalone statements under `set -e`, and a post-increment returns the pre-increment value — so the first increment from 0 returned status 1 and terminated the script. Since `build.sh` calls it unguarded behind an `ERR` trap, `sudo ./build.sh` died at the offline-repo step on every normal build. Converted to assignment form.
- **Online installs preferred unverified packages**: `neos-pacstrap` prepended an unsigned `SigLevel = Optional TrustAll` local repo above `/etc/pacman.conf`, and pacman takes a package from the first repo that provides it — so a stale, unverified copy from the boot medium outranked the signed current package from the mirrors. The local repo is now offline-only, matching the script's documented "always latest" contract for online mode.
- **ShellCheck findings in two privileged scripts**: quoting in `neos-driver-manager`'s exit trap (SC2016/SC2064), and in `neos-operations-hub` five indirect `$?` checks (SC2181), two trap expansions (SC2064) and an unquoted `dbus-send` command substitution (SC2046/SC2086).

### Added
- **Regression guard for bare arithmetic increments**: `tests/verify_shell_arithmetic.sh` scans every shell script for standalone `((VAR++))`/`((VAR--))`, which abort a `set -e` script on the first increment from 0. Verified to match the buggy forms and to ignore `if ((i++))`, `((i++)) || true` and `VAR=$((VAR+1))`.
- **ISO size release gate**: `tests/verify_iso_size.sh` enforces the 2048 MiB budget that README, `profiledef.sh`, PERFORMANCE.md and ADR 0006 all describe as enforced but nothing actually checked. Runs in CI's Validate ISO step; override with `MAX_ISO_MIB`. *(Superseded 2026.09.22 — the gate was removed; see the entry above.)*
- **Dependabot configuration**: weekly updates for GitHub Actions plus the Cargo and Go toolchain modules, so the floating action tags used by the release workflow stay current and visible.
- **Project knowledge graph** in `graphify-out/`: 372 nodes, 422 edges, 77 communities over all code and documentation, with god nodes, cohesion scores and an integrity diagnostic. Committed deliberately; `.gitignore` previously excluded it.
- **Deep audit report**: `reports/v2026.09.18/AUDIT_AND_RECOMMENDATIONS.md` documents the findings above, the fixes applied, what was deliberately left alone, and four open decisions (offline-repo vs size budget, build-path unification, real toolchain gates, boot/install verification).

## [2026.09.11] - 2026-09-11

### Changed
- **Audit consolidation (single source of truth)**: profile auditing is now owned exclusively by `tools/neos-profile-audit` (Rust), which is a strict superset of every removed implementation and the only auditor CI actually executes.
  - Removed the five duplicate auditors in `tools/polyglot/` (Kotlin, Swift, Common Lisp, Haskell, Free Pascal) and their verification gate `tests/verify_polyglot_languages.sh`.
  - Removed the duplicate `audit` command from `tools/neosctl` (Go); the CLI keeps its unique concurrent `rank-mirrors` feature, and `verify_go_neosctl.sh` now builds the tool, guards against the duplicate returning, and exercises mirror-ranking dispatch.
  - Replaced the Ruby `audit_profile` duplicate in `tools/neos_tasks.rb` with an ownership guard; `rake audit` and `ruby tools/neos_tasks.rb audit` now verify auditor ownership instead of re-implementing the audit. Removed the polyglot toolchain packages (`kotlin`, `sbcl`, `clisp`, `ghc`, `fpc`) from the installed-system developer manifest since their only consumers were the removed duplicates.
  - `tools/NeosDiagnostics` (C#) is retained: it audits a distinct domain (security sysctl, ZRAM tuning, pacman signature posture), not the profile.
- **Duplicate report relocation**: the eight root-level agent reports (`ARCHITECT_REPORT.md`, `ARCHITECT_SCOPE.json`, `BOLT_REPORT.md`, `PALETTE_REPORT.md`, `RISK_REPORT.md`, `SENTINEL_REPORT.md`, `SPECIALIST_GUIDANCE.json`, `STRATEGIC_DIRECTIVE.md`) moved to `reports/v2026.09.11/`, ending the parallel append-to-root duplication of the versioned report history.
- **Install manifests refreshed**: regenerated `neos-packages.txt`/`neos-overlay.txt` via `tools/gen-manifests.sh`, picking up `usr/local/bin/chcon` which had silently drifted out of the committed overlay manifest (the exact stale-manifest regression class documented in the 2026.07.03 and 2026.08.18 audits).
- **README / .gitattributes**: tooling table and Linguist rules updated for the consolidation.

### Fixed
- **Repo hygiene**: added `.gitignore` rules for .NET `bin/`/`obj/` build artifacts so local `tools/NeosDiagnostics` builds can no longer pollute `git status` or get committed.

### Added
- **Manifest drift guard**: `tests/verify_manifest_drift.sh` regenerates `neos-packages.txt`/`neos-overlay.txt` via `tools/gen-manifests.sh` in an isolated copy of `profile/` and fails if the committed copies differ (also checks the AUTO-GENERATED headers). CI's pre-build test loop picks it up automatically; this closes the loop on the CWE-436 stale-manifest drift class documented in the 2026.07.03 and 2026.08.18 audits, which CI previously masked because the build job always regenerates before building.

### Cleaned Up
- **Repository hygiene (unslop)**: removed decorative emojis from README.md, all documentation files (ARCHITECTURE.md, ROADMAP.md, PERFORMANCE.md, BOOTLOADER.md, user-guide docs, archive docs), shell scripts (build.sh, gen-*.sh, tests/*), profile configs (pacman.conf, grub, sysctl.d, systemd units), and source code (Rust, Go, C#).
- **Test output standardization**: replaced emojis in test output messages with standard [PASS]/[FAIL]/[WARN]/[INFO] prefixes for consistent, scriptable output.
- **Archive documentation**: cleaned up emojis and placeholder references in historical audit reports (DEEP_AUDIT.md, AUDIT_ACTION_PLAN.md, ISO_BUILD_FIX.md) while preserving their archival value.

## [2026.09.08] - 2026-09-08

### Fixed
- **`neos-welcome` root-execution block** (Sentinel, HIGH): the welcome GUI script now refuses to run as root, closing a privilege-boundary gap in the live-session welcome flow.
- **Calamares dummy `chcon` warnings**: added a no-op `chcon` shim to `profile/airootfs/usr/local/bin/` (with matching `profiledef.sh` permission entry and `verify_airootfs_structure.sh` coverage) so Calamares stops logging spurious SELinux-context warnings on a system that has no SELinux.
- **Licensing dialog horizontal scroll**: welcome app's licensing dialog no longer scrolls sideways.

### Changed
- **Welcome app accessibility**: added visible keyboard focus styles to the welcome app's buttons (Palette).
- **Operations Hub**: minor update to `neos-operations-hub`.

### Notes
- This entry consolidates 55 upstream commits (PRs #900–#954) pulled from `origin/main`; the remainder were governance/strategic-directive bookkeeping (Phase 5–8 validation-pause acknowledgements) with no functional impact.

## [2026.08.18] - 2026-08-18

### Added
- **Polyglot Language Toolchains & Implementations**:
  - **Developer Toolchains**: Added `kotlin`, `sbcl`, `clisp`, `ghc` (Haskell), and `fpc` (Free Pascal) to installed-system developer package manifests in `tools/gen-manifests.sh`.
  - **Polyglot Audit Suite (`tools/polyglot/`)**: Implemented native NeOS profile auditors across Kotlin (`NeosAudit.kt`), Swift (`NeosAudit.swift`), Common Lisp (`neos_audit.lisp`), Haskell (`NeosAudit.hs`), and Free Pascal (`neos_audit.pas`).
  - **Verification Gate**: Added `tests/verify_polyglot_languages.sh` testing execution across all polyglot runtimes with graceful static validation fallbacks.
- **Modern Language Tooling Stack**:
  - **Go CLI Utility (`tools/neosctl/`)**: High-performance Go tool for profile auditing, multi-threaded mirror latency benchmarking via goroutines, and distribution metadata reporting.
  - **C# .NET Compliance & Diagnostics Inspector (`tools/NeosDiagnostics/`)**: Modern .NET 8 cross-platform engine validating security sysctl posture, ZRAM performance flags, package signature policies, and JSON report generation.
  - **Ruby Task Runner & Automation Suite (`tools/neos_tasks.rb` & `Rakefile`)**: Idiomatic Ruby task runner for profile auditing, manifest generation, and verification test orchestration.
  - **Verification Test Gates**: Added `tests/verify_go_neosctl.sh`, `tests/verify_csharp_diagnostics.sh`, and `tests/verify_ruby_tasks.sh` to the test suite.

### Changed
- **Official Arch Linux Mirrorlist Refresh**: Updated `profile/airootfs/etc/pacman.d/neos-mirrorlist` to the latest official HTTPS mirrorlist from archlinux.org with prioritized global CDN and Tier-1 mirrors (`geo.mirror.pkgbuild.com`, `fastly.mirror.pkgbuild.com`, `mirror.fcix.net`, `mirrors.kernel.org`, `mirror.osbeck.com`).
- **Modernized Upstream Package Dependencies**:
  - Replaced legacy `p7zip` with upstream official Arch package `7zip` in `profile/packages.x86_64`.
  - Replaced `iptables-nft` with modern unified `iptables` package in `profile/packages.x86_64`.
  - Updated NVIDIA driver target in `tools/gen-manifests.sh` to `nvidia-open-dkms` for LTS kernel compatibility.
- **Manifest Synchronization**: Regenerated `profile/airootfs/etc/calamares/neos-packages.txt` and `profile/airootfs/etc/calamares/neos-overlay.txt`.

## [2026.07.03] - 2026-07-03

### Added
- **Deep repository & build audit** (`reports/v2026.07.03/deep-audit-report.md`): full audit of the archiso profile, build scripts, airootfs overlay, Calamares config, CI workflow, tests, and tooling, judged against the ArchWiki Archiso article and Ubuntu LiveCDCustomization image-hygiene practices. 3 High / 7 Medium / 6 Low findings with file:line evidence, an ArchWiki+Ubuntu compliance matrix, and a 14-item fix backlog. Headline findings: dormant kiosk installer path that could re-impose passwordless login on installed systems if re-enabled; CI gates weakened with `|| true`; `neos-secureboot-setup` never copied to installed systems; dead i686/aarch64 package lists enforced by the Rust profile audit.
- `tools/gen-build-conf.sh` and `tools/gen-manifests.sh`: single source of truth for the build pacman.conf and the Calamares netinstall manifests, now called by both `build.sh` and CI. **Fixes a High-severity bug found during remediation: CI never regenerated `neos-packages.txt`/`neos-overlay.txt`, so systems installed from CI-built ISOs silently missed every overlay file added after the last committed manifest** (including `neos-secureboot-setup`, the snapshot pacman hooks, and the Plymouth logo).
- `profile/airootfs/etc/mkinitcpio.d/linux-lts.preset` (ArchWiki pattern): builds only the archiso initramfs image, skipping the redundant fallback image (smaller ISO, faster build). Live-only — excluded from the installed-system overlay.
- CI releases now ship `SHA256SUMS` alongside the ISO.
- Regression test: `neos-liveuser-setup.service` must stay unsandboxed (sandboxing it silently breaks live autologin); the check ignores comments and fails if any `ProtectSystem`/`ProtectHome`/`PrivateTmp`/`NoNewPrivileges` directive reappears.

### Added
- **Offline install support**: `tools/gen-install-repo.sh` downloads every package from `neos-packages.txt` into a local pacman repo that `build.sh` embeds on the ISO at `/neos/pkg/` (outside the SquashFS, via xorriso). `neos-pacstrap` now installs hybrid: fresh packages from the network when online, from the on-ISO repo when offline — installation no longer requires internet.

### Changed (boot experience)
- **Plymouth splash redesigned** (supersedes the cat-only layout below): NeOS wordmark + tagline top-third, animated cat centred, pulsing dot indicator and status text beneath — Ubuntu-style polish, still no logo image and no KDE splash. Calamares slideshow (`show.qml`), SDDM theme, and welcome app refreshed to match; slideshow keeps keyboard-focus border and accessibility roles.
- **The cat IS the boot screen now**: removed the NeOS logo from the Plymouth splash — the animated cat alone, dead centre, transparent frames over the plain navy background. The unused theme `logo.png` was deleted (Calamares keeps its own branding logo).
- **KDE/Plasma login splash disabled**: `etc/skel/.config/ksplashrc` (`Engine=none`, `Theme=None`) ships to the live user and installed users, so the Plymouth cat is the only boot screen — no second splash after SDDM login. Guarded by `tests/verify_boot_gui.sh`.

### Fixed
- **Boot/installer logo rendered as a black box**: the NeOS badge (`logo.png` in the Plymouth theme and Calamares branding) shipped with an alpha channel but every pixel opaque — a black square with white corner remnants baked in, visible over the navy gradient on the boot splash and in the installer sidebar. Cut the circular badge out with an anti-aliased alpha mask (`tools/fix-branding-alpha.sh`, ImageMagick — reproducible, no Pillow needed).
- **Boot cat sat on a grey box**: the committed `cat-NN.png` frames predated `tools/gen-bootlogo-frames.py` and carried an opaque `#31384C` rectangle from an older pipeline, even though the source `loader-cat.gif` is fully transparent. Regenerated all 32 frames from the GIF (composite disposal, per-cel trim, 2× Lanczos, centred on a shared 328×328 transparent canvas — same layout rules as the Python generator).
- **Removed the dormant kiosk installer path** (`liveuser-setup.conf`, `neos-install-identity`): orphaned since the public-installer switch, it would have re-imposed a passwordless autologin identity on installed disks if ever re-wired. Also removed the orphaned `neos-installer-partition.sh` (its Btrfs subvolume scheme contradicted the active `mount.conf`) and the broken, unwired `neos-restore-module.qml` (used a `Process` QML type no import provides), plus their tests.
- **CI quality gates restored**: `verify_mkinitcpio.sh` and `verify_qml_enhancements.sh` no longer run under `|| true` — both pass and can now fail the build. ISO-dependent tests remain in the build job where an ISO exists.
- **Overlay manifest hygiene**: live-only mechanics are now excluded from the installed-system overlay (`/root/*` including the build-time `customize_airootfs.sh` — which mkarchiso deletes from the ISO, so its manifest entry would have failed the Calamares rsync — plus `pacman-init.service`, `etc-pacman.d-gnupg.mount`, and `etc/mkinitcpio.d/`).
- Pacman post-snapshot hook now pairs with the newest *pre* snapshot specifically instead of the newest snapshot of any type (concurrent timeline/autoupdate snapshots could mis-link the pair).
- Duplicate liveuser creation removed from `neos-liveuser-setup`: the runtime branch drifted from the build-time `customize_airootfs.sh` (different shell path and groups); the script now fails loudly if the build-time user is missing.
- `gen-vm-appliance.sh` randomizes the VirtualBox NIC MAC (template shipped a fixed one — two NeOS VMs on one LAN segment collided).
- Stale comment in `profile/pacman.conf` claiming the installed system must switch to `DatabaseRequired` (the opposite is deliberate and enforced by the profile audit); publisher URL in `profiledef.sh` aligned with os-release.

### Changed
- **Releases now tag from the `VERSION` file** (`v<VERSION>-b<run>`) instead of the bare CI run number, and the release body carries the matching CHANGELOG section.
- Dropped the never-built i686/aarch64 package lists (Arch dropped i686 in 2017; no aarch64 port exists — `profiledef.sh` builds x86_64 only). `tools/neos-profile-audit` and tests now audit only the shipped architecture.
- `build.sh` warns that the local build mutates the host keyring (use a container for hermetic builds, as CI does).

## [2026.07.02] - 2026-07-02

### Fixed
- **Off-center / wobbling boot cat**: The source GIF anchors the cat in the top-left of its canvas, so the generated frames kept it pinned up-left of center and it jittered as each frame's content size changed. Re-trimmed all 32 `cat-NN.png` frames to their visible pixels and re-centered them on a uniform 320×320 transparent canvas, so the loader cat now sits perfectly centered and stable. Updated `tools/gen-bootlogo-frames.py` to crop-and-center frames on regeneration.

### Changed
- **Faster, Windows-11-style boot**: Eliminated the visible boot-menu wait so the machine drops straight into the animated splash. GRUB now uses `timeout=0` with `timeout_style=hidden` (menu still reachable by holding ESC/SHIFT/F8); the syslinux/BIOS path drops from a 1s to a 0.5s `TIMEOUT` (any keypress still halts the countdown via `MENU IMMEDIATE`). Boot internals were already tuned for speed (squashfs `zstd -22` for smallest size at codec-constant decompress speed, Plymouth `ShowDelay=0` for instant splash), so no rebuild-time regression.

## [2026.07.01] - 2026-07-01

### Fixed
- **Stuck mouse cursor in live session**: The live ISO autologged into the Wayland Plasma session (`Session=plasma`), contradicting the project's X11-everywhere decision. On GPUs that cannot get hardware GL (marginal/hybrid GPUs, NVIDIA/nouveau, non-3D VMs), KWin-Wayland composites via llvmpipe and stops servicing input, freezing the cursor. Switched live autologin to the X11 session (`Session=plasmax11`) in `sddm.conf.d/autologin.conf`.
- **Calamares welcome page missing info buttons**: `welcome.conf` had all `show*Url=false` and `branding.desc` carried no URL strings, so no Support / Known-Issues / Release-Notes links rendered. Enabled the buttons and populated the URLs from os-release.
- **Dead installer instance**: Removed an orphaned `liveuser` shellprocess instance left in `settings.conf` after the earlier public-installer switch.

### Added
- **NeOS logo branding**: Integrated the official NeOS "neo" badge. Added a transparent-background `logo.png` to the Plymouth theme and refreshed the Calamares `logo.png` / `welcome.png` branding assets from the source artwork.

### Changed
- **Windows-11-style boot splash**: Reworked the Plymouth `neos.script` layout so the NeOS logo sits centered just above the vertical middle with the animated cat acting as a spinner below it (LUKS prompt below the cat). Previously the cat sat dead-center with no logo.
- Bumped branding version string to 2026.07.

## [2026.06.29] - 2026-06-29

### Fixed
- **GRUB theme**: Starfield theme's selected-menu-entry highlight was broken. The theme referenced a `blob_*.png` 9-slice pixmap set, but only `blob_w.png` was shipped; additionally, `selected_item_color` was set to `#000` (same as normal items), rendering the selected entry near-invisible. Fixed by removing the broken pixmap reference, setting `selected_item_color` to `#3465a4` (Arch blue) for clear visual feedback, and deleting the orphaned `blob_w.png` file. Boot menu selection is now clearly visible.

### Added
- **Firmware updates**: `fwupd` installed system-wide for hardware firmware management.
- **Accessibility suite**: Added `orca`, `speech-dispatcher`, `espeak-ng`, `espeakup`, and `brltty` to the live image (speech stack only; kept minimal for ISO size). Added `neos-accessibility` oneshot systemd service that detects the `accessibility=on` kernel cmdline parameter and starts espeakup, enabling screen-reader support in the live session. The prior `accessibility=on` boot entry was a dead promise (no packages shipped); this release delivers functional accessibility.
- **Flatpak support**: `flatpak` installed system-wide, providing a working backend for the already-shipped Discover app store.
- **CJK fonts**: `noto-fonts-cjk` added to the installed system (not the live image, to respect the 2 GiB ISO size constraint).
- **NVIDIA support**: `nvidia-dkms` added to the installed system, pairing with existing `dkms` and `linux-lts-headers` for seamless NVIDIA GPU driver compilation during post-install.
- **Secure Boot helpers**: Added `sbctl`, `mokutil`, and `efitools` to the installed system, plus `neos-secureboot-setup` user-initiated helper script using sbctl's own-keys model (post-install, not auto-wired to avoid brick risk). Documented in new `docs/SECURE_BOOT.md`. Live USB still requires Secure Boot to be disabled (no MS-signed shim shipped).
- **Hardware and connectivity**: Added `thermald` (Intel thermal management), `modemmanager` (WWAN support), `networkmanager-openvpn` (VPN UI in NetworkManager), `sane` and `sane-airscan` (scanner support). `thermald` and `modemmanager` are enabled on the installed system via Calamares services-systemd module.

### Changed
- ISO package discipline: Only the minimal a11y speech stack was added to the live squashfs (`profile/packages.x86_64`); all other new capabilities (fwupd, flatpak, CJK fonts, nvidia-dkms, Secure Boot helpers, etc.) are installed network-pacstrapped at installation time from `neos-packages.txt`, keeping the ISO under the 2 GiB GitHub release limit with comfortable margin.

## [2026.06.24] - 2026-06-24

### Fixed
- **Critical**: Live ISO no longer hangs at "Terminate Plymouth Boot Screen". The image shipped only the Wayland Plasma session (`plasma-desktop`) with no X11 session installed at all, and autologged straight into Wayland. On GPUs/VMs where the Wayland session cannot start (notably NVIDIA/nouveau), autologin failed silently and boot stalled at the Plymouth handoff. Now ship `plasma-x11-session` + `xorg-server`, force SDDM onto X11 (`DisplayServer=x11`), and autologin into the `plasmax11` session — the portable path a live installer needs. Wayland remains selectable from SDDM where supported.
- The installed system now also defaults to the X11 Plasma session, so a machine whose GPU could not start Wayland in the live environment does not hit the same hang after installation.

## [2026.06.23] - 2026-06-23

### Fixed
- **Critical**: Calamares now starts. The `alci-calamares` package (last built Feb 2025) links the removed `libyaml-cpp.so.0.8` and fails on current Arch (yaml-cpp 0.9) with exit 127. Replaced it with `calamares-garuda` from the Garuda repo — an actively-rebuilt Calamares that tracks current Arch libraries, provides `calamares`, and pulls no `qt6-webengine` (no ISO size impact). NeOS continues to supply its own `/etc/calamares` settings, modules, and branding.
- **Critical**: "Install NeOS" no longer fails silently. On the live Wayland session the launcher hardcoded `DISPLAY=:0` (often wrong under XWayland), did not pass `XAUTHORITY`, and discarded all errors — so clicking Install showed only a "Starting…" popup and then nothing. The launcher now uses the session's real `DISPLAY`/`XAUTHORITY`, verifies Calamares is present, and surfaces any startup failure via a dialog instead of failing silently. (This is what exposed the `libyaml-cpp` error above.)

- **Critical**: ISO no longer exceeds the 2 GiB GitHub release limit, which was blocking automated releases since V158. Switched squashfs compression from `zstd -19` to `xz` with the x86 BCJ filter for a significantly better compression ratio (trades a slightly slower live-boot for fitting under the limit with comfortable margin).
- Btrfs installs now create a snapper-compatible subvolume layout (`@`, `@home`, `@cache`, `@log`, `@.snapshots`). Previously no subvolumes were created, so snapshot/rollback of the root filesystem could not work despite being a headline feature. Added `modules/mount.conf`.
- `users.conf` now actually grants the `network` and `lp` groups (the prior CHANGELOG claimed these but they were missing).

### Added
- Build-time installer verification (`tests/verify_iso_calamares_libs.sh`): after the airootfs is built the build chroots in and confirms every Calamares shared library resolves and `calamares --version` runs. This gates the build, so a broken installer (e.g. a soname break) fails CI instead of being released.
- Smoke test now exercises the UEFI/OVMF boot path in addition to BIOS, uses more RAM, and fails on kernel panic / emergency-mode / root-mount errors.

### Changed
- Calamares is now sourced from the Garuda repo (`[garuda]`) instead of `alci_repo`. See the build `pacman.conf`.
- Excluded additional datacenter/server-only NIC and HBA firmware from the live image (qed, bnx2x, bnx2, dpaa2, cavium, cnn55xx) — hardware never present on desktops/laptops — to reclaim space in `linux-firmware`.
- Post-install cleanup removes the dangling `neos-liveuser-setup.service` symlink and uninstalls the now-orphaned Calamares package from the installed system.

## [2026.06] - 2026-06-22

### Fixed
- **Critical**: Users created by Calamares now get proper groups (wheel, video, audio, storage, power, network, lp, input) - previously empty
- **Critical**: NetworkManager, SDDM, Bluetooth, and CUPS services now enabled on installed system
- **Critical**: Autoupdate service no longer blocked by overly strict systemd sandboxing (ProtectSystem=full prevented pacman from writing to /usr)
- **Critical**: CI test failures now properly fail the build instead of being silently ignored
- Fixed unpackfs.conf exclude path inconsistencies
- Fixed command injection vulnerability in autoupdate notification system
- Fixed SUID core dump leak (fs.suid_dumpable 2 -> 0)
- Fixed deprecated SSH `ChallengeResponseAuthentication` directive
- Fixed placeholder os-release URLs pointing to neos.example
- Fixed test assertions for updated security values and file layout
- Fixed GRUB test expecting old menuentry names
- Removed alci_repo from installed system pacman.conf (only needed during build)
- Replaced `iptables` with `iptables-nft` to avoid conflicts with ufw

### Added
- Firefox browser (replaces Falkon as default)
- Full KDE Plasma 6 experience: systemsettings, kinfocenter, spectacle, gwenview, okular, kate, kcalc, bluedevil, plasma-systemmonitor
- Vulkan drivers: vulkan-radeon, vulkan-intel, vulkan-swrast
- KDE desktop integration: kwallet-pam, kde-gtk-config, breeze-gtk, xdg-desktop-portal-kde, ffmpegthumbs, kdegraphics-thumbnailers, kio-extras
- CJK font support (noto-fonts-cjk)
- System tools: fwupd, inxi, pacman-contrib, rsync, exfatprogs, alsa-utils, rtkit
- Man pages and bash-completion for better terminal experience
- SSH rate limiting (MaxAuthTries, ClientAliveInterval)
- GRUB accessibility boot option
- Syslinux accessibility boot option
- 6-slide installer slideshow showcasing stability, performance, security, hardware, and desktop features
- Kernel SysRq safe recovery subset (sync, remount-ro, reboot)

### Changed
- Squashfs compression switched from xz to zstd level 15 for significantly faster boot
- GRUB timeout reduced from 15s to 5s
- GRUB boot entries renamed for clarity (removed "Install" prefix)
- Boot parameters now include loglevel=3 and systemd.show_status=auto for cleaner boot
- Welcome app redesigned with professional dark UI and NeOS branding
- Installer slideshow expanded from 1 to 6 informative slides
- Default user shell set to zsh (matching live environment)
- Branding version updated to 2026.06
- Installed system pacman.conf now includes Color, VerbosePkgLists, ILoveCandy
- Locale and man page stripping removed from pacman.conf (was breaking non-English users)
- Root shell messages updated to reference GUI installer instead of archinstall
- Desktop setup script now configures default browser and user directories

### Removed
- Falkon browser (replaced by Firefox)
- Deprecated xf86-video-intel and xf86-video-fbdev/vesa drivers (mesa handles all modern hardware)
- Stale xf86-video-* legacy DDX drivers

## [Unreleased - Prior]

- Fixed documentation URLs to point to https://github.com/uthsarad/NeOS
- Initialized CHANGELOG.md following the 'Keep a Changelog' format
- Fixed `pacman.conf` build blocker (resolved missing repository error).
- Added ISO size validation in CI workflows.
- Updated documentation to clarify x86_64 as the primary supported architecture.
- Improved build verification script robustness against missing `pyyaml`.
- Initial project scaffolding.
