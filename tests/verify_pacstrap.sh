#!/bin/bash
# Verify the netinstall (pacstrap) installer wiring.
#
# NeOS installs by pacstrapping a fresh base from the repos, NOT by cloning the
# live squashfs. This guards that the Calamares sequence, the neospacstrap
# python job module, the backend script and the generated package list are
# all consistent.
set -euo pipefail

SETTINGS="profile/airootfs/etc/calamares/settings.conf"
MODULE_DESC="profile/airootfs/etc/calamares/modules/neospacstrap/module.desc"
MODULE_MAIN="profile/airootfs/etc/calamares/modules/neospacstrap/main.py"
PACSTRAP_BIN="profile/airootfs/usr/local/bin/neos-pacstrap"
PKGLIST="profile/airootfs/etc/calamares/neos-packages.txt"
OVERLAY="profile/airootfs/etc/calamares/neos-overlay.txt"
SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
FAIL=0

echo "Verifying netinstall (pacstrap) installer configuration..."

# 1. Sequence runs the pacstrap step and NOT the old live-clone unpackfs.
if grep -qE '^\s*-\s*neospacstrap\s*$' "$SETTINGS"; then
    echo "✅ sequence runs neospacstrap"
else
    echo "❌ sequence does not run neospacstrap"; FAIL=1
fi
if grep -qE '^\s*-\s*unpackfs\s*$' "$SETTINGS"; then
    echo "❌ sequence still runs unpackfs (live clone) — should be removed"; FAIL=1
else
    echo "✅ no unpackfs (live clone) in sequence"
fi

# 2. The neospacstrap python job module is declared and points at the backend.
if [[ -f "$MODULE_DESC" ]] && grep -q '"job"' "$MODULE_DESC" && grep -q '"python"' "$MODULE_DESC"; then
    echo "✅ neospacstrap module.desc declares a python job module"
else
    echo "❌ neospacstrap module.desc missing or malformed"; FAIL=1
fi
if [[ -f "$MODULE_MAIN" ]] && grep -q '"/usr/local/bin/neos-pacstrap"' "$MODULE_MAIN" && grep -q "rootMountPoint" "$MODULE_MAIN"; then
    echo "✅ neospacstrap main.py invokes neos-pacstrap with the target root"
else
    echo "❌ neospacstrap main.py missing or does not invoke neos-pacstrap"; FAIL=1
fi
if [[ -f "$MODULE_MAIN" ]] && grep -q "setprogress" "$MODULE_MAIN"; then
    echo "✅ neospacstrap reports live install progress (job.setprogress)"
else
    echo "❌ neospacstrap does not report progress — installer will look stuck"; FAIL=1
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
    PKGLIST_CONTENT=$(<"$PKGLIST")
    for must in base linux-lts grub sddm plasma-desktop; do
        if [[ "$PKGLIST_CONTENT" =~ (^|$'
')"$must"($|$'
') ]]; then
            : # MATCHED
        else
            echo "❌ neos-packages.txt missing '$must'"; FAIL=1;
        fi
    done
    for forbidden in mkinitcpio-archiso calamares-garuda; do
        if [[ "$PKGLIST_CONTENT" =~ (^|$'
')"$forbidden"($|$'
') ]]; then
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
            echo "❌ overlay missing NeOS file '$must'"; FAIL=1;
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
