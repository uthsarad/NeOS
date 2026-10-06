# NeOS 2026.10.02 — Review Against the Improvement Plan

Plan: [`00-improvement-plan.md`](00-improvement-plan.md). Brief: [`01-architect-report.md`](01-architect-report.md).

```
STATUS: APPROVED
- 14 of 14 planned items implemented; 2 extra defects found and fixed while implementing (red ISO build, skel .bashrc)
- all 54 tests/verify_*.sh pass locally (51 before + 3 new), each new or extended gate shown to FAIL on the pre-change tree
- 4 items deferred as maintainer decisions (D1–D4), now documented in docs/architecture/OMARCHY_INTEGRATION.md
report: reports/v2026.10.02/02-review-report.md
```

## Item-by-item

| Item | Status | What changed | Proof |
| :-- | :-- | :-- | :-- |
| **A1** Installer credentials / CodeQL alert 3 | Done | `context.py` writes no secret: the arch config is written without `encryption_password` (top-level and nested) *before* a provisioning passphrase is generated, and the deferred-mode creds file is a literal `{"users": []}`. Both files are created `0600` (`O_EXCL\|O_NOFOLLOW`) in a `0700` dir. The passphrase travels in `InstallContext.archinstall_secrets` (`repr=False`) and is injected by `archinstall_adapter._InMemorySecretsConfigHandler`. The LUKS key files and the Tailscale key go through `write_private`. The ineffective `# codeql[...]` comment and the autofix's sanitiser are gone. | `tests/verify_installer_secrets.sh`: 22 checks over three scenarios (generated passphrase, rig passphrase plus smuggled accounts, normal install). It fails on the pre-change orchestrator. The archinstall behaviour it pins was read from upstream `archlinux/archinstall@6bda550` (4.5), `lib/args.py` `from_config` and `lib/models/device.py` `DiskEncryption.parse_arg`. |
| **A2** Fork PR auto-merge | Done (approved by the user) | `jules-auto-merge.yml` reads `isCrossRepository` and exits before any merge for fork PRs; it comments once, on opened/reopened. A null value fails closed. `workflow_dispatch` remains the deliberate maintainer path. CONTRIBUTING updated in all four places that described the policy. | `verify_auto_merge.sh` requires the fork guard to precede the first `gh pr merge`, and fails on the old workflow. actionlint clean. |
| **A3** `build-iso.yml` | Done | `head_ref`/`ref_name`/`event_name`/`run_number` go through `env:`. One sanitiser instead of two. Unused `VERSION` removed. Header comment corrected. Torrent ISO selection by mtime. SSH key written under `umask 077`. Codename call moved to `claude-opus-5-5` with `max_tokens` 1024 (Opus 5.5 always thinks) and `fallbacks: "default"`; the static list still covers every failure. | actionlint: 2 findings before, 0 after. `verify_workflow_security.sh` flags both old expansions (lines 269, 284). |
| **A4** Live releng units | Done | Removed the root tty1 autologin, sshd, networkd ×4, the cloud-init wants plus the `cloud-init` package, livecd-talk/alsa-unmuter, and choose-mirror. `NetworkManager-wait-online` was kept; it was briefly caught by a directory removal and restored before the test run. | `verify_live_services.sh` lists 12 failures on the old tree, including 2 missing `Exec` binaries found by the generic check. |
| **B1** Package list | Done | Strictly sorted (3 entries were out of order), header added, orphan headings removed. | `verify_manifest_drift`, `verify_pacstrap`, `verify_rust_profile_audit` pass. The installed list differs only by order and by `cloud-init`. |
| **B2** pacman.conf comment (M11) | Done | False "Size optimization" line removed. | `verify_build_profile` passes. |
| **C1** Root stray files | Done | `rename_omarchy.sh` and `replace_text.sh` deleted. `gen_wp.py` → `tools/gen-wallpaper.py` (it replaces a generator whose output no longer matched the shipped asset). `wallpaper.html` → `tools/wallpaper-reference.html`. | The new generator's output is **pixel-identical** to the committed `neos-wallpaper.png`. HANDBOOK points at both files. |
| **C2** Duplicate skel trees | Done | `.config/neos/omarchy/` and `.local/state/neos/omarchy/` removed (both byte-identical to their parents). Overlay manifest: 501 → 484 entries. | `verify_airootfs_structure.sh` now rejects omarchy-named overlay paths. |
| **C3** Release paperwork | Done | `VERSION` and its four literals → `2026.10.02`. CHANGELOG section covers all 18 previously undocumented commits plus this work. | `verify_version_stamp.sh` now checks all five sources and the CHANGELOG section (it fails if any is left behind, which closes the drift half of M10). |
| **C4** Docs | Done | New `docs/architecture/OMARCHY_INTEGRATION.md` (active / removed / dormant / decision needed), indexed in `docs/README.md` and README. README gate count updated. Reports index updated. | `verify_docs_links.sh` passes. |
| **C5** `build.sh` cwd | Done | `cd` to the script directory after argument parsing. | `--help` and unknown-option handling work from `/tmp`. ShellCheck clean. |
| **C6** Workflow gate | Done | `tests/verify_workflow_security.sh`: static check of every `run:` block, plus actionlint when installed. | See A3. |

