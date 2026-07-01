# NeOS v2026.07.01 — Cursor & Installer Investigation

Scope: `profile/airootfs/` (cursor/input + `etc/calamares/`, excluding branding `*.png`).
No commits, no pushes. Branding image files untouched.

---

## STATUS: DONE

- Problem 1 (stuck cursor): root cause identified and fixed.
- Problem 2 (installer lacks UI): gaps identified; welcome-page UI restored, stale
  strings corrected, dead sequence entry removed.

---

## PROBLEM 1 — "Mouse cursor sometimes gets stuck"

### Root cause
The live ISO autologs into the **Wayland** Plasma session, not X11.

`profile/airootfs/etc/sddm.conf.d/autologin.conf` shipped:

```
[Autologin]
User=liveuser
Session=plasma      # -> /usr/share/wayland-sessions/plasma.desktop  (Wayland)
```

Everything else in the project is deliberately forced to X11 because Wayland is
the least portable path:
- `sddm.conf.d/10-displayserver.conf` -> `DisplayServer=x11` (this only forces the
  **greeter** to X11; it does **not** change the autologin session — confirmed via
  SDDM docs / ArchWiki: `DisplayServer` is the greeter server, `[Autologin] Session`
  is a separate session desktop-file name).
- `modules/displaymanager.conf` -> installed system defaults to `startplasma-x11`.
- CHANGELOG 2026.06.24 documents the whole "ship X11, autologin plasmax11" decision.

So the autologin session was the one remaining Wayland hold-out. KWin on Wayland
has **no uncomposited mode**: on a GPU that can't get hardware GL (marginal/hybrid
GPUs, NVIDIA/nouveau, VMs without 3D) it composites through llvmpipe, the desktop
paints once and input is never serviced — the mouse **cursor freezes / gets stuck**
and buttons appear dead. This exact failure mode is described in-repo by
`usr/local/bin/neos-liveuser-setup` (lines 45–52), but its mitigation
(`sed Session=plasma -> plasmax11`, remove the Wayland session, disable compositing)
is **gated to VMs only** (`systemd-detect-virt != none`). Bare-metal machines with a
marginal GPU therefore still autologin into Wayland and hit the stuck cursor.

Input driver is not the problem: `xf86-input-libinput` is present in the live
package list (`profile/packages.x86_64`); no synaptics/legacy driver conflict.

### Fix
`profile/airootfs/etc/sddm.conf.d/autologin.conf`: `Session=plasma` -> `Session=plasmax11`
(plus an explanatory comment). Now the live session autologins into X11 on **all**
hardware — the robust path a live installer needs — while Wayland stays selectable
from the SDDM session menu on capable hardware (per 10-displayserver.conf's own
stated intent). The VM branch in `neos-liveuser-setup` becomes a harmless no-op
(its `sed` now matches nothing; it still removes the Wayland session + disables
compositing in VMs).

Test safety: `tests/verify_live_graphical_target.sh` greps `Session=plasma`, which
is a prefix of `Session=plasmax11`, so the change still passes. No test edit needed.

Sources:
- SDDM — ArchWiki: https://wiki.archlinux.org/title/SDDM (X11 sessions in
  `/usr/share/xsessions`, Wayland in `/usr/share/wayland-sessions`; `[Autologin] Session`
  names the desktop file; greeter server is separate).
- KWin/Wayland software-rendering cursor freeze: KDE bug 452117
  (https://bugs.kde.org/show_bug.cgi?id=452117) and KWin env vars
  (https://community.kde.org/KWin/Environment_Variables).

---

## PROBLEM 2 — Installer UI gaps

### What was actually present (verified good)
The Calamares `show` sequence in `settings.conf` is the **complete** canonical set
and needed no page added:
`welcome, locale, keyboard, partition, users, summary` -> exec -> `finished`
(matches the upstream Calamares example — https://calamares.euroquis.nl/docs/deploy-configuration).
Slideshow (`show.qml`), stylesheet, sidebar/navigation widgets, and the core
branding strings were all present. The `users` page had been correctly restored in
the last public-installer change (commit 52ca474).

### Gaps found and fixed
1. **Welcome page had zero info buttons.** `welcome.conf` set every `show*Url`
   to `false`, and `branding.desc` `strings:` had **no** URL entries — so the
   welcome page rendered bare (no Support / Known Issues / Release Notes links a
   normal Calamares welcome page shows). Calamares reads the URL strings from
   `branding.desc` and the show* booleans from `welcome.conf`
   (https://github.com/calamares/calamares/blob/calamares/src/branding/README.md).
   Fixed by adding `supportUrl / knownIssuesUrl / releaseNotesUrl / productUrl`
   (real GitHub URLs from `etc/os-release`) to `branding.desc` and flipping the
   three show* booleans to `true` in `welcome.conf`. Donate left off (no donation
   page; otherwise Calamares falls back to the hardcoded KDE donate URL).

2. **Stale product version in the installer chrome.** `branding.desc` advertised
   `2026.06` (window title / welcome), while the release is `2026.07.01`. Bumped
   the four version strings to `2026.07`.

3. **Dead `liveuser` shellprocess instance.** `settings.conf` still declared the
   `liveuser` shellprocess instance (`liveuser-setup.conf` -> kiosk identity
   script) even though commit 52ca474 removed it from the run sequence when NeOS
   switched to a public multi-user installer. It was orphaned config (unused
   instance, harmless to Calamares but misleading / re-enable hazard). Removed the
   instance block. (The orphaned `usr/local/bin/neos-install-identity` and
   `modules/liveuser-setup.conf` scripts are outside the strict fix scope and left
   in place; noted below.)

### Notes / not changed
- `welcome.conf` keeps `required: - internet` (netinstall gate) — intended, not a
  UI defect.
- Orphaned kiosk artifacts still on disk (out of scope, cleanup candidates for a
  follow-up): `profile/airootfs/usr/local/bin/neos-install-identity`,
  `profile/airootfs/etc/calamares/modules/liveuser-setup.conf`.
- No package changes were required; `xf86-input-libinput`, `plasma-x11-session`,
  and `xorg-server` are already in `profile/packages.x86_64`.

---

## Files changed
| File | Change | Why |
|------|--------|-----|
| `profile/airootfs/etc/sddm.conf.d/autologin.conf` | `Session=plasma` -> `Session=plasmax11` (+comment) | Autologin into X11 everywhere so KWin doesn't freeze the cursor on marginal-GPU/bare-metal Wayland. |
| `profile/airootfs/etc/calamares/branding/neos/branding.desc` | Add support/knownIssues/releaseNotes/product URLs; version `2026.06`->`2026.07` | Restore welcome-page info buttons; fix stale installer version string. |
| `profile/airootfs/etc/calamares/modules/welcome.conf` | `showSupportUrl/showKnownIssuesUrl/showReleaseNotesUrl` -> `true` | Show the welcome-page info buttons (URLs now exist in branding). |
| `profile/airootfs/etc/calamares/settings.conf` | Remove dead `liveuser` shellprocess instance | Broken leftover from the public-installer switch; prevents re-running the abandoned kiosk script. |

Report path: `/home/nima/NeOS/reports/v2026.07.01/cursor-installer-report.md`
