#!/bin/bash
# Exercise runtime helpers without touching the host's packages or disks.
# The extracted code consumes/sets these variables through eval; the sed pattern
# intentionally matches a literal shell variable.
# shellcheck disable=SC2016,SC2034,SC2154
set -euo pipefail
cd "$(dirname "$0")/.."

# Load only the notification function, avoiding the updater's root-only setup.
eval "$(sed -n '/^notify_users() {$/,/^}$/p' profile/airootfs/usr/local/bin/neos-autoupdate.sh)"
loginctl() { printf '1000 alice\n'; }
notify-send() { :; }
sudo() { printf '%s\n' "$@"; }
actual=$(notify_users '-message with spaces' '-title' dialog-error critical)
expected=$(printf '%s\n' -u alice -- env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
    notify-send --icon=dialog-error --urgency=critical -- '-title' '-message with spaces')
if [[ "$actual" != "$expected" ]]; then
    echo '[FAIL] update notification arguments are invalid'
    exit 1
fi
echo '[PASS] notification options precede -- and message arguments stay intact'

# Run only the connectivity decision, with curl and sleep replaced by stubs.
network_check=$(sed -n '/^net_ok=/,/^if \[\[ "\$net_ok" -eq 1 \]\]; then$/p' \
    profile/airootfs/usr/local/bin/neos-pacstrap | sed '$d')
log() { :; }
sleep() { :; }
curl() {
    calls=$((calls + 1))
    [[ "$succeed_on" -gt 0 && "$calls" -ge "$succeed_on" ]]
}
NET_TIMEOUT=3
NET_RETRIES=3
for scenario in delayed offline connected; do
    calls=0
    NET_AVAILABLE=0
    succeed_on=0
    expected_calls=3
    expected_online=0
    case "$scenario" in
        delayed) succeed_on=2; expected_calls=2; expected_online=1 ;;
        connected) NET_AVAILABLE=1; expected_calls=0; expected_online=1 ;;
    esac
    eval "$network_check"
    if [[ "$net_ok" != "$expected_online" || "$calls" != "$expected_calls" ]]; then
        echo "[FAIL] $scenario: online=$net_ok attempts=$calls"
        exit 1
    fi
    echo "[PASS] installer connectivity: $scenario (online=$net_ok attempts=$calls)"
done
