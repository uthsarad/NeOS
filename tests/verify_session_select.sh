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
printf '[Last]\nSession=/usr/share/xsessions/xfce.desktop\n' > "$root/var/lib/sddm/state.conf"
NEOS_SESSION_ROOT="$root" NEOS_SESSION_CMDLINE="$root/cmdline" NEOS_SESSION_DRM="$root/drm" \
    NEOS_SESSION_VIRT="$WORK/virt" NEOS_SESSION_NO_WAIT=1 FAKE_VM=0 bash "$SCRIPT" >/dev/null
if grep -qx 'Session=/usr/share/xsessions/xfce.desktop' "$root/var/lib/sddm/state.conf"; then pass "keeps the session the user last chose"; else fail "overwrote the user's last session"; fi

printf '[Last]\nSession=/usr/share/xsessions/plasmax11.desktop\n' > "$root/var/lib/sddm/state.conf"
NEOS_SESSION_ROOT="$root" NEOS_SESSION_CMDLINE="$root/cmdline" NEOS_SESSION_DRM="$root/drm" \
    NEOS_SESSION_VIRT="$WORK/virt" NEOS_SESSION_NO_WAIT=1 FAKE_VM=0 bash "$SCRIPT" >/dev/null
if grep -qx 'Session=/usr/share/xsessions/xfce.desktop' "$root/var/lib/sddm/state.conf"; then pass "migrates removed Plasma X11 session"; else fail "obsolete session survived migration"; fi

if grep -qx 'Session=xfce' "$WORK/vm/etc/sddm.conf"; then pass "X11 fallback selects Xfce"; else fail "X11 fallback did not select Xfce"; fi

# SDDM reads its primary configuration after all drop-ins. Assert the effective
# values, including an existing installed configuration that forces Wayland.
run primary "quiet splash" 1 vmwgfx >/dev/null
root="$WORK/primary"
cat > "$root/etc/sddm.conf" <<'EOF'
# DisplayServer=keep-this-comment
[General]
  DisplayServer = wayland
GreeterEnvironment=EXTRA_VAR=keep,QT_WAYLAND_SHELL_INTEGRATION=xdg-shell,QT_WAYLAND_SHELL_INTEGRATION=wrong
[Autologin]
User=me
Relogin=true
 Session = plasmax11.desktop
[Theme]
Session=plasma
DisplayServer=custom
[Other]
GreeterEnvironment=keep
CompositorCommand=keep
[General]
DisplayServer=wayland
[Wayland]
CompositorCommand=weston --shell=kiosk-shell.so
[Autologin]
Session=plasma
EOF
chmod 0640 "$root/etc/sddm.conf"
reselect_primary() {
    NEOS_SESSION_ROOT="$root" NEOS_SESSION_CMDLINE="$root/cmdline" \
        NEOS_SESSION_DRM="$root/drm" NEOS_SESSION_VIRT="$WORK/virt" \
        NEOS_SESSION_NO_WAIT=1 FAKE_VM=1 bash "$SCRIPT" >/dev/null
}
reselect_primary
python3 - "$root" <<'PY'
import configparser
from pathlib import Path
import sys

root = Path(sys.argv[1])
config = configparser.ConfigParser(strict=False, interpolation=None)
config.read([root / "etc/sddm.conf.d/zz-neos-session.conf", root / "etc/sddm.conf"])
assert config["General"]["DisplayServer"] == "x11", "primary config defeats the VM fallback"
assert config["Autologin"]["Session"] == "xfce"
assert config["Autologin"]["User"] == "me"
assert config["Autologin"]["Relogin"] == "true"
assert config["Theme"]["Session"] == "plasma"
assert config["Theme"]["DisplayServer"] == "custom"
assert config["Other"]["GreeterEnvironment"] == "keep"
assert config["Other"]["CompositorCommand"] == "keep"
primary = root / "etc/sddm.conf"
assert primary.read_text().count("DisplayServer=x11") == 2, "not all duplicate overrides updated"
assert "# DisplayServer=keep-this-comment" in primary.read_text()
assert primary.stat().st_mode & 0o777 == 0o640, "primary configuration permissions changed"
PY
pass "effective VM fallback overrides conflicting primary config and preserves authentication"

printf 'quiet neos.session=wayland\n' > "$root/cmdline"
reselect_primary
python3 - "$root" <<'PY'
import configparser
from pathlib import Path
import sys

root = Path(sys.argv[1])
config = configparser.ConfigParser(strict=False, interpolation=None)
config.read([root / "etc/sddm.conf.d/zz-neos-session.conf", root / "etc/sddm.conf"])
assert config["General"]["DisplayServer"] == "wayland", "primary config defeats explicit Wayland selection"
assert config["Autologin"]["Session"] == "plasma"
environment = config["General"]["GreeterEnvironment"].split(",")
assert environment == ["EXTRA_VAR=keep", "QT_WAYLAND_SHELL_INTEGRATION=layer-shell"]
assert config["Wayland"]["CompositorCommand"] == "kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1"
assert config["Other"]["CompositorCommand"] == "keep"
PY
pass "explicit Wayland selection repairs primary greeter settings and keeps unrelated environment"
cp "$root/etc/sddm.conf" "$root/primary-first-boot.conf"
reselect_primary
if cmp -s "$root/etc/sddm.conf" "$root/primary-first-boot.conf"; then pass "primary configuration update is idempotent"; else fail "primary configuration changes on repeated boots"; fi

# Preserve a separately installed desktop chosen for autologin.
printf '[Autologin]\nUser=me\nSession=gnome\n' > "$root/etc/sddm.conf"
reselect_primary
if grep -qx 'Session=gnome' "$root/etc/sddm.conf"; then pass "preserves a custom autologin desktop"; else fail "custom autologin desktop overwritten"; fi
if ! grep -q '^\[General\]' "$root/etc/sddm.conf"; then pass "absent primary keys inherit generated drop-in"; else fail "unnecessary primary settings added"; fi
rm "$root/etc/sddm.conf"
reselect_primary
if [[ ! -e "$root/etc/sddm.conf" ]]; then pass "absent primary config remains absent"; else fail "created an unnecessary primary config"; fi

# Static configs must stay the safe floor if the service never runs.
if grep -qx 'DisplayServer=x11' profile/airootfs/etc/sddm.conf.d/10-displayserver.conf && grep -qx 'Session=xfce' profile/airootfs/etc/sddm.conf.d/autologin.conf; then pass "static SDDM config stays on X11 as the fallback"; else fail "static SDDM config must stay X11 (neos-session-select upgrades it)"; fi

for pkg in xfce4-session xfce4-panel xfce4-settings xfdesktop xfwm4; do
    if grep -qx "$pkg" profile/packages.x86_64; then pass "$pkg available in the image"; else fail "missing fallback package $pkg"; fi
done
if grep -qx 'plasma-x11-session' profile/packages.x86_64; then fail "removed Plasma X11 package requested"; fi
if grep -q 'rm -f /usr/share/wayland-sessions/plasma.desktop' profile/airootfs/usr/local/bin/neos-liveuser-setup; then fail "live setup deletes the Wayland override session"; fi

if (( FAIL )); then
    echo "[FAIL] Display session selection checks failed."
    exit 1
fi
echo "[PASS] Display session selection verified."
