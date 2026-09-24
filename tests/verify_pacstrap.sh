#!/bin/bash
# Verify the netinstall (pacstrap) installer wiring.
#
# NeOS installs by pacstrapping a fresh base from the repos, NOT by cloning the
# live squashfs. This guards that the Calamares sequence, the neospacstrap
# Python job module, the backend script and the generated package list are
# all consistent.
set -euo pipefail

SETTINGS="profile/airootfs/etc/calamares/settings.conf"
NEOSPACSTRAP_DESC="profile/airootfs/etc/calamares/modules/neospacstrap/module.desc"
NEOSPACSTRAP_MAIN="profile/airootfs/etc/calamares/modules/neospacstrap/main.py"
NEOSPACSTRAP_LIB_DESC="profile/airootfs/usr/lib/calamares/modules/neospacstrap/module.desc"
NEOSPACSTRAP_LIB_MAIN="profile/airootfs/usr/lib/calamares/modules/neospacstrap/main.py"
PACSTRAP_BIN="profile/airootfs/usr/local/bin/neos-pacstrap"
PKGLIST="profile/airootfs/etc/calamares/neos-packages.txt"
LIVE_PKGLIST="profile/packages.x86_64"
OVERLAY="profile/airootfs/etc/calamares/neos-overlay.txt"
SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
FAIL=0

echo "Verifying netinstall (pacstrap) installer configuration..."

# 1. Sequence runs the pacstrap step and NOT the old live-clone unpackfs.
if grep -qE 'shellprocess@pacstrap|neospacstrap' "$SETTINGS"; then
    echo "  [PASS] sequence runs pacstrap"
else
    echo "[FAIL] sequence does not run pacstrap"; FAIL=1
fi
if grep -qE '^\s*-\s*unpackfs\s*$' "$SETTINGS"; then
    echo "[FAIL] sequence still runs unpackfs (live clone) — should be removed"; FAIL=1
else
    echo "  [PASS] no unpackfs (live clone) in sequence"
fi

# Ensure modules-search includes system module path and etc module path
if grep -q "/usr/lib/calamares/modules" "$SETTINGS" && grep -q "/etc/calamares/modules" "$SETTINGS"; then
    echo "  [PASS] settings.conf includes explicit module search paths (/usr/lib and /etc)"
else
    echo "[FAIL] settings.conf missing explicit module search paths"; FAIL=1
fi

# 2. The neospacstrap Python job module is declared in usr/lib and etc, and points at the backend.
if [[ -f "$NEOSPACSTRAP_LIB_DESC" && -f "$NEOSPACSTRAP_DESC" ]] && grep -q 'interface:.*"python"' "$NEOSPACSTRAP_LIB_DESC"; then
    echo "  [PASS] neospacstrap/module.desc declares a python job in /usr/lib and /etc"
else
    echo "[FAIL] neospacstrap/module.desc missing from /usr/lib or not a python job"; FAIL=1
fi
# The job code lives in exactly one place: /usr/lib/calamares/modules (first
# entry in settings.conf's modules-search, and the copy profiledef.sh grants
# 0:0:755). /etc/calamares/modules is the *second* search path, so its copy is
# a relative symlink rather than a hand-maintained duplicate — two copies of an
# installer job is how a fix silently fails to take effect depending on search
# order (reports/v2026.09.18 M1 / UPDATES_NEEDED §4.5).
if [[ -f "$NEOSPACSTRAP_LIB_MAIN" && -f "$NEOSPACSTRAP_LIB_DESC" ]]; then
    for pair in "main.py" "module.desc"; do
        etc_copy="$(dirname "$NEOSPACSTRAP_MAIN")/$pair"
        lib_copy="$(dirname "$NEOSPACSTRAP_LIB_MAIN")/$pair"
        if [[ ! -e "$etc_copy" ]]; then
            echo "[FAIL] /etc/calamares/modules/neospacstrap/$pair is missing"; FAIL=1
        elif [[ -L "$etc_copy" ]]; then
            if [[ "$(readlink -f "$etc_copy")" == "$(readlink -f "$lib_copy")" ]]; then
                echo "  [PASS] /etc copy of $pair is a symlink to the single canonical /usr/lib copy"
            else
                echo "[FAIL] /etc/calamares/modules/neospacstrap/$pair points at $(readlink "$etc_copy"), not the canonical /usr/lib copy"; FAIL=1
            fi
        elif cmp -s "$etc_copy" "$lib_copy"; then
            echo "  [PASS] /etc and /usr/lib copies of $pair are byte-identical (unsymlinked copy)"
        else
            echo "[FAIL] the /etc and /usr/lib neospacstrap copies of $pair have diverged"
            diff -u "$lib_copy" "$etc_copy" | head -20 || true
            FAIL=1
        fi
    done
