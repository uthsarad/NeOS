# NeOS — What Needs Updating

> **Status (end of the 2026-09-22 work session).** This started as an audit; the
> findings below were then acted on in the same branch. Resolved here: §1 (VERSION +
> CHANGELOG now cover `523a269`/`4fab136`, ADR 0006/PERFORMANCE.md/audit banner
> corrected), §2.1 (nine reports restored to `reports/v2026.09.11/`, root duplicates
> deleted), §2.2 (CLAUDE.md references now resolve), §2.3 (docs index added — 0 broken
> links), §3 (shipped URLs repointed at the canonical repo), §4.1–4.4 (docs
> corrected), §5 C2/H3/H4/M1/M3/M4/M5/M8/M11 (see CHANGELOG 2026.09.22). Still open:
> §2.4 (`graphify-out/` still needs regenerating with the graphify tool — it predates
> this work; it now carries a snapshot banner and a `graphify-out/README.md`), §4.5 (deduplicated: the `/etc` module copies are now relative symlinks to
> the canonical `/usr/lib` copy, guarded against re-divergence), §5 M6
> (UFW rule set — needs a product decision), M7 (installed-system repo trust test),
> M9 (`bootstrap_packages.x86_64` documented as unused rather than deleted), M10
> (partially addressed: no hardcoded version literals remain in shipped files, but the
> four version sources are still synchronised by hand), and O4 (unattended Calamares
> install test). Sections below are kept as written on the day of the audit.

**Date:** 2026-09-22
**Snapshot:** `NimuthuGanegoda/NeOS` (fork of `uthsarad/NeOS`), branch `testing` @ `4fab136`
("fix(ci): remove revived 2 GiB ISO size gate", 2026-09-19). Fork and upstream tips are
identical (`main` = `28a4ee7`, `testing` = `4fab136`), so this is not a "behind upstream" problem.
**Scope:** whole tree (331 tracked files) — release paperwork, docs↔reality drift, shipped-system
identity/URLs, CI and tooling, plus the still-open items from the 2026.09.18 audit.
**Method:** read-only. Full tree review; all 39 non-ISO verification scripts executed locally
(all pass, 7 skip gracefully for missing toolchains/network); markdown link + file-path resolution
checks over every `.md`; GitHub API inspection of both repos, their branches, workflows and issues;
diff of the two commits that landed after the last release-metadata sync.

---

## 1. Release paperwork no longer matches the code (fix first)

### 1.1 The CHANGELOG documents a size gate that was deleted
`CHANGELOG.md:23` still advertises `tests/verify_iso_size.sh` as added and wired into CI's
Validate ISO step. The tip commit removed it (`tests/verify_iso_size.sh` deleted,
`.github/workflows/build-iso.yml` size step dropped), and `README.md:41` now says
"(no size cap; releases ship via SourceForge)". The changelog is the release-notes source
(`build-iso.yml` extracts the `## [VERSION]` section), so the next release would ship release
notes describing a gate that does not exist.

### 1.2 Two commits after the last metadata sync are undocumented
`VERSION` = `2026.09.18` = the newest CHANGELOG entry, but the branch tip is two commits later:

| Commit | Date | Effect | In CHANGELOG? |
| :-- | :-- | :-- | :-- |
| `523a269` | 2026-09-19 | `cups.service` → `cups.path` + `cups.socket`, `neos-packages.txt` trimmed by 15 entries, `services-systemd.conf`, `neos-liveuser-setup`, `gen-manifests.sh` | no |
| `4fab136` | 2026-09-19 | size gate removed (workflow, README, ADR 0006, `profiledef.sh`) | no — and it contradicts 1.1 |

Per the project's own version-first rule (`CLAUDE.md`), the next release needs `VERSION` bumped
(2026.09.22) plus one CHANGELOG section covering both commits, since the release tag is derived
from `VERSION` and the body from that section.

### 1.3 Documents left behind by the gate removal
- `docs/decisions/0006-ubuntu-parity-capabilities.md` — line 44 is marked superseded, but the
  Context (line 8), Decision (26) and Consequences (33, 40) still assert a *hard* 2 GiB limit
  "for reliable GitHub releases", which is no longer where ISOs go (SourceForge, via rsync).
