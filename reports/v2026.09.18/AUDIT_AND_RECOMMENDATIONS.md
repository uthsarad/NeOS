# NeOS Deep Audit — v2026.09.18

> **Superseded in part (2026-09-19 → 2026-09-22).** This report describes the state of
> the tree at `332d8c5`. Two changes since then invalidate parts of it, and the
> follow-up work is recorded in `reports/v2026.09.22/UPDATES_NEEDED.md`:
>
> - **H1 / M5 / O1 are closed by removal, not by enforcement.** Commit `4fab136`
>   deleted `tests/verify_iso_size.sh` and dropped the CI size step; the ISO size
>   limit is deliberately not enforced (releases ship via SourceForge, which has no
>   per-asset cap). Read "H1 — the documented 2 GiB ISO budget was enforced nowhere"
>   as *the budget was retired*, not as *a gate now exists*.
> - **H3 / O3 are fixed**: CI's `test` job installs `ruby`, `go` and `dotnet-sdk`
>   and exports `REQUIRE_TOOLS=1`, so a missing toolchain fails the build instead of
>   degrading to a static grep; `verify_rust_profile_audit.sh` now also runs
>   `cargo test`; `tools/gen-install-repo.sh` is exercised by
>   `tests/verify_install_repo.sh` (see C2 below).
> - **C2 / O2 are fixed**: CI now calls `build.sh --ci --no-offline-repo` — one
>   build entrypoint for both paths, with the offline repo opt-out explicit.
> - **H4 is fixed**: the live ISO boots with a serial console and ships
>   `neos-boot-probe.service`, and `tests/verify_iso_smoketest.sh` now fails unless
>   the guest reports an active `graphical.target` and renders a non-blank frame —
>   a timeout is no longer a pass. `tests/verify_boot_evidence.sh` guards the wiring.
> - M5's "first glob match" consumers now select the newest image by mtime, and
>   `build.sh` removes a partially written `-with-repo.iso` on failure.
>
> **Still open:** M1 (live/installed manifest duplication), M3 (`--admin` merge
> fallback), M4 (action SHA pinning), M6 (UFW rules), M7 (installed-system repo
> trust), M10 (version sources — partially addressed), M11 (`NoExtract` comment),
> and an unattended end-to-end Calamares install test (O4).

**Date:** 2026-09-18
**Branch:** `testing`
**Scope:** Whole repository, prioritized — build & install pipeline, security
hardening, shell correctness, CI, docs↔reality drift, tooling and test coverage.
**Method:** Review of all 321 tracked files (208 under `profile/`, 41 tests, 20
tooling files, 4 workflows, 29 docs) plus targeted empirical checks.

## Verification honesty

**Verified by execution**

- The `((VAR++))`-under-`set -e` failure mode, reproduced in isolation.
- `shellcheck` findings in every extensionless script in
  `profile/airootfs/usr/local/bin/` (this is how the two failing scripts were
  found, and how `neos-welcome-app` was identified as Python and `.hook` files
  as pacman/alpm INI config — neither may be linted as shell).
- The full pre-build suite: **39 passed, 0 failed** after the changes below.
- YAML validity of all four workflows plus `dependabot.yml`.
- `bash -n` on every script touched.
- The new arithmetic guard, confirmed to match the buggy forms and ignore the
  legitimate ones.

**Not verified**

- **No ISO was built.** `archiso` is unavailable in this environment, so
  `build.sh`, `mkarchiso`, `verify_iso_*` and the Calamares install flow were
  not exercised. Every claim about build behaviour is static analysis of the
  command sequence, not an observed build.
- No boot test, no QEMU run, no install run.

---

## Critical findings

### C1 — `tools/gen-install-repo.sh` aborts on every normal build

`((CACHED_COUNT++))`, `((REUSED_COUNT++))` and `((CLEANED++))` were standalone
statements under `set -euo pipefail`. A post-increment evaluates to the value
*before* the increment, so the first increment from 0 returns exit status 1 and
`set -e` terminates the script (reproduced: prints `before`, exits 1).

