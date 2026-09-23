# Assisted install (cidata)

[← Back to Documentation Index](../README.md#documentation)

NeOS can start its installer for you, the same idea as
[Omarchy's cidata autoinstall](https://github.com/omacom/omarchy-iso): attach a
second volume labelled `cidata` (or `NEOSCIDATA`) next to the live ISO, drop an
`autoinstall.yaml` on it, and the live session launches Calamares with your
identity pre-filled.

There is deliberately no zero-click mode: upstream Calamares has no
unattended CLI switch, so partitioning is always confirmed interactively.
Nothing is wiped unless you confirm it in the installer — a complete config
(`erase: true` plus a username and password) auto-launches Calamares and
pre-selects erase; anything less only pre-fills the fields.

## Where the config is read from

The live session looks in this order and uses the first hit:

1. A filesystem labelled `cidata`, `CIDATA`, `NEOSCIDATA`, or `neoscidata`
2. `/run/archiso/bootmnt/neos/autoinstall/` on the live ISO itself
3. `/run/archiso/bootmnt/autoinstall/`

Accepted filenames inside that directory: `autoinstall.yaml`,
`autoinstall.yml`, `autoinstall.conf`, `neos.yaml`,
`user_configuration.yaml`.

## Example

```yaml
hostname: neos-box
username: alice
fullname: Alice
password: change-me-now
locale: en_US
keyboard: us
timezone: UTC
erase: true
reboot: true
```

`password` must be 6+ characters from `[A-Za-z0-9._@%+=!-]` (no spaces or
shell metacharacters — it is applied with `chpasswd` in the target). A
pre-hashed shadow password can be supplied instead as `hashed_password`
(preferred for automation: it never appears in plaintext; it must be crypt
alphabet only, `[A-Za-z0-9./$=]`).

`locale`, `keyboard` and `timezone` are accepted and reported by `parse`, but
only `keyboard` is currently applied to the installer — locale and timezone
are picked on the installer's locale page. `disk` is accepted and reported
but not acted on: the target disk is always chosen in the partition page.

## What happens on boot

1. Plasma autostarts `neos-autoinstall apply` (the cidata volume is mounted
   with `udisks2`, so no root prompt is involved).
2. If a complete config (`erase: true` plus credentials) is found, Calamares
   auto-launches with identity and keyboard pre-filled, and the welcome
   window stays closed. You still step through and confirm partitioning.
3. Otherwise the welcome app opens as usual (with fields pre-filled when a
   partial config is present).

`neos-autoinstall` is live-media only. It is excluded from the installed-system
overlay, so a finished install does not keep looking for cidata.

## Probe it

```bash
neos-autoinstall probe
neos-autoinstall parse /path/to/autoinstall.yaml
```

`probe` prints `MODE=UNATTENDED` (complete config → auto-launch),
`MODE=PREFILL` (partial config → pre-fill only), or `MODE=NONE`. The
`UNATTENDED` name is historical: it means "ready to auto-launch", not
"zero-click" — partitioning is always confirmed.

## Safety

- No cidata volume → nothing happens, the GUI installer is unchanged.
- `erase: true` without a username/password → Calamares does not
  auto-launch; the welcome app opens with whatever was pre-filled.
- There is no silent disk wipe in any mode: Calamares always shows its
  partition page for confirmation.
- Internet is no longer a hard Calamares requirement: a local ISO with an
  embedded package repo (`sudo ./build.sh`) can finish offline.