- `docs/architecture/PERFORMANCE.md` — the budget table still lists ISO Size `< 2.5GB / 4GB`
  and was not touched by the removal commit; it now disagrees with README's "no size cap".
- `reports/v2026.09.18/AUDIT_AND_RECOMMENDATIONS.md` — H1 ("There is now a real gate", lines
  95–102), M5 (line 150), "Changes in this commit" (line 207) and O1 (line 232) all describe the
  gate as live. The report needs the same superseded banner the archived audits received.
- `tools/neosctl/main.go:92` and `CHANGELOG.md:32–34` point at `reports/v2026.09.11/…`, which
  does not exist on this branch (see 2.1).

---

## 2. Repo hygiene / stale artefacts

### 2.1 Six "Strategic Pause" reports are still at the repo root
`ARCHITECT_SCOPE.json`, `SPECIALIST_GUIDANCE.json`, `STRATEGIC_DIRECTIVE.md`, `BOLT_REPORT.md`,
`PALETTE_REPORT.md`, `RISK_REPORT.md` — all dated 2026-09-12 and all asserting *"Halt all feature
development… Do not write production code"*, i.e. a policy the repository has contradicted for
ten days of merges. `CHANGELOG.md` (2026.09.11) claims these were moved to
`reports/v2026.09.11/`, but that directory does not exist here — the claim is false on this
branch. `.github/workflows/jules-auto-merge.yml:27` still cites `ARCHITECT_SCOPE.json`'s
`strategic_pause` history.

### 2.2 `CLAUDE.md` references eight files that do not exist in the repo
`docs/orchestrator/AGENTS.md`, `WORKFLOWS.md`, `MODES.md`, `QUALITY-GATES.md`, `VERSIONING.md`,
`META-DECISIONS.md`, `docs/policies/DOMAIN_PACK_SPEC.md`, `docs/AGENT_MODEL_SELECTION.md`, plus
five `skills/*` directories used by its routing tables. Neither branch carries them, so the
"CC_GodMode v7.1.1 — Docs Polish" contract cannot be followed as written.

### 2.3 Broken relative links in documentation
`docs/README.md` does not exist, but five documents link to it as the documentation index:
`docs/architecture/ARCHITECTURE.md`, `BOOTLOADER.md`, `PERFORMANCE.md`, `ROADMAP.md`,
`docs/user-guide/VM_STARTUP.md`. `docs/archive/ISO_BUILD_FIX.md` additionally links to
`HANDBOOK.md`, `ARCHITECTURE.md`, `BOOTLOADER.md` as if they sat beside it.

### 2.4 `graphify-out/` is stale
*(Still open: the graph itself has not been regenerated — the `graphify` tool is not available
here. What changed in this session is that the staleness is now stated where the artefact is
read: `GRAPH_REPORT.md` carries a snapshot banner and `graphify-out/README.md` documents the
tool, the file set, and the fact that the counts no longer match the tree.)*

The manifest covers 192 files; 43 current code/config/doc files are absent (`dependabot.yml`,
most of `etc/calamares/modules/`, the SDDM theme `Main.qml`, the pacman hooks, …). The report
header still says "192 files · 372 nodes" and the community list still names
"ISO Size And Audit History".

### 2.5 Emoji cleanup is incomplete
2026.09.11 claimed emojis were replaced by `[PASS]/[FAIL]/[WARN]/[INFO]` in *test output*, yet
`tests/verify_iso_calamares_libs.sh`, `verify_iso_smoketest.sh`, `verify_mirrorlist_connectivity.sh`,
`verify_service_hardening.sh` (⏭️) and `verify_palette_consistency.sh` (✅/❌) still emit emoji.
(The UI-facing scripts and QML — `neos-welcome-app`, `neospacstrap/main.py`, `show.qml`,
`Main.qml` — are a taste call, not a defect.)

---

## 3. Shipped-system identity and support URLs point at the wrong repo

`/etc/os-release`, the Calamares branding and the ISO publisher all point at the **fork**:

| File | Value |
| :-- | :-- |
| `profile/airootfs/etc/os-release:7-10` | `NimuthuGanegoda/NeOS` for HOME/DOCUMENTATION/SUPPORT/BUG_REPORT |
| `profile/airootfs/etc/calamares/branding/neos/branding.desc:26-29` | product/support/known-issues/release-notes → `NimuthuGanegoda/NeOS` |
| `profile/profiledef.sh:7` | `iso_publisher="NeOS Team <…/NimuthuGanegoda/NeOS>"` |

Everything else (README badges and links, `CONTRIBUTING.md:7`, `docs/user-guide/HANDBOOK.md:41,68`,
`neos-operations-hub`, `tools/neos-sync.sh`) points at `uthsarad/NeOS`. The fork has **Issues
disabled** (verified via API), so every "report a bug / support" link shipped inside the installed
OS is a dead end, and `branding.desc`'s `releaseNotesUrl` targets the fork's `main` CHANGELOG,
which lags at `2026.09.11` while releases are cut from `testing`.

---

## 4. Documentation that contradicts the shipped tree

| # | Claim | Reality |
| :-- | :-- | :-- |
| 4.1 | `docs/user-guide/HANDBOOK.md:53` — "the temporary installer session starts Calamares automatically" | What autostarts is `neos-welcome-app` (`etc/xdg/autostart/neos-welcome-app.desktop`); Calamares only launches when Install is pressed (`neos-welcome-app:241,345`) |
| 4.2 | HANDBOOK path table and quick map use unprefixed `airootfs/`, `grub/`, `packages.x86_64` (lines 104–137) | Everything lives under `profile/`; the wallpaper pointer (`airootfs/usr/share/wallpapers/`) does not exist — the asset is `profile/airootfs/usr/share/backgrounds/neos-wallpaper.png` |
| 4.3 | `docs/architecture/BOOTSTRAP.md:16,26,33` — bootloader config at `grub/grub.cfg`, bootstrap packages in `bootstrap_packages.x86_64`, scripts in `airootfs/usr/local/bin/` | Real paths are `profile/…`; `bootstrap_packages.x86_64` is dead config because `profiledef.sh` sets `buildmodes=('iso')` only (audit M9) |
| 4.4 | `docs/TROUBLESHOOTING.md:5` warns about `SigLevel = Required DatabaseRequired` blocking builds | The shipped profile deliberately uses `DatabaseOptional`; this doc never got the "superseded" treatment the archived audits did |
| 4.5 | Two identical copies of the `neospacstrap` Calamares module ship (`etc/calamares/modules/` and `usr/lib/calamares/modules/`, `main.py` + `module.desc` byte-identical) | `settings.conf` searches both paths — one copy is redundant and a guaranteed future drift source. **Resolved:** the single canonical copy lives in `/usr/lib` (first search path, and the one `profiledef.sh` grants `0:0:755`); the `/etc` copies are relative symlinks to it, and `tests/verify_pacstrap.sh` now fails if a divergent second copy is reintroduced |

---

## 5. Engineering items still open from the 2026.09.18 audit

Nothing below has changed since that report was written; all are re-verified against today's tree.