On a fresh build `REPO_DIR` is empty, so `CACHED_COUNT` never increments — but
`work/pkgs` exists from the `mkarchiso` run immediately before, so the first
package reused from that cache triggers `((REUSED_COUNT++))` from 0 and kills
the script. `build.sh` calls it unguarded:

```
bash tools/gen-install-repo.sh ... # no || true, no set +e
```

and `build.sh` has an `ERR` trap that logs a critical failure and exits. **Every
local `sudo ./build.sh` therefore dies at "Building offline install package
repo".** Fixed.

### C2 — CI builds a different ISO than `build.sh` does

`build-iso.yml` re-implements the build inline (generate build conf → generate
manifests → `mkarchiso` → validate). It never runs `tools/gen-install-repo.sh`
or the `xorriso -map` step that embeds the offline repository at `/neos/pkg`.

Two consequences:

1. **Released ISOs cannot install offline.** `neos-pacstrap` looks for
   `/run/archiso/bootmnt/neos/pkg`, does not find it, and if the network check
   also fails it exits with "no network detected and no local package repo on
   the ISO". The README claimed offline install for all ISOs.
2. **C1 survived.** No CI job, and no test, ever executed the offline-repo
   script — so its fatal bug was unreachable from automation.

**Not fixed** — see open decisions. The correct fix (make CI call one shared
build entrypoint) interacts directly with O1 below.

### C3 — Online install preferred unverified packages over signed ones

In online mode `neos-pacstrap` prepended a synthetic repo above `/etc/pacman.conf`:

```
[neos-local]
SigLevel = Optional TrustAll
Server = file://${LOCAL_REPO}
```

pacman resolves a package from the **first** repository that provides it, so an
unsigned — and potentially stale — package from the boot medium outranked the
signed, current package from the mirrors. That is both a supply-chain hole and a
direct contradiction of the script's own contract ("ONLINE: Download fresh
packages from internet mirrors (always latest)"). The local repo is now offline-only.

---

## High findings

### H1 — The documented 2 GiB ISO budget was enforced nowhere

