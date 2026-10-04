#!/bin/bash
# NeOS defaults to Wayland and falls back to X11 where Wayland is known to fail
# (VMs, nomodeset, unknown display drivers). Runs neos-session-select against
# fake /proc/cmdline, /sys/class/drm and config trees for each case.
set -euo pipefail

SCRIPT="profile/airootfs/usr/local/bin/neos-session-select"
SERVICES="profile/airootfs/etc/calamares/modules/services-systemd.conf"
FAIL=0

echo "Verifying display session selection..."

pass() { echo "  [PASS] $1"; }
fail() { echo "[FAIL] $1"; FAIL=1; }

if [[ -x "$SCRIPT" ]]; then pass "$SCRIPT is executable"; else fail "$SCRIPT missing or not executable"; fi
if grep -q '"/usr/local/bin/neos-session-select"\]="0:0:755"' profile/profiledef.sh; then pass "profiledef.sh marks it 0755"; else fail "profiledef.sh has no entry for neos-session-select"; fi
if [[ -L profile/airootfs/etc/systemd/system/multi-user.target.wants/neos-session-select.service ]]; then pass "enabled on the live image"; else fail "neos-session-select.service not enabled on the live image"; fi
if grep -q 'name: "neos-session-select"' "$SERVICES"; then pass "enabled on installed systems"; else fail "neos-session-select not in $SERVICES"; fi
if grep -q '^Before=.*display-manager.service' profile/airootfs/etc/systemd/system/neos-session-select.service; then pass "runs before the display manager"; else fail "neos-session-select.service is not ordered before display-manager.service"; fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
# Fake systemd-detect-virt: "in a VM" when FAKE_VM=1 (expanded by the stub).
# shellcheck disable=SC2016
printf '#!/bin/sh\n[ "$FAKE_VM" = 1 ]\n' > "$WORK/virt"
chmod +x "$WORK/virt"

# run <name> <cmdline> <vm 0|1> <driver or ""> [session.conf value]
run() {
    local root="$WORK/$1"
    rm -rf "$root"
    mkdir -p "$root/etc/sddm.conf.d" "$root/var/lib/sddm" "$root/drm"
    printf '%s\n' "$2" > "$root/cmdline"
    if [[ -n "$4" ]]; then
        # card0/device/driver -> .../<driver>, plus a connector entry to ignore.
        mkdir -p "$root/drm/card0/device" "$root/drivers/$4" "$root/drm/card0-eDP-1"
        ln -s "$root/drivers/$4" "$root/drm/card0/device/driver"
    fi
    if [[ -n "${5:-}" ]]; then
        mkdir -p "$root/etc/neos"
        printf 'SESSION=%s\n' "$5" > "$root/etc/neos/session.conf"
    fi
    printf '[Autologin]\nUser=me\nSession=plasmax11\n' > "$root/etc/sddm.conf"
    NEOS_SESSION_ROOT="$root" NEOS_SESSION_CMDLINE="$root/cmdline" \
        NEOS_SESSION_DRM="$root/drm" NEOS_SESSION_VIRT="$WORK/virt" \
        NEOS_SESSION_NO_WAIT=1 FAKE_VM="$3" bash "$SCRIPT" >/dev/null
    grep -o '^DisplayServer=.*' "$root/etc/sddm.conf.d/zz-neos-session.conf" | cut -d= -f2
}

expect() {
    local label="$1" want="$2"; shift 2
    local got
    got="$(run "$@")" || got="error"
    if [[ "$got" == "$want" ]]; then pass "$label -> $want"; else fail "$label: expected $want, got $got"; fi
}

expect "Intel graphics"            wayland intel  "quiet splash" 0 i915
expect "AMD graphics"              wayland amd    "quiet splash" 0 amdgpu
expect "NVIDIA proprietary driver" wayland nvidia "quiet splash" 0 nvidia
expect "nouveau"                   x11     nouv   "quiet splash" 0 nouveau
expect "firmware framebuffer only" x11     sdrm   "quiet splash" 0 simpledrm
expect "no GPU device"             x11     none   "quiet splash" 0 ""
expect "virtual machine"           x11     vm     "quiet splash" 1 virtio_gpu
expect "Safe Graphics (nomodeset)" x11     nomod  "quiet nomodeset" 0 i915
expect "neos.session=wayland in a VM" wayland cmdw "quiet neos.session=wayland" 1 virtio_gpu
expect "neos.session=x11 on Intel"    x11     cmdx "quiet neos.session=x11" 0 i915
expect "session.conf x11 on Intel"    x11     confx "quiet" 0 i915 x11
expect "session.conf wayland in a VM" wayland confw "quiet" 1 virtio_gpu wayland
expect "cmdline beats session.conf"   wayland both  "neos.session=wayland" 0 i915 x11

# Side effects on an Intel (Wayland) run.
root="$WORK/intel"
if grep -qx 'Session=plasma' "$root/etc/sddm.conf"; then pass "rewrites Calamares' autologin session in /etc/sddm.conf"; else fail "/etc/sddm.conf autologin session not updated"; fi
if grep -qx 'Session=/usr/share/wayland-sessions/plasma.desktop' "$root/var/lib/sddm/state.conf"; then pass "seeds the greeter's first-boot session"; else fail "state.conf not seeded"; fi
if grep -qx 'CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1' \
    "$root/etc/sddm.conf.d/zz-neos-session.conf"; then
    pass "Wayland greeter runs on kwin_wayland"
else
    fail "no kwin_wayland CompositorCommand"
fi

# A user's later pick in the greeter must survive the next boot.
printf '[Last]\nSession=/usr/share/xsessions/plasmax11.desktop\n' > "$root/var/lib/sddm/state.conf"
NEOS_SESSION_ROOT="$root" NEOS_SESSION_CMDLINE="$root/cmdline" NEOS_SESSION_DRM="$root/drm" \
    NEOS_SESSION_VIRT="$WORK/virt" NEOS_SESSION_NO_WAIT=1 FAKE_VM=0 bash "$SCRIPT" >/dev/null
if grep -qx 'Session=/usr/share/xsessions/plasmax11.desktop' "$root/var/lib/sddm/state.conf"; then pass "keeps the session the user last chose"; else fail "overwrote the user's last session"; fi

if grep -qx 'Session=plasmax11' "$WORK/vm/etc/sddm.conf"; then pass "X11 fallback keeps the autologin session on plasmax11"; else fail "X11 fallback changed the autologin session"; fi

# Static configs must stay the safe floor if the service never runs.
if grep -qx 'DisplayServer=x11' profile/airootfs/etc/sddm.conf.d/10-displayserver.conf && grep -qx 'Session=plasmax11' profile/airootfs/etc/sddm.conf.d/autologin.conf; then pass "static SDDM config stays on X11 as the fallback"; else fail "static SDDM config must stay X11 (neos-session-select upgrades it)"; fi

if (( FAIL )); then
    echo "[FAIL] Display session selection checks failed."
    exit 1
fi
echo "[PASS] Display session selection verified."