else
    echo "[FAIL] neospacstrap main.py/module.desc missing from /usr/lib"; FAIL=1
fi
if [[ -f "$NEOSPACSTRAP_MAIN" ]] && grep -q '/usr/local/bin/neos-pacstrap' "$NEOSPACSTRAP_MAIN"; then
    echo "  [PASS] neospacstrap/main.py invokes neos-pacstrap"
else
    echo "[FAIL] neospacstrap/main.py missing or does not invoke neos-pacstrap"; FAIL=1
fi
if [[ -f "$NEOSPACSTRAP_MAIN" ]] && grep -q 'globalstorage.value("rootMountPoint")' "$NEOSPACSTRAP_MAIN"; then
    echo "  [PASS] neospacstrap reads the target root from rootMountPoint (runs on the host, installs INTO target)"
else
    echo "[FAIL] neospacstrap must read rootMountPoint from global storage"; FAIL=1
fi
if [[ -f "$NEOSPACSTRAP_MAIN" ]] && grep -q 'job.setprogress' "$NEOSPACSTRAP_MAIN"; then
    echo "  [PASS] neospacstrap reports incremental progress"
else
    echo "[FAIL] neospacstrap does not report progress — back to an opaque black-box job"; FAIL=1
fi

# 3. Backend script actually pacstraps.
if [[ -f "$PACSTRAP_BIN" ]] && grep -q "pacstrap -K" "$PACSTRAP_BIN"; then
    echo "  [PASS] neos-pacstrap runs 'pacstrap -K'"
else
    echo "[FAIL] neos-pacstrap missing or does not run pacstrap"; FAIL=1
fi

# 3b. The config reaches pacstrap in the only form it understands: short
# options BEFORE the root (`pacstrap [options] root [packages...]`, getopts
# style, no long options). A trailing `--config` would be treated as a
# package name — failing the install while silently ignoring the offline
# repo, which is exactly how offline installs broke.
if grep -qE 'pacstrap[[:space:]]+.*--config' "$PACSTRAP_BIN"; then
    echo "[FAIL] neos-pacstrap passes '--config' to pacstrap, which only understands '-C' before the root"; FAIL=1
elif grep -qE 'pacstrap +-K +-C ' "$PACSTRAP_BIN"; then
    echo "  [PASS] neos-pacstrap passes its config as '-C' before the root"
else
    echo "[FAIL] neos-pacstrap does not pass '-C <conf>' to pacstrap"; FAIL=1
fi

