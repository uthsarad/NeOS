# Unattended install (cidata)

[← Back to Documentation Index](../README.md#documentation)

NeOS can install itself with no keyboard, the same idea as
[Omarchy's cidata autoinstall](https://github.com/omacom/omarchy-iso): attach a
second volume labelled `cidata` (or `NEOSCIDATA`) next to the live ISO, drop an
`autoinstall.yaml` on it, and the live session launches Calamares for you.

Nothing is wiped unless the file says `erase: true` **and** supplies a username
plus a password. A config without `erase` only pre-fills the installer.

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
pre-hashed shadow password can be supplied instead as `hashed_password`.

## What happens on boot

1. Plasma autostarts `neos-autoinstall apply`.
2. If a config with `erase: true` plus credentials is found, Calamares starts
   in `--unattended` mode and the welcome window stays closed.
3. Otherwise the welcome app opens as usual (with fields pre-filled when a
   partial config is present).

`neos-autoinstall` is live-media only. It is excluded from the installed-system
overlay, so a finished install does not keep looking for cidata.

## Probe it

```bash
neos-autoinstall probe
neos-autoinstall parse /path/to/autoinstall.yaml
```

`probe` prints `MODE=UNATTENDED`, `MODE=PREFILL`, or `MODE=NONE`.

## Safety

- No cidata volume → nothing happens, the GUI installer is unchanged.
- `erase: true` without a username/password → Calamares opens for review; it
  does **not** run unattended.
- Internet is no longer a hard Calamares requirement: a local ISO with an
  embedded package repo (`sudo ./build.sh`) can finish offline.
