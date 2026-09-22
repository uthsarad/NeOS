# Graph Report - .  (2026-09-18)

> **Snapshot, not current output.** Generated 2026-09-18. It predates the changes
> recorded in `CHANGELOG.md` under [2026.09.22], the relocation of the agent reports
> into `reports/v2026.09.11/` and `reports/v2026.09.22/`, and the removal of the ISO
> size gate. The manifest covers 192 files; files added since (`.github/dependabot.yml`,
> most of `etc/calamares/modules/`, the SDDM `Main.qml`, the pacman hooks, …) are
> absent, and the community list still contains "ISO Size And Audit History".
> Regenerate with the `graphify` tool (`graphify-out/README.md`) before relying on the
> counts, communities or edges below.

## Corpus Check
- 192 files · ~209,712 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 372 nodes · 422 edges · 77 communities (19 shown, 58 thin omitted)
- Extraction: 92% EXTRACTED · 6% INFERRED · 2% AMBIGUOUS · INFERRED: 25 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Rust Profile Auditor
- Build And ISO Validation
- Architecture And Boot Docs
- ADRs And Mission
- ISO Size And Audit History
- Secure Boot Setup
- CI Release Pipeline
- C# Diagnostics Tool
- Autoupdate And Snapshots
- Welcome App
- Display Sync
- Go Mirror Ranker
- Contribution And Auto-Merge
- Bootlogo Asset Pipeline
- Ruby Task Runner
- Calamares Pacstrap Module
- Calamares Module (etc copy)
- Driver Manager
- Netinstall Pacstrap Backend
- Wallpaper Asset Pipeline
- Live User Setup
- Welcome Launcher
- Branding Alpha Fixer
- VM Appliance Generator
- Dotnet Project Config
- Accessibility Helper
- Desktop Setup
- Hardware Setup
- Operations Hub
- VM Graphics
- Service Hardening Test
- Issue Body Interpolation Into AI Prompt
- Path-Based Labeler Rules
- customize_airootfs.sh
- chcon
- profiledef.sh
- Low Risk Posture Assertion
- verify_airootfs_structure.sh
- verify_autoupdate_security.sh
- verify_boot_gui.sh
- verify_build_profile.sh
- verify_calamares_defaults.sh
- verify_cleanup.sh
- verify_csharp_diagnostics.sh
- verify_discover_config.sh
- verify_display_sync.sh
- verify_go_neosctl.sh
- verify_grub_config.sh
- verify_grub_theme.sh
- verify_hardware_setup.sh
- verify_live_graphical_target.sh
- verify_manifest_drift.sh
- verify_mirrorlist_connectivity.sh
- verify_mirrorlist_retry_counter.sh
- verify_mkinitcpio.sh
- verify_module_matching.sh
- verify_operations_hub.sh
- verify_pacstrap.sh
- verify_palette_consistency.sh
- verify_performance_config.sh
- verify_qml_enhancements.sh
- verify_ruby_tasks.sh
- verify_rust_profile_audit.sh
- verify_sddm_theme.sh
- verify_security_autologin.sh
- verify_security_config.sh
- verify_shellcheck.sh
- verify_ssh_config.sh
- verify_sudoers_fix.sh
- verify_syslinux_config.sh
- verify_ufw.sh
- verify_umount_prep.sh
- verify_ux_polish.sh
- verify_welcome_app.sh
- neos-sync.sh
- github.com/uthsarad/NeOS/tools/neosctl