# 4. Generated package list exists, is non-trivial, and excludes live-only pkgs.
if [[ -f "$PKGLIST" ]]; then
    count=$(grep -vcE '^\s*(#|$)' "$PKGLIST")
    if [[ "$count" -ge 20 ]]; then
        echo "  [PASS] neos-packages.txt has $count packages"
    else
        echo "[FAIL] neos-packages.txt looks too small ($count packages)"; FAIL=1
    fi
    # The manifest is derived from profile/packages.x86_64, so the same package
    # legitimately appears in both files — but a repeated entry *inside* either
    # list would make pacstrap/auditing see a package twice (reports/v2026.09.18
    # M1). Nothing checked that until now.
    DUPES=$(grep -vE '^\s*(#|$)' "$PKGLIST" | LC_ALL=C sort | uniq -d)
    if [[ -z "$DUPES" ]]; then
        echo "  [PASS] neos-packages.txt has no duplicate entries"
    else
        echo "[FAIL] neos-packages.txt contains duplicate entries:"; while IFS= read -r d; do printf '       %s\n' "$d"; done <<<"$DUPES"; FAIL=1
    fi
    DUPES_LIVE=$(grep -vE '^\s*(#|$)' "$LIVE_PKGLIST" | LC_ALL=C sort | uniq -d)
    if [[ -z "$DUPES_LIVE" ]]; then
        echo "  [PASS] $LIVE_PKGLIST has no duplicate entries"
    else
        echo "[FAIL] $LIVE_PKGLIST contains duplicate entries:"; while IFS= read -r d; do printf '       %s\n' "$d"; done <<<"$DUPES_LIVE"; FAIL=1
    fi

    PKGLIST_CONTENT=$(<"$PKGLIST")
    for must in base linux-lts grub sddm plasma-desktop; do
        if [[ "$PKGLIST_CONTENT" =~ (^|$'
')"$must"($|$'
') ]]; then
            : # MATCHED
        else
            echo "[FAIL] neos-packages.txt missing '$must'"; FAIL=1;
        fi
    done
    for forbidden in mkinitcpio-archiso calamares-garuda; do
        if [[ "$PKGLIST_CONTENT" =~ (^|$'
')"$forbidden"($|$'
') ]]; then
            echo "[FAIL] neos-packages.txt should not install live-only '$forbidden'"; FAIL=1
        fi
    done
else
    echo "[FAIL] neos-packages.txt not found (run build.sh to generate it)"; FAIL=1
fi

# 5. Backend applies the NeOS overlay (otherwise the install is vanilla Arch).
if grep -q "rsync -a --files-from=" "$PACSTRAP_BIN"; then
    echo "  [PASS] neos-pacstrap applies the overlay via rsync"
else
    echo "[FAIL] neos-pacstrap does not apply the NeOS overlay"; FAIL=1
fi

# 6. Overlay manifest exists, carries NeOS identity, and excludes live-/
#    installer-only and per-install-state files.
if [[ -f "$OVERLAY" ]]; then
    echo "  [PASS] overlay manifest present ($(grep -cE '.' "$OVERLAY") files)"
    OVERLAY_CONTENT=$'
'"$(<"$OVERLAY")"$'
'
    for must in \
        "etc/os-release" \
        "usr/share/backgrounds/neos-wallpaper.png" \
        "etc/systemd/system/neos-autoupdate.timer" \
        "etc/sysctl.d/90-neos-security.conf"; do
        if [[ "$OVERLAY_CONTENT" == *$'
'"$must"$'
'* ]]; then
            : # MATCHED
        else
            echo "[FAIL] overlay missing NeOS file '$must'"; FAIL=1;
        fi
    done
    # These must NEVER be copied to an installed system.
    for forbidden in \
        "etc/machine-id" \
        "etc/polkit-1/rules.d/49-nopasswd_calamares.rules" \
        "etc/mkinitcpio.conf" \
        "etc/sudoers.d/zz-live-wheel" \
        "usr/local/bin/neos-pacstrap"; do
        if [[ "$OVERLAY_CONTENT" == *$'
'"$forbidden"$'
'* ]]; then
            echo "[FAIL] overlay must NOT carry '$forbidden' to the installed system"; FAIL=1
        fi
    done
else
    echo "[FAIL] overlay manifest not found (run build.sh to generate it)"; FAIL=1
fi

# 7. Every neos-* unit the installer enables must be delivered by the overlay,
#    otherwise services-systemd fails the install enabling a missing unit.
if [[ -f "$SERVICES" && -f "$OVERLAY" ]]; then
    while read -r unit; do
        base="${unit%.service}"; base="${base%.timer}"
        if grep -qxF "etc/systemd/system/${base}.service" "$OVERLAY" \
           || grep -qxF "etc/systemd/system/${base}.timer" "$OVERLAY"; then
            echo "  [PASS] enabled unit '$unit' is delivered by the overlay"
        else
            echo "[FAIL] installer enables '$unit' but no overlay file delivers it"; FAIL=1
        fi
    done < <(grep -oE 'name: *"neos-[^"]+"' "$SERVICES" | sed -E 's/.*"(neos-[^"]+)".*/\1/')
fi

# 8. Every vendor unit the installer enables must have its package in the
# install manifest, otherwise the enable fails on a unit that was never
# installed (this caught ModemManager being enabled while modemmanager was
# in neither package list). neos-* units are covered by section 7 above;
# fstrim.timer ships with util-linux via `base`, and graphical.target is a
# target, not a unit — neither needs a manifest entry.
if [[ -f "$SERVICES" && -f "$PKGLIST" ]]; then
    while IFS='=' read -r unit pkg; do
        [[ -z "$unit" ]] && continue
        if grep -qE "name: *\"$unit\"" "$SERVICES"; then
            if grep -qxF "$pkg" <(grep -vE '^\s*(#|$)' "$PKGLIST"); then
                echo "  [PASS] enabled unit '$unit' has package '$pkg' in the manifest"
            else
                echo "[FAIL] installer enables '$unit' but '$pkg' is not in neos-packages.txt"; FAIL=1
            fi
        fi
    done <<'UNITMAP'
NetworkManager=networkmanager
bluetooth=bluez
sddm=sddm
ModemManager=modemmanager
ufw=ufw
cups.socket=cups
cups.path=cups
thermald=thermald
snapper-timeline.timer=snapper
snapper-cleanup.timer=snapper
vboxservice=virtualbox-guest-utils
vmtoolsd=open-vm-tools
qemu-guest-agent=qemu-guest-agent
spice-vdagentd=spice-vdagent
UNITMAP
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Netinstall verification FAILED."
    exit 1
fi
echo "Netinstall verification passed!"
