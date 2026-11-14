# NeOS — Improvement Plan (2026.10.02)

**Snapshot:** `uthsarad/NeOS`, branch `testing` @ `6a87be7` (2026-10-01).
**Baseline:** all 51 `tests/verify_*.sh` pass locally (ShellCheck included — installed for
this review); `actionlint` reports one script-injection finding and one unused variable in
`build-iso.yml`. `VERSION` = `2026.09.23`, but 18 commits have landed since that bump
(the Omarchy integration, BitTorrent publishing, CodeQL autofixes) and none of them is in
`CHANGELOG.md`.

**Method:** whole-tree read, with emphasis on everything that changed since `b83dfbe` (the
2026.09.23 release); every test run before and after; upstream sources checked where a
finding depends on another project's behaviour (archinstall 4.5 `lib/args.py` and
`lib/models/device.py` at `archlinux/archinstall@6bda550`).

Items are ordered by severity. Each one names the evidence and the change. "Deferred"
items need a maintainer decision and are only documented here.

---

## A. Security and correctness

### A1. Installer credentials: CodeQL clear-text storage, and a silent loss of disk encryption — **critical**
`profile/airootfs/usr/share/neos-iso/orchestrator/context.py:107` (code-scanning alert 3).

- The Copilot autofix (`f8738a8`, `2273312`) strips every password-like key before writing
  `provisioning-user_credentials.json`. That file is what the orchestrator passes to archinstall
  as `--creds`. archinstall reads the LUKS passphrase **only** from the top-level
  `encryption_password` key of the merged config/creds (`args.py`, `ArchConfig.from_config`), and
  `DiskEncryption.parse_arg` returns `None` when no password is given (`device.py`). So after the
  autofix, an encrypted deferred-provisioning install would install **without encryption**, and
  nothing would report it.
- The same passphrase is still written in clear text, with default (0644) permissions, to
  `archinstall-user_configuration.json` (line 111, nested under `disk_config.disk_encryption`,
  where archinstall ignores it). The `# codeql[...]` comment does not suppress anything.
- The LUKS key files in `phases_impl.py` are written first and `chmod 0600`-ed afterwards, so
  each one is briefly world-readable.

**Change:** no secret is written to the state files any more. Both files are written secret-free
and created `0600` (`O_EXCL`, inside a `0700` state dir). The passphrase stays in memory and is
injected into archinstall's own parsed config through a small `ArchConfigHandler` subclass in the
adapter, which is the module whose job is to contain archinstall API churn. The key files that
exist by design (the first-boot re-key keyfile) are created `0600` atomically. New test:
`tests/verify_installer_secrets.sh` runs `InstallContext.from_env` in a sandbox and checks that
no file contains the passphrase and every file is `0600`. It also checks that the adapter
re-injects the passphrase, using a stub `archinstall` that mimics the upstream parsing contract.

### A2. Auto-merge lands pull requests from forks into the release branch — **high**
`.github/workflows/jules-auto-merge.yml` runs on `pull_request_target` for every non-draft PR
into `testing` and merges it with `--admin`. That includes PRs from forks, i.e. from anyone.
`testing` is the branch whose push builds and **publishes** releases (GitHub + SourceForge,
with secrets). As things stand, anyone with a GitHub account can ship code in a NeOS release.
**Change:** only auto-merge PRs whose head repository is this repository (collaborators with
push access); a fork PR gets a comment and waits for a maintainer. The `--admin` policy for
same-repository PRs is a stated maintainer choice and stays. Test and CONTRIBUTING updated.

### A3. `build-iso.yml` script injection and dead code — **high/medium**
- `${{ github.head_ref }}` is expanded directly into a `run:` script (actionlint
  `expression`). A branch name is attacker-controlled on a fork PR. **Change:** pass it via `env:`.
- The branch suffix is computed twice (lines 262–293). The first block is dead, and `VERSION`
  is unused (SC2034). **Change:** keep one sanitiser.
- The header comment says PRs run "the `test` job only". The `build` job comment says the
  opposite, and the latter is true. **Change:** correct the header.
- The torrent step picks `sort | head -1`, the first glob match that the 2026.09.22 M5 fix
  removed everywhere else. **Change:** pick the newest ISO by mtime, like the upload step.
- The SourceForge private key is written under the default umask. **Change:** `umask 077`.
- `"model": "claude-opus-5"` with `output_config.effort` for a 3-word codename: checked against
  the current model list (see implementation note in the review report).

