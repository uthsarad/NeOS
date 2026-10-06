#!/bin/bash
# Live-session service set (reports/v2026.10.02/00-improvement-plan.md A4).
#
# The Omarchy integration imported the Arch `releng` profile's service set,
# which assumes a root console session, systemd-networkd and cloud images.
# NeOS's live session is a liveuser desktop on NetworkManager with its own
# cidata autoinstall, so those units conflict with it or call binaries that
# do not exist here. This keeps them out and checks that every shipped unit
# points at a binary the overlay actually ships.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="profile/airootfs"
UNITS="$ROOT/etc/systemd/system"
FAIL=0

echo "Verifying live-session services..."

forbidden=(
    "getty@tty1.service.d/autologin.conf|root console autologin (live session autologs liveuser via SDDM only)"
    "multi-user.target.wants/sshd.service|SSH daemon in the live desktop session"
    "multi-user.target.wants/systemd-networkd.service|systemd-networkd alongside NetworkManager"
    "sockets.target.wants/systemd-networkd.socket|systemd-networkd alongside NetworkManager"
    "network-online.target.wants/systemd-networkd-wait-online.service|networkd-wait-online stalls network-online.target (networkd manages no links)"
    "cloud-init.target.wants|cloud-init reads the same 'cidata' label as neos-autoinstall"
    "livecd-talk.service|calls the missing /usr/local/bin/livecd-sound; neos-accessibility.service owns accessibility=on"
    "livecd-alsa-unmuter.service|calls the missing /usr/local/bin/livecd-sound"
    "choose-mirror.service|calls the missing /usr/local/bin/choose-mirror"
)
for entry in "${forbidden[@]}"; do
    path="${entry%%|*}"
    why="${entry#*|}"
    if [[ -e "$UNITS/$path" || -L "$UNITS/$path" ]]; then
        echo "[FAIL] $UNITS/$path is present: $why"
        FAIL=1
    fi
done
(( FAIL )) || echo "  [PASS] no conflicting releng units"

if grep -qx 'cloud-init' profile/packages.x86_64; then
    echo "[FAIL] cloud-init is in profile/packages.x86_64 (its NoCloud datasource claims the 'cidata' label)"
    FAIL=1
else
    echo "  [PASS] cloud-init is not installed"
fi

# NetworkManager owns networking; it must still be enabled and waited on.
for unit in multi-user.target.wants/NetworkManager.service network-online.target.wants/NetworkManager-wait-online.service; do
    if [[ -L "$UNITS/$unit" ]]; then
        echo "  [PASS] $unit enabled"
    else
        echo "[FAIL] $unit is not enabled"
        FAIL=1
    fi
done

# Every overlay unit that runs something from /usr/local/bin must find it in
# the overlay (packages never install there).
missing=0
while IFS= read -r unit; do
    while IFS= read -r bin; do
        if [[ ! -e "$ROOT$bin" ]]; then
            echo "[FAIL] ${unit#"$ROOT"/} runs $bin, which the overlay does not ship"
            missing=1
        fi
    done < <(grep -hoE '^Exec[A-Za-z]*=[-@:+!]*/usr/local/bin/[^[:space:]]+' "$unit" | sed -E 's/^[^=]*=[-@:+!]*//')
done < <(find "$UNITS" "$ROOT/etc/systemd/user" "$ROOT/usr/lib/systemd" -type f \( -name '*.service' -o -name '*.conf' \) 2>/dev/null)
if (( missing )); then
    FAIL=1
else
    echo "  [PASS] every /usr/local/bin Exec target in shipped units exists"
fi

if (( FAIL )); then
    echo "[FAIL] Live-session service verification failed."
    exit 1
fi
echo "[PASS] Live-session services verified."