## Found during implementation (not in the plan)

- **The ISO build on `testing` is red** (uthsarad/NeOS#1068, `build` job, 2026-10-01): pacstrap
  aborted with "conflicting files" on eight overlay files that packages also own (`hicolor`
  `index.theme`, skel `.screenrc` and `.zshrc`, and the `lftp`/`ModemManager`/`gvim` icons). They
  were captured from an installed system during the Omarchy import, and mkarchiso copies the
  overlay before installing packages. Removed and guarded in `verify_airootfs_structure.sh`.
  pacman reports all conflicts in one pass, so this is the complete list for that step; later
  build steps are only proven by the next CI run.

- **Every new user's interactive bash printed `/default/bash/rc: No such file or directory`.**
  The imported `/etc/skel/.bashrc` sourced `$NEOS_PATH/default/bash/rc`. `NEOS_PATH` comes
  from `/usr/share/neos/default/bash/env-bootstrap`, which does not exist because the rename
  left the tree at `/usr/share/neos/neos/`. Moving the tree up was rejected: it would activate
  `EDITOR=neos-launch-editor`, `BROWSER=neos-launch-browser` (neither shipped) and a
  `bat`-based `MANPAGER` (not installed), breaking `git commit`, `sudoedit` and `man`. The
  pre-merge `.bashrc` is restored, and the NeOS environment loads only where it resolves.
  `verify_airootfs_structure.sh` now starts an interactive bash with the skel file and fails
  on any error output. Against the old file it reproduces the exact error.
- **Normal installs with a nested-only passphrase** (`disk_config.disk_encryption.encryption_password`
  and no top-level key) were also handed to archinstall without a password before A1, and so
  installed unencrypted. A1's resolution order (creds → config top-level → nested) now covers them.

## Residual risk / not verifiable here

- **CodeQL itself was not run** (not available in this environment). After A1 no
  password-named value reaches a file write in `context.py`. Two writes in `phases_impl.py`
  (`luks-key`, `/etc/neos/provisioning.key`) still persist a passphrase **by design**: they
  are the first-boot re-key key and the initramfs auto-unlock keyfile, now created `0600`
  atomically. If code scanning still lists them, dismiss them as "used in tests / by design"
  with that rationale, or redesign the provisioning unlock (e.g. a random keyfile added as a
  second LUKS slot instead of the passphrase itself). That redesign is outside this change.
- The adapter overrides archinstall's private `_parse_config`. The stub test pins the contract;
  re-check it when archinstall moves past 4.5 (the adapter's docstring already says it is the
  place for that).
- No ISO was built and nothing was booted here (no `mkarchiso`/QEMU in this environment). The
  `build` job in CI runs `build.sh` and the QEMU boot gate on the PR.
- `pacman`-dependent gates (`verify_install_repo.sh`) and the ISO gates skip locally as before;
  CI runs them.

## Deferred (unchanged, documented)

D1 dormant Omarchy defaults/Hyprland configs, D2 the unwired archinstall installer,
D3 `graphify-out/` regeneration, D4 UFW rules (M6) and unattended Calamares test (O4).
See `docs/architecture/OMARCHY_INTEGRATION.md` § Decision needed for D1/D2.
