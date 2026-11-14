# Audit remediation — NeOS 2026.11.01

The defects recorded in `audit-2026-11-01.md` have been fixed in the working tree. No commit, push, or release was performed.

## Changes

- Assisted installation uses option-safe printf calls and a YAML-aware update of the actual shellprocess command list. Password commands preserve literal values, and generated configuration directories are private.
- Cidata mounting runs in the calling shell, retains cleanup records, unmounts udisks devices by block-device path, and leaves pre-existing mounts alone. Apply no longer writes a predictable shared probe file.
- `.gitattributes` enforces LF text checkouts, including extensionless Linux overlay scripts. Existing checkout text was normalized without changing unrelated committed content.
- The interactive Bash verification probe receives closed stdin so it cannot consume the audit runner's input. The structure gate now completes normally.
- Automatic integration merges require a successful pre-build test check, pin the validated head commit, and respect branch protections. Fork PRs still require a maintainer. Tests simulate success, failed CI, fork PRs, and stale heads without contacting GitHub.
- Workflow scanning preserves regular-expression escapes and runs actionlint with explicit filenames, so it works in isolated snapshots. Tests verify that direct untrusted expressions fail and an environment-variable boundary succeeds.
- The mirror connectivity probe has a realistic timeout. Version validation also covers the .NET assembly metadata, and all release stamps match 2026.11.01.

## Reusable tools

From Windows, run:

```powershell
python tools/audit.py --strict --include-ui --arch-container
```

Windows dispatches through WSL and tests a temporary snapshot of current working files, including uncommitted changes. Git executable and symlink modes are preserved. On Linux use `python3 tools/audit.py --snapshot` with the same other options.

The runner writes individual logs and `summary.json` to `reports/audit-latest/`. It bounds each check, terminates timed-out process groups, reports skipped coverage, and makes missing-tool fallbacks fail in strict mode. `--only verify_autoinstall_runtime.sh` selects a gate; `--output` chooses a separate report directory. The Arch container option requires Docker and uses a read-only source mount.

`sudo bash tools/install-audit-tools.sh` installs audit dependencies on Arch or Ubuntu, including language toolchains, PyYAML, ShellCheck, Qt rendering dependencies, and pinned actionlint. For this session, the missing dependencies were installed in WSL Ubuntu and the existing Arch Docker image supplied the Arch-only gate.

## Verification

The complete strict run with UI rendering and the Arch container returned:

- **61 passed**
- **0 failed, timed out, or incomplete**
- **3 explicitly skipped**: ISO Calamares libraries, ISO GRUB, and ISO smoke testing require a built image and run through `build.sh`.

Coverage included generated installer YAML, literal plaintext/hash password commands, new/reused/manual cidata mount lifecycle, audit reporting and timeout behavior, merge policy, workflow scanning, ShellCheck, actionlint, Rust execution/tests, Go compilation, .NET execution, Ruby checks, torrent generation, and offscreen Qt rendering. Stubbed command tests never touched real disks or user passwords.

This does not certify a booted or installed operating system. No ISO was built, no interactive installation was performed, and real Btrfs update/recovery behavior remains to be exercised in a disposable VM or on test hardware.