### A4. Live-session services imported from the Arch `releng` profile conflict with NeOS — **high**
Added in `823c3d0` ("integrate omarchy configurations"):

| Unit | Problem |
| :-- | :-- |
| `getty@tty1.service.d/autologin.conf` | root shell auto-logged-in on tty1, which contradicts the liveuser-only live model that `verify_security_autologin.sh` describes |
| `multi-user.target.wants/sshd.service` | an SSH daemon in the live desktop session that nothing uses ("Secure by Default") |
| `systemd-networkd` (+ `.socket`, `-wait-online`, `dbus-org.freedesktop.network1` alias) | NetworkManager already owns networking. networkd manages no links, so `systemd-networkd-wait-online` holds `network-online.target` until its 120 s timeout on every boot |
| `cloud-init.target.wants/*` + the `cloud-init` package | cloud-init's NoCloud datasource reads the same `cidata` volume label that NeOS's autoinstall uses, so it would apply that volume's `user-data` to the live system (and to installed systems through its generator) |
| `livecd-talk.service`, `livecd-alsa-unmuter.service` | run on the `accessibility=on` boot entry and call `/usr/local/bin/livecd-sound`, which does not exist. `livecd-talk` switches to VT13 before it fails, so the post-step that switches back never runs. `neos-accessibility.service` already handles this entry |
| `choose-mirror.service` | calls `/usr/local/bin/choose-mirror`, which does not exist |

**Change:** remove these units (and `cloud-init` from the package list). New test
`tests/verify_live_services.sh` fails on any of them and on any shipped unit whose
`/usr/local/bin` `ExecStart*` target is missing from the overlay.

## B. Packaging

- **B1.** `profile/packages.x86_64` was re-sorted alphabetically in the Omarchy merge, so its 12
  section comments now sit next to unrelated packages (e.g. `# Desktop Environment` above
  `device-mapper`). **Change:** drop the orphaned headings and add a header that says the list is
  sorted.
- **B2.** `profile/pacman.conf` still promises "Size optimization: Exclude docs…" with no
  `NoExtract` (open item M11 since 2026.09.18). **Change:** remove the false comment.

## C. Repository hygiene, artefacts and docs

- **C1.** One-shot migration scripts at the repo root: `rename_omarchy.sh` and `replace_text.sh`.
  Re-running `replace_text.sh` would `sed -i` the whole overlay again. **Change:** delete.
  `gen_wp.py` (the generator of the shipped wallpaper) and `wallpaper.html` (its design
  reference) **move to `tools/`**. The old `tools/gen-wallpaper.py` no longer produces the
  shipped asset, so it is replaced, and the file it writes is unchanged.
- **C2.** `etc/skel/.config/neos/omarchy/` is a byte-identical copy of `etc/skel/.config/neos/`
  (a leftover of the rename). It lands in every new user's home. **Change:** delete it and
  regenerate the manifests.
- **C3.** Release paperwork: `VERSION` → `2026.10.02` in all five version sources, plus a
  CHANGELOG section covering the 18 undocumented commits and this work.
- **C4.** New `docs/architecture/OMARCHY_INTEGRATION.md`: what was imported, what is wired,
  and what is dormant. Indexed in `docs/README.md`. README test count and security bullet
  refreshed.
- **C5.** `build.sh` assumes it is started from the repo root (`REPO_ROOT="$PWD"`). **Change:**
  `cd` to the script's directory first.
- **C6.** New `tests/verify_workflow_security.sh`: no `${{ github.head_ref }}` or
  `${{ github.event.* }}` in `run:` blocks, auto-merge restricted to same-repo PRs, and
  `actionlint` when it is installed.

## Deferred (needs a maintainer decision; documented, not changed)

- **D1.** `profile/airootfs/usr/share/neos/neos/` (1.7 MB of Omarchy/Hyprland defaults), the
  Hyprland skel configs and `profile/packages_omarchy.x86_64`: nothing references them, and
  Hyprland is not in the package list. Either finish the Hyprland edition or drop them.
- **D2.** `usr/share/neos-iso/` + `neos-iso-install`: a second (archinstall-based) installer
  that nothing launches. Its defaults (`linux-neos` kernel, Limine) are rename artefacts of
  packages NeOS does not ship. A1 fixes its credential handling either way.
- **D3.** `graphify-out/` regeneration (still open from 2026.09.22 §2.4).
- **D4.** UFW rule set (M6) and the unattended Calamares test (O4), carried over.
