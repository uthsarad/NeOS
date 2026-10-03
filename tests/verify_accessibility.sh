#!/bin/bash
# The Screen Reader boot entry (accessibility=on) must make the desktop speak,
# not just the text console: neos-accessibility --session (autostarted in the
# Plasma session) turns on Plasma's screen reader and starts Orca. On a normal
# boot both modes must do nothing.
set -euo pipefail

SCRIPT="profile/airootfs/usr/local/bin/neos-accessibility"
AUTOSTART="profile/airootfs/etc/xdg/autostart/neos-screen-reader.desktop"
FAIL=0

pass() { echo "  [PASS] $1"; }
fail() { echo "[FAIL] $1"; FAIL=1; }

echo "Verifying the screen reader boot path..."

if grep -q 'accessibility=on' profile/grub/grub.cfg && grep -q 'accessibility=on' profile/syslinux/archiso_sys.cfg; then
    pass "UEFI (GRUB) and BIOS (syslinux) menus both have a Screen Reader entry"
else
    fail "a boot menu lacks the accessibility=on Screen Reader entry"
fi
for pkg in orca espeakup; do
    if grep -qx "$pkg" profile/packages.x86_64; then pass "$pkg is on the live image"; else fail "$pkg missing from profile/packages.x86_64"; fi
done
if grep -qx 'Exec=/usr/local/bin/neos-accessibility --session' "$AUTOSTART"; then
    pass "the desktop session autostarts neos-accessibility --session"
else
    fail "$AUTOSTART does not run neos-accessibility --session"
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin"
# Test copy with stubs first on PATH.
sed -e "s#^export PATH=.*#export PATH=\"$WORK/bin:\$PATH\"#" "$SCRIPT" > "$WORK/neos-accessibility"
chmod +x "$WORK/neos-accessibility"
for tool in orca kwriteconfig6 systemctl logger; do
    printf '#!/bin/sh\necho "%s $*" >> "%s/calls"\n' "$tool" "$WORK" > "$WORK/bin/$tool"
    chmod +x "$WORK/bin/$tool"
done
printf '#!/bin/sh\nexit 1\n' > "$WORK/bin/pgrep"   # Orca not running yet
chmod +x "$WORK/bin/pgrep"

run() { rm -f "$WORK/calls"; NEOS_A11Y_CMDLINE="$WORK/cmdline" "$WORK/neos-accessibility" "$@" >/dev/null 2>&1; }

echo "quiet splash" > "$WORK/cmdline"
run --session
run
if [[ ! -s "$WORK/calls" ]] || ! grep -qE '^(orca|kwriteconfig6|systemctl) ' "$WORK/calls"; then
    pass "normal boot: nothing is started"
else
    fail "normal boot started something: $(tr '\n' ';' < "$WORK/calls")"
fi

echo "quiet splash accessibility=on" > "$WORK/cmdline"
run --session
if grep -q '^kwriteconfig6 --file kaccessrc --group ScreenReader --key Enabled true' "$WORK/calls"; then
    pass "session: Plasma's screen reader setting is turned on"
else
    fail "session: kaccessrc ScreenReader/Enabled was not set"
fi
if grep -q '^orca --replace' "$WORK/calls"; then pass "session: Orca is started"; else fail "session: Orca was not started"; fi

printf '<busconfig>\n  <auth>EXTERNAL</auth>\n</busconfig>\n' > "$WORK/accessibility.conf"
NEOS_A11Y_BUSCONF="$WORK/accessibility.conf" run
if grep -q '^systemctl start espeakup.service' "$WORK/calls"; then pass "boot service: espeakup is started"; else fail "boot service: espeakup was not started"; fi
NEOS_A11Y_BUSCONF="$WORK/accessibility.conf" run
if [[ "$(grep -c '<allow user="root"/>' "$WORK/accessibility.conf")" == 1 ]] && tail -n1 "$WORK/accessibility.conf" | grep -qx '</busconfig>'; then
    pass "boot service: root may join the accessibility bus (installer speech), once"
else
    fail "boot service: accessibility bus policy not patched exactly once: $(tr '\n' ' ' < "$WORK/accessibility.conf")"
fi
echo "quiet splash" > "$WORK/cmdline"
printf '<busconfig>\n</busconfig>\n' > "$WORK/accessibility.conf"
NEOS_A11Y_BUSCONF="$WORK/accessibility.conf" run
if ! grep -q 'allow user="root"' "$WORK/accessibility.conf"; then pass "normal boot: accessibility bus left alone"; else fail "normal boot patched the accessibility bus"; fi

# The installer launcher hands the bus to the root Calamares, and an install
# from a screen reader boot keeps speech on in the installed system.
WELCOME="profile/airootfs/usr/local/bin/neos-welcome"
# shellcheck disable=SC2016 # literal text to find in the script
if grep -q 'AT_SPI_BUS_ADDRESS=' "$WELCOME" && grep -qF '"${A11Y_ENV[@]}"' "$WELCOME"; then
    pass "installer: Calamares gets the accessibility bus on a screen reader boot"
else
    fail "installer: $WELCOME does not pass AT_SPI_BUS_ADDRESS to Calamares"
fi
PACSTRAP="profile/airootfs/usr/local/bin/neos-pacstrap"
if grep -q 'accessibility=on' "$PACSTRAP" && grep -q 'etc/xdg/kaccessrc' "$PACSTRAP" && grep -q 'espeakup.service' "$PACSTRAP"; then
    pass "installed system: screen reader and console speech stay on after a screen reader install"
else
    fail "installed system: $PACSTRAP does not carry the screen reader over"
fi

if (( FAIL )); then
    echo "[FAIL] Screen reader checks failed."
    exit 1
fi
echo "[PASS] Screen reader boot path verified."