## God Nodes (most connected - your core abstractions)
1. `assert_profiledef_properties()` - 13 edges
2. `run_audit()` - 12 edges
3. `build.sh script` - 8 edges
4. `NeOS (Next Evolution Operating System)` - 8 edges
5. `main()` - 7 edges
6. `parse_package_file()` - 7 edges
7. `Build NeOS ISO Workflow` - 7 edges
8. `log()` - 5 edges
9. `DiagnosticReport` - 5 edges
10. `assert_required_files()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `CI Builds On Main Branch Claim` --conceptually_related_to--> `Build NeOS ISO Workflow`  [AMBIGUOUS]
  README.md → .github/workflows/build-iso.yml
- `Evolve Forward Brand Ethos` --rationale_for--> `NeOS (Next Evolution Operating System)`  [INFERRED]
  docs/architecture/BRAND_STRUCTURE.md → README.md
- `NeOS Security Policy` --references--> `NeOS (Next Evolution Operating System)`  [INFERRED]
  SECURITY.md → README.md
- `Offline Install Claim` --conceptually_related_to--> `Inline mkarchiso Build Path`  [AMBIGUOUS]
  README.md → .github/workflows/build-iso.yml
- `ISO Size Budget (< 2.5GB target, 4GB hard limit)` --conceptually_related_to--> `Sub-2GB ISO Footprint Claim`  [AMBIGUOUS]
  docs/architecture/PERFORMANCE.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **ISO Size Budget Constraint** — readme_sub_2gb_iso_claim, changelog_two_tier_placement, changelog_xz_compression_switch [INFERRED 0.85]
- **CI Release Pipeline** — github_workflows_build_iso, github_workflows_build_iso_codename, github_workflows_build_iso_sourceforge, changelog_neos_changelog [EXTRACTED 1.00]
- **Core Architecture ADR Set** — docs_decisions_0001_linux_lts, docs_decisions_0002_btrfs_snapper, docs_decisions_0003_calamares, docs_decisions_0004_plasma_meta, docs_decisions_0005_parallel_downloads [INFERRED 0.95]
- **ISO Size Constraint Contradiction Cluster** — docs_architecture_performance_iso_size_budget, docs_decisions_0006_size_limit_enforced_claim, docs_archive_audit_action_plan_iso_size_gate, readme_sub_2gb_iso_claim [INFERRED 0.85]

## Communities (77 total, 58 thin omitted)

### Community 0 - "Rust Profile Auditor"
Cohesion: 0.18
Nodes (25): ExitCode, HashSet, Path, PathBuf, Result, String, assert_arch_specific_expectations(), assert_mirrorlists_have_servers() (+17 more)

### Community 1 - "Build And ISO Validation"
Cohesion: 0.11
Nodes (14): neos_fetch_chaotic(), PATH, build.sh script, verify_iso_calamares_libs.sh script, skip_or_fail(), verify_iso_grub.sh script, boot_log_is_clean(), run_boot() (+6 more)

### Community 2 - "Architecture And Boot Docs"
Cohesion: 0.10
Nodes (21): NeOS Curated And Staging Repos, NeOS Architecture Document, Curated Repo Topology vs Shipped Config, Six-Layer System Model, Boot Flow (GRUB/Syslinux), Bootloader And Initramfs Defaults, GRUB Preload Modules, ZFS Boot Support Claim (+13 more)

### Community 3 - "ADRs And Mission"
Cohesion: 0.12
Nodes (20): Evolve Forward Brand Ethos, Audit Consolidation To Rust Auditor, Manifest Drift Guard, NeOS Brand Structure, ADR 0001 Core Architecture Decisions, NeOS Mission and Identity, Not A Thin Arch Wrapper, Removed Features (+12 more)

### Community 4 - "ISO Size And Audit History"
Cohesion: 0.12
Nodes (20): Two-Tier Package Placement, Squashfs xz/BCJ Compression Switch, Cold Boot Time Budget (< 10s target), Performance Budgets, ISO Size Budget (< 2.5GB target, 4GB hard limit), Audit Quick Action Plan, Proposed ISO Size Validation CI Step, Deep Audit Report (2026-04-01) (+12 more)

### Community 5 - "Secure Boot Setup"
Cohesion: 0.24
Nodes (18): neos-secureboot-setup script, check_root(), check_sbctl(), check_uefi(), create_keys_if_needed(), detect_setup_mode(), enroll_keys(), find_efi_files() (+10 more)

### Community 6 - "CI Release Pipeline"
Cohesion: 0.12
Nodes (16): Bolt Specialist Report, NeOS Changelog, CC_GodMode Orchestrator Framework, reports/vX.X.X Report Convention, Smart Routing Policy, Version-First Rule, Build NeOS ISO Workflow, Claude-Generated Fish Codename (+8 more)

### Community 7 - "C# Diagnostics Tool"
Cohesion: 0.21
Nodes (8): Neos.Diagnostics, DateTime, List, Task, Program, DiagnosticCheck, DiagnosticReport, SecurityInspector

### Community 8 - "Autoupdate And Snapshots"
Cohesion: 0.36
Nodes (10): check_btrfs(), check_dependencies(), check_disk_space(), check_root(), log(), main(), notify_users(), PATH (+2 more)

### Community 9 - "Welcome App"
Cohesion: 0.24
Nodes (4): get_os_version(), is_live_mode(), NeosWelcome, QWidget

### Community 10 - "Display Sync"
Cohesion: 0.31
Nodes (7): neos-display-sync script, apply_scale(), PATH, print_help(), rotate_display(), run_daemon(), sync_rotation()

### Community 11 - "Go Mirror Ranker"
Cohesion: 0.43
Nodes (6): Duration, MirrorResult, main(), printUsage(), runInfo(), runRankMirrors()

### Community 12 - "Contribution And Auto-Merge"
Cohesion: 0.40
Nodes (6): NeOS Code of Conduct, Auto-Merge Bot Policy, NeOS Contributing Guide, Admin Merge Bypass, Jules Auto-Merge Workflow, Pull Request Review Approval Gate

### Community 13 - "Bootlogo Asset Pipeline"
Cohesion: 0.40
Nodes (5): main(), _mode_pixel(), Return a hashable key for an RGBA pixel tuple., Return the most common RGBA value from a list of pixel tuples., _rgba_key()

### Community 17 - "Driver Manager"
Cohesion: 0.50
Nodes (3): neos-driver-manager script, is_loaded(), PATH

### Community 18 - "Netinstall Pacstrap Backend"
Cohesion: 1.00
Nodes (4): neos-pacstrap script, do_offline_install(), log(), run_pacstrap_with_retry()

### Community 21 - "Welcome Launcher"
Cohesion: 0.67
Nodes (3): neos-welcome script, notify_error(), PATH

### Community 22 - "Branding Alpha Fixer"
Cohesion: 0.67
Nodes (3): circle_cut(), PATH, fix-branding-alpha.sh script

## Ambiguous Edges - Review These
- `Offline Install Claim` → `Inline mkarchiso Build Path`  [AMBIGUOUS]
  README.md · relation: conceptually_related_to
- `CI Builds On Main Branch Claim` → `Build NeOS ISO Workflow`  [AMBIGUOUS]
  README.md · relation: conceptually_related_to
- `Sub-2GB ISO Footprint Claim` → `ISO Size Budget (< 2.5GB target, 4GB hard limit)`  [AMBIGUOUS]
  docs/architecture/PERFORMANCE.md · relation: conceptually_related_to
- `Admin Merge Bypass` → `Pull Request Review Approval Gate`  [AMBIGUOUS]
  .github/workflows/jules-auto-merge.yml · relation: conceptually_related_to
- `NeOS Curated And Staging Repos` → `Curated Repo Topology vs Shipped Config`  [AMBIGUOUS]
  docs/architecture/ARCHITECTURE.md · relation: conceptually_related_to
- `ZFS Boot Support Claim` → `GRUB Preload Modules`  [AMBIGUOUS]
  docs/architecture/BOOTLOADER.md · relation: conceptually_related_to
- `Repository As Archiso Profile` → `Handbook Root-Level Path Assumption`  [AMBIGUOUS]
  docs/user-guide/HANDBOOK.md · relation: conceptually_related_to
- `Proposed ISO Size Validation CI Step` → `2 GiB ISO Limit Enforced Claim`  [AMBIGUOUS]
  docs/decisions/0006-ubuntu-parity-capabilities.md · relation: conceptually_related_to
- `Installed System Uses DatabaseRequired Claim` → `Two Separate Pacman Configurations Model`  [AMBIGUOUS]
  docs/archive/DEEP_AUDIT.md · relation: conceptually_related_to
- `NeOS Handbook` → `Handbook Root-Level Path Assumption`  [AMBIGUOUS]
  docs/user-guide/HANDBOOK.md · relation: references

## Knowledge Gaps
- **85 isolated node(s):** `PATH`, `customize_airootfs.sh script`, `PATH`, `profiledef.sh script`, `verify_airootfs_structure.sh script` (+80 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **58 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Offline Install Claim` and `Inline mkarchiso Build Path`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `CI Builds On Main Branch Claim` and `Build NeOS ISO Workflow`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Sub-2GB ISO Footprint Claim` and `ISO Size Budget (< 2.5GB target, 4GB hard limit)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Admin Merge Bypass` and `Pull Request Review Approval Gate`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `NeOS Curated And Staging Repos` and `Curated Repo Topology vs Shipped Config`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `ZFS Boot Support Claim` and `GRUB Preload Modules`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Repository As Archiso Profile` and `Handbook Root-Level Path Assumption`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._