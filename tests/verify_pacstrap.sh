#!/bin/bash
# Verify the netinstall (pacstrap) installer wiring.
#
# NeOS installs by pacstrapping a fresh base from the repos, NOT by cloning the
# live squashfs. This guards that the Calamares sequence, the shellprocess
# module, the backend script and the generated package list are all consistent.
set -euo pipefail

SETTINGS="profile/airootfs/etc/calamares/settings.conf"
PACSTRAP_CONF="profile/airootfs/etc/calamares/modules/pacstrap.conf"
PACSTRAP_BIN="profile/airootfs/usr/local/bin/neos-pacstrap"
PKGLIST="profile/airootfs/etc/calamares/neos-packages.txt"
OVERLAY="profile/airootfs/etc/calamares/neos-overlay.txt"
SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
FAIL=0

echo "Verifying netinstall (pacstrap) installer configuration..."

# 1. Sequence runs the pacstrap step and NOT the old live-clone unpackfs.
if grep -q "shellprocess@pacstrap" "$SETTINGS"; then
    echo "  [PASS] sequence runs shellprocess@pacstrap"
else
    echo "[FAIL] sequence does not run shellprocess@pacstrap"; FAIL=1
fi
if grep -qE '^\s*-\s*unpackfs\s*$' "$SETTINGS"; then
    echo "[FAIL] sequence still runs unpackfs (live clone) — should be removed"; FAIL=1
else
    echo "  [PASS] no unpackfs (live clone) in sequence"
fi

# 2. The pacstrap shellprocess instance is declared and points at the backend.
if grep -q "config:   pacstrap.conf" "$SETTINGS" || grep -q "config: *pacstrap.conf" "$SETTINGS"; then
    echo "  [PASS] pacstrap instance declared in settings.conf"
else
    echo "[FAIL] pacstrap instance not declared in settings.conf"; FAIL=1
fi
if [[ -f "$PACSTRAP_CONF" ]] && grep -q "neos-pacstrap \${ROOT}" "$PACSTRAP_CONF"; then
    echo "[PASS] pacstrap.conf invokes neos-pacstrap with \${ROOT}"
else
    echo "[FAIL] pacstrap.conf missing or does not invoke neos-pacstrap \${ROOT}"; FAIL=1
fi
if grep -q "dontChroot: true" "$PACSTRAP_CONF" 2>/dev/null; then
    echo "  [PASS] pacstrap runs on the host (dontChroot: true)"
else
    echo "[FAIL] pacstrap must run with dontChroot: true (installs INTO target)"; FAIL=1
fi

# 3. Backend script actually pacstraps.
if [[ -f "$PACSTRAP_BIN" ]] && grep -q "pacstrap -K" "$PACSTRAP_BIN"; then
    echo "  [PASS] neos-pacstrap runs 'pacstrap -K'"
else
    echo "[FAIL] neos-pacstrap missing or does not run pacstrap"; FAIL=1
fi

# 4. Generated package list exists, is non-trivial, and excludes live-only pkgs.
if [[ -f "$PKGLIST" ]]; then
    count=$(grep -vcE '^\s*(#|$)' "$PKGLIST")
    if [[ "$count" -ge 20 ]]; then
        echo "  [PASS] neos-packages.txt has $count packages"
    else
        echo "[FAIL] neos-packages.txt looks too small ($count packages)"; FAIL=1
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

if [[ "$FAIL" -ne 0 ]]; then
    echo "Netinstall verification FAILED."
    exit 1
fi
echo "Netinstall verification passed!"