Four places assert the limit is hard and/or enforced: `README.md`
("sub-2GB ISO size"), `profile/profiledef.sh` ("stay under the 2048 MiB release
gate"), `docs/architecture/PERFORMANCE.md` (Performance Budgets), and ADR 0006
("2 GiB ISO limit enforced"). The workflow only *printed* the size
(`printf -v ISO_SIZE_MB`), so a regression would have shipped. There is now a
real gate (`tests/verify_iso_size.sh`, wired into CI's Validate ISO step).

Note the stated rationale is also stale: ADR 0006 and the workflow comments
justify the limit by "GitHub release size limits", but the ISO is uploaded to
SourceForge by rsync — GitHub only receives checksums and VM templates.

### H2 — ShellCheck never linted the privileged scripts

CI ran `find . -type f -name '*.sh' | xargs shellcheck`. The 13 shell scripts in
`profile/airootfs/usr/local/bin/` — including `neos-pacstrap`,
`neos-driver-manager`, `neos-secureboot-setup` and `neos-liveuser-setup` — have
**no extension**, so they were never linted. Discovered by shebang now; two real
findings surfaced and were fixed first so the widened gate passes clean:

- `neos-driver-manager`: `exit_trap_cmd='rm -f "$REPORT_FILE"'` +
  `trap "$exit_trap_cmd" EXIT` (SC2016, SC2064).
- `neos-operations-hub`: 5× SC2181 (`[ $? -eq 0 ]` after a command
  substitution), 2× SC2064, and an unquoted command substitution in the
  `dbus-send` call (SC2046/SC2086).

### H3 — Several CI gates report success by *skipping*

The `test` job installs `git wget awk grep diffutils syslinux python rust
python-yaml shellcheck trivy` — no `ruby`, `go` or `dotnet`. So
`verify_ruby_tasks.sh`, `verify_go_neosctl.sh` and `verify_csharp_diagnostics.sh`
silently degrade to static `grep` assertions, and the README-advertised
`neosctl` mirror-benchmarking CLI is never compiled in CI. The Rust auditor's 10
unit tests never run either (`verify_rust_profile_audit.sh` calls
`cargo run`, never `cargo test`). **Not fixed** — needs a toolchain decision.

### H4 — `verify_iso_smoketest.sh` treats a timeout as a pass

`run_boot` accepts exit codes `124` (timed out) and `137` as success and only
greps the log for kernel-panic/emergency strings. A live session that never
reaches the desktop — black screen, dropped to a TTY, SDDM failing to start —
passes. `-nographic` is used with no serial console assertion. There is no
end-to-end Calamares install test at all. **Not fixed.**

---

## Medium findings

| ID | Finding | Location |
|----|---------|----------|
| M1 | `gen-manifests.sh` re-adds 9 packages already in `packages.x86_64` into the generated manifest: `firefox`, `cups`, `discover`, `dkms`, `flatpak`, `fwupd`, `linux-lts-headers`, `packagekit-qt6`, `broadcom-wl-dkms`. The Rust auditor rejects duplicates in the *source* list, yet nothing checks the manifest consumers actually use. | `tools/gen-manifests.sh` |
| M2 | `neos-welcome-app` is Python; `.hook` files are pacman/alpm INI. Neither is shell — recorded so nobody "fixes" the lint coverage by adding them. | `profile/airootfs/usr/local/bin/`, `usr/share/neos/hooks/` |
| M3 | `jules-auto-merge.yml` force-merges as its last resort (`gh pr merge --squash --admin`), bypassing required status checks — which weakens the review gate the file's own comment argues for. Also re-approves the PR before merging. | `.github/workflows/jules-auto-merge.yml` |
| M4 | Workflows consume third-party actions by floating tag with `contents: write` on the workflow. Permissions are now scoped per job and Dependabot added; SHA pinning still outstanding. | `.github/workflows/` |
| M5 | `verify_iso_smoketest.sh` and the "Prepare ISO for upload" step both take `out/*.iso` and use the *first glob match*. `build.sh` writes a temporary `-with-repo.iso` and only removes it after a successful `mv`; `-` (0x2d) sorts before `.` (0x2e), so a leftover temporary is selected over the real image. `verify_iso_size.sh` selects by newest mtime instead. | `tests/verify_iso_smoketest.sh`, `.github/workflows/build-iso.yml` |
| M6 | UFW ships `ENABLED=yes` with no rules on both live and installed systems (default deny incoming), with no allowance for mDNS/Avahi discovery, network printing or KDE Connect. `tests/verify_ufw.sh` only checks that the flag is set. | `profile/airootfs/etc/ufw/ufw.conf` |
| M7 | Installed-system repo trust is unverified end to end. `gen-manifests.sh` excludes `etc/pacman.d/`, `etc/pacman.conf` and every `*.target.wants/`, so service enablement depends entirely on `services-systemd.conf` and the `[garuda]` key is never `--populate`d on the target. Nothing tests that an installed system can actually resolve `pacman -Syu`. | `tools/gen-manifests.sh`, `etc/calamares/modules/services-systemd.conf` |
| M8 | `build.sh` prompts with a bare `read -p` and no `[[ -t 0 ]]` guard; a non-interactive invocation with an existing `work/` hits EOF, returns non-zero, and the `ERR` trap aborts the build. `build.sh` also writes `profile/install-repo/` inside the git-tracked tree (not in `.gitignore`) and leaves it behind on failure. | `build.sh` |
| M9 | `profile/bootstrap_packages.x86_64` is dead: `buildmodes=('iso')` only, so the bootstrap package list is never consulted. | `profile/profiledef.sh` |
| M10 | Four independent version sources: `VERSION`, `profiledef.sh`'s `date`-based `iso_version`, `tools/neos_tasks.rb`'s `VERSION`, and the CI-generated tag. Nothing asserts they agree. | repo-wide |
| M11 | `profile/pacman.conf` promises "# Size optimization: Exclude docs, non-English locales, and unneeded enterprise firmware" with no `NoExtract` directive following it. | `profile/pacman.conf` |

---

## Documentation ↔ reality drift

All fixed in this change set:

| Claim | Reality | Fix |
|-------|---------|-----|
| README: CI runs "every push to `main`" | Workflow triggers on `testing` only | Corrected (2 places) |
| README: "install offline with the Calamares wizard" | Only local `build.sh` ISOs embed the offline repo | Clarified with the actual condition |
| README: "built in the cloud upon every push to the main branch" | `testing` | Corrected |
| CONTRIBUTING: "create a feature branch from `main`" | CI/releases run off `testing` | Corrected |
| ADR 0006: `nvidia-dkms` | Manifest ships `nvidia-open-dkms` | Corrected |
| ADR 0006: "2 GiB ISO limit enforced" | Nothing enforced it | Now true — references the new gate |
| HANDBOOK: clone URL `NimuthuGanegoda/NeOS.git` | Remote is `Uthsarad/NeOS` | Corrected |
| HANDBOOK: `sudo mkarchiso -v -w work -o out .` | Profile lives in `profile/`; `build.sh` is the entrypoint | Corrected |
| HANDBOOK: project-structure table lists profile files at repo root | They are under `profile/` | Corrected |
| `docs/archive/DEEP_AUDIT.md`: installed system uses `DatabaseRequired` | Shipped config uses `DatabaseOptional` | Superseded banner |
| `docs/archive/ISO_BUILD_FIX.md`: same claim | Same | Superseded banner |

Remaining doc debt (not fixed): `docs/TROUBLESHOOTING.md` and
`docs/user-guide/TROUBLESHOOTING.md` are separate files with overlapping
content, and ADRs live in two directories (`docs/decisions/` and
`docs/architecture/decisions/`).

---

## Changes in this commit

**Fixed**

- `tools/gen-install-repo.sh` — all three increments converted to assignment
  form, with a comment explaining the failure mode (C1).
- `profile/airootfs/usr/local/bin/neos-pacstrap` — the unsigned local repo is no
  longer prepended in online mode; header comment states that it is offline-only
  (C3).
- `profile/airootfs/usr/local/bin/neos-driver-manager` — trap quoting (H2).
- `profile/airootfs/usr/local/bin/neos-operations-hub` — trap quoting, direct
  exit-status tests, quoted `dbus-send` substitution (H2).
- `README.md`, `CONTRIBUTING.md`, `docs/decisions/0006-…`,
  `docs/user-guide/HANDBOOK.md` — drift corrected.
- `docs/archive/DEEP_AUDIT.md`, `docs/archive/ISO_BUILD_FIX.md` — superseded
  banners.

**Added**

- `tests/verify_shell_arithmetic.sh` — regression guard for the C1 class. Flags
  only standalone `((VAR++))`/`((VAR--))`; deliberately ignores `if ((i++))`,
  `((i++)) || true` and `VAR=$((VAR+1))`.
- `tests/verify_iso_size.sh` — enforced ISO size gate (H1), env-overridable via
  `MAX_ISO_MIB`, selects the newest ISO by mtime (M5), skips without an ISO
  unless `REQUIRE_ISO=1`.
- `.github/dependabot.yml` — Actions, Cargo and Go module updates.
- `graphify-out/` — project knowledge graph (see below).

**Changed**

- `.github/workflows/build-iso.yml` — least-privilege permissions (workflow
  read-only, `build` job opts into `contents: write`); ShellCheck widened to
  shebang-based discovery (H2); `REQUIRE_ISO=1 bash tests/verify_iso_size.sh`
  added to the Validate ISO step.
- `tests/verify_shellcheck.sh` — mirrors the widened CI invocation exactly.

**Deliberately not done**

- Action SHA pinning. Requires SHAs verified against upstream tags; a wrong SHA
  fails the release build, and fabricating them is worse than floating tags plus
  Dependabot. Recorded as a follow-up.
- Any change to the CI/local build-path split, pending O1.

---

## Open decisions (owner input required)

### O1 — Offline install repo vs the 2 GiB budget

These are mutually exclusive as configured. `gen-install-repo.sh` downloads every
package in `neos-packages.txt` (~210 entries including `firefox`,
`libreoffice-fresh`, `vlc`, `gimp`, `nvidia-open-dkms`) and embeds them **outside**
the squashfs. The offline repo therefore does not affect the live image, but it
does affect ISO size — and C2 means the shipped artefact has never included it.

Options: (a) drop the offline repo and delete the script; (b) keep it and scope it
to a minimal base set; (c) keep it, raise the gate deliberately, and update all
four documents that state 2 GiB.

### O2 — Unify the build paths

CI must run the same entrypoint as `build.sh`, or the tested artefact is not the
shipped artefact. This is safe to do only after O1.

### O3 — Make the toolchain gates real

Install `ruby`, `go`, `dotnet` in the `test` job (or add a matrix), run
`cargo test`, and add a `REQUIRE_TOOLS=1` mode where a missing toolchain fails
instead of skipping (H3).

### O4 — Boot and install verification

Serial-console assertions, `graphical.target`/SDDM checks, and an unattended
Calamares install to a disk image (H4).

---

## Prioritized recommendations

1. **O1** — decide the offline-repo question; it blocks O2 and C2's real fix.
2. **O2** — one build entrypoint shared by CI and local builds.
3. **O3** — stop gating on tools that are not installed; add `cargo test`.
4. **O4** — assert the desktop actually reaches `graphical.target`.
5. Pin actions to verified SHAs; add `actionlint` and `zizmor`.
6. Add secret scanning and a CVE pass over the ISO package set
   (`arch-audit`/`osv-scanner` against `neos-packages.txt`) — `trivy fs ./` on a
   shell/config repo inspects almost nothing.
7. Give UFW a rule set (M6) and verify installed-system repo trust (M7).
8. De-duplicate the manifest generator's package emission (M1) and add a
   duplicate check for `neos-packages.txt`.
9. Fix `build.sh`'s TTY guard and keep build artefacts out of `profile/` (M8).
10. Remove the `--admin` merge fallback (M3).

---

## Knowledge graph

The repository now carries a queryable knowledge graph in `graphify-out/`
(committed deliberately — `.gitignore` previously excluded it):

- **372 nodes · 422 edges · 77 communities** — 92% EXTRACTED, 6% INFERRED,
  2% AMBIGUOUS.
- God nodes: `assert_profiledef_properties()` (13), `run_audit()` (12),
  `build.sh script` (8), `NeOS (Next Evolution Operating System)` (8).
- Four hyperedges, including "ISO Size Constraint Contradiction Cluster" — which
  the graph derived independently of this audit, from the docs alone.

**Disclosed graph limitation:** the integrity diagnostic reports
`52 dangling-endpoint edges` and `11 collapsed (undirected) edges`. The dangling
edges are AST artefacts of the Rust extractor — references to built-in types
(`String`, `Path`, `Result`) that have no corresponding node. The graph is
usable; the edge count overstates true connectivity by ~12%.

Coverage: all 79 code files (AST) and all 43 documents (semantic). The 70 image
assets — Plymouth frames, GRUB theme textures, wallpapers, logos, Calamares
partition SVGs — were excluded as decorative; they carry no architectural
semantics.