| ID | Item | Evidence |
| :-- | :-- | :-- |
| C2 | CI and `build.sh` build different artefacts; only local builds embed the offline repo, so released ISOs cannot install offline (README is scoped, `build.sh:180-205` is not in CI) | `build-iso.yml` build job vs `build.sh` |
| H3 | The `test` job installs no `ruby`, `go` or `dotnet` (`build-iso.yml:43`), so `verify_ruby_tasks.sh`, `verify_go_neosctl.sh`, `verify_csharp_diagnostics.sh` degrade to static greps; `cargo test` never runs | verified locally: same three tests print "not installed… validating statically" |
| H4 | `verify_iso_smoketest.sh:83` accepts exit 124/137 (timeout) as success — a live session that never reaches the desktop passes | same |
| M1 | 9 packages are emitted into *both* the live list and the installed manifest (`firefox`, `cups`, `discover`, `dkms`, `flatpak`, `fwupd`, `linux-lts-headers`, `packagekit-qt6`, `broadcom-wl-dkms`) | re-checked: still duplicated |
| M3 | `jules-auto-merge.yml` still falls back to `gh pr merge --admin`, bypassing required checks | last resort branch |
| M4 | Third-party actions still on floating tags (SHA pinning outstanding; Dependabot is the mitigation) | `checkout@v5`, `action-gh-release@v3`, `labeler@v6`, `ai-inference@v2` |
| M5 | ISO selection by first glob match persists (`build-iso.yml:380-381`, `verify_iso_smoketest.sh`) while `build.sh` leaves a `-with-repo.iso` temporary behind on failure | idem |
| M6 | UFW ships `ENABLED=yes` with no rules (no mDNS/printing/KDE Connect allowance) | `etc/ufw/ufw.conf` |
| M7 | Installed-system repo trust (`[garuda]` key, `pacman -Syu` resolution) is untested | `gen-manifests.sh` exclusions |
| M8 | `build.sh:58` prompts with a bare `read -p` (no `[[ -t 0 ]]` guard) and writes `profile/install-repo/` inside the git tree, which `.gitignore` does not cover | idem |
| M9 | `profile/bootstrap_packages.x86_64` is never consulted | `profiledef.sh:11` `buildmodes=('iso')` |
| M10 | Four version sources (`VERSION`, date-based `iso_version`, tool `VERSION` constants, CI tag) — now five, counting `neos-welcome-app:387`'s hardcoded `'v2026.09'` fallback | repo-wide |
| M11 | `profile/pacman.conf:13` still promises "Size optimization: Exclude docs, non-English locales…" with no `NoExtract` directive | idem |

---

## 6. GitHub-side housekeeping

- **Open issues that read as resolved:** `uthsarad/NeOS#980` ("NeOS Installer has an issue" —
  stuck at 10%) and `#955` ("We need images on the readme") both carry a MikoYae-AI comment saying
  they were fixed in PR #1003, and both are still open. Close or re-verify.
- **Fork Issues disabled** while shipped URLs point there (section 3) — either enable issues on
  the fork or repoint the URLs.
- **No sync needed:** fork and upstream tips match; `main` is the intentionally idle branch
  (`VERSION` 2026.09.11 vs `testing` 2026.09.18), which matches the README statement.

---

## 7. Verified healthy (not on the list)

- All 39 non-ISO verification scripts pass locally. Skips are environmental only: PyYAML,
  shellcheck, cargo, go, ruby, dotnet absent, mirrorlist connectivity blocked.
- `tests/verify_manifest_drift.sh` passes — the committed Calamares manifests match the generator.
- `tools/gen-install-repo.sh`'s `((VAR++))` regression is fixed and guarded by
  `tests/verify_shell_arithmetic.sh`; `neos-pacstrap` no longer prepends the unsigned local repo.
- README/CONTRIBUTING/ADR 0006/HANDBOOK corrections from 2026.09.18 are present in the tree
  (the remaining drift is what sections 1 and 4 list).
- CI workflow YAML could not be re-validated here (no PyYAML in this sandbox); the only workflow
  edit since the last green build is the size-gate removal.

---

## Suggested order of work

1. **Bump `VERSION` to 2026.09.22** and add a CHANGELOG section for `523a269` + `4fab136`
   (including an explicit note that the size gate was removed), so release notes stop lying.
2. **Add superseded notes** to the 2026.09.18 audit report (H1/M5/O1), ADR 0006's Context/Decision/
   Consequences, and align the PERFORMANCE.md ISO budget with the "no size cap" policy.
3. **Decide the report-root policy:** delete/relocate the six Strategic-Pause files and fix the
   2026.09.11 CHANGELOG claim, or restore `reports/v2026.09.11/`.
4. **Point shipped URLs at `uthsarad/NeOS`** (os-release, branding.desc, profiledef) or enable
   Issues on the fork — this is user-visible in every install.
5. **Fix the doc drift in section 4** (HANDBOOK, BOOTSTRAP, TROUBLESHOOTING comment, duplicate
   Calamares module, `docs/README.md` / link targets, `CLAUDE.md` references).
6. **Make the CI gates real** (O3/H3: install ruby/go/dotnet, run `cargo test`), then
   **unify the build paths** (O2/C2) and **harden the smoke test** (H4).
7. Regenerate `graphify-out/` once 1–5 have landed, so the graph describes the final tree.
