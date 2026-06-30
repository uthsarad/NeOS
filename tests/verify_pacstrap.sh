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
    echo "✅ sequence runs shellprocess@pacstrap"
else
    echo "❌ sequence does not run shellprocess@pacstrap"; FAIL=1
fi
if grep -qE '^\s*-\s*unpackfs\s*$' "$SETTINGS"; then
    echo "❌ sequence still runs unpackfs (live clone) — should be removed"; FAIL=1
else
    echo "✅ no unpackfs (live clone) in sequence"
fi

# 2. The pacstrap shellprocess instance is declared and points at the backend.
if grep -q "config:   pacstrap.conf" "$SETTINGS" || grep -q "config: *pacstrap.conf" "$SETTINGS"; then
    echo "✅ pacstrap instance declared in settings.conf"
else
    echo "❌ pacstrap instance not declared in settings.conf"; FAIL=1
fi
if [[ -f "$PACSTRAP_CONF" ]] && grep -q "neos-pacstrap \${ROOT}" "$PACSTRAP_CONF"; then
    echo "✅ pacstrap.conf invokes neos-pacstrap with \${ROOT}"
else
    echo "❌ pacstrap.conf missing or does not invoke neos-pacstrap \${ROOT}"; FAIL=1
fi
if grep -q "dontChroot: true" "$PACSTRAP_CONF" 2>/dev/null; then
    echo "✅ pacstrap runs on the host (dontChroot: true)"
else
    echo "❌ pacstrap must run with dontChroot: true (installs INTO target)"; FAIL=1
fi

# 3. Backend script actually pacstraps.
if [[ -f "$PACSTRAP_BIN" ]] && grep -q "pacstrap -K" "$PACSTRAP_BIN"; then
    echo "✅ neos-pacstrap runs 'pacstrap -K'"
else
    echo "❌ neos-pacstrap missing or does not run pacstrap"; FAIL=1
fi

# 4. Generated package list exists, is non-trivial, and excludes live-only pkgs.
if [[ -f "$PKGLIST" ]]; then
    count=$(grep -vcE '^\s*(#|$)' "$PKGLIST")
    if [[ "$count" -ge 20 ]]; then
        echo "✅ neos-packages.txt has $count packages"
    else
        echo "❌ neos-packages.txt looks too small ($count packages)"; FAIL=1
    fi
    for must in base linux-lts grub sddm plasma-desktop; do
        grep -qxE "$must" "$PKGLIST" || { echo "❌ neos-packages.txt missing '$must'"; FAIL=1; }
    done
    for forbidden in mkinitcpio-archiso calamares-garuda; do
        if grep -qxE "$forbidden" "$PKGLIST"; then
            echo "❌ neos-packages.txt should not install live-only '$forbidden'"; FAIL=1
        fi
    done
else
    echo "❌ neos-packages.txt not found (run build.sh to generate it)"; FAIL=1
fi

# 5. Backend applies the NeOS overlay (otherwise the install is vanilla Arch).
if grep -q "rsync -a --files-from=" "$PACSTRAP_BIN"; then
    echo "✅ neos-pacstrap applies the overlay via rsync"
else
    echo "❌ neos-pacstrap does not apply the NeOS overlay"; FAIL=1
fi

# 6. Overlay manifest exists, carries NeOS identity, and excludes live-/
#    installer-only and per-install-state files.
if [[ -f "$OVERLAY" ]]; then
    echo "✅ overlay manifest present ($(grep -cE '.' "$OVERLAY") files)"
    for must in \
        "etc/os-release" \
        "usr/share/backgrounds/neos-wallpaper.png" \
        "etc/systemd/system/neos-autoupdate.timer" \
        "etc/sysctl.d/90-neos-security.conf"; do
        grep -qxF "$must" "$OVERLAY" || { echo "❌ overlay missing NeOS file '$must'"; FAIL=1; }
    done
    # These must NEVER be copied to an installed system.
    for forbidden in \
        "etc/machine-id" \
        "etc/polkit-1/rules.d/49-nopasswd_calamares.rules" \
        "etc/mkinitcpio.conf" \
        "etc/sudoers.d/zz-live-wheel" \
        "usr/local/bin/neos-pacstrap"; do
        if grep -qxF "$forbidden" "$OVERLAY"; then
            echo "❌ overlay must NOT carry '$forbidden' to the installed system"; FAIL=1
        fi
    done
else
    echo "❌ overlay manifest not found (run build.sh to generate it)"; FAIL=1
fi

# 7. Every neos-* unit the installer enables must be delivered by the overlay,
#    otherwise services-systemd fails the install enabling a missing unit.
if [[ -f "$SERVICES" && -f "$OVERLAY" ]]; then
    while read -r unit; do
        base="${unit%.service}"; base="${base%.timer}"
        if grep -qxF "etc/systemd/system/${base}.service" "$OVERLAY" \
           || grep -qxF "etc/systemd/system/${base}.timer" "$OVERLAY"; then
            echo "✅ enabled unit '$unit' is delivered by the overlay"
        else
            echo "❌ installer enables '$unit' but no overlay file delivers it"; FAIL=1
        fi
    done < <(grep -oE 'name: *"neos-[^"]+"' "$SERVICES" | sed -E 's/.*"(neos-[^"]+)".*/\1/')
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "Netinstall verification FAILED."
    exit 1
fi
echo "Netinstall verification passed!"
