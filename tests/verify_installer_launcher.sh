#!/bin/bash
# A stalled optional notification must never prevent the installer invocation.
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
chmod 0777 "$work"
mkdir "$work/home"
chmod 0777 "$work/home"
export NEOS_TEST_CAPTURE="$work/started"

# Exported functions are inherited by the real Bash launcher, even though it
# resets PATH. The timeout mock runs the deliberately stalled dialog function;
# /usr/bin/timeout below independently enforces the test's deadline.
# shellcheck disable=SC2317,SC2329
kdialog() { sleep 3; }
# shellcheck disable=SC2317,SC2329
calamares() { :; }
# shellcheck disable=SC2317,SC2329
pgrep() { return 1; }
# shellcheck disable=SC2317,SC2329
xhost() { :; }
# shellcheck disable=SC2317,SC2329
systemd-detect-virt() { return 1; }
# shellcheck disable=SC2317,SC2329
sudo() { printf '%s\n' "$*" > "$NEOS_TEST_CAPTURE"; }
# shellcheck disable=SC2317,SC2329
timeout() {
    while [[ "$1" == -* ]]; do shift; done
    shift
    "$@"
}
export -f kdialog calamares pgrep xhost systemd-detect-virt sudo timeout

launcher="$PWD/profile/airootfs/usr/local/bin/neos-welcome"
command=(bash "$launcher")
if (( EUID == 0 )); then
    # The production launcher correctly refuses root callers.
    command=(runuser -u nobody -- env "HOME=$work/home" bash "$launcher")
fi
if ! /usr/bin/timeout 2s "${command[@]}"; then
    echo '[FAIL] Stalled notification blocked the installer launcher'; exit 1
fi
if ! grep -q -- '-n env QT_QPA_PLATFORM=xcb' "$NEOS_TEST_CAPTURE"; then
    echo '[FAIL] Launcher did not invoke Calamares through noninteractive sudo'; exit 1
fi
echo '[PASS] A stalled startup notification does not block the real installer launcher'
