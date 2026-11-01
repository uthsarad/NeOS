#!/bin/bash
# Rollback must actually change what boots. `snapper rollback` only changes the
# btrfs default subvolume, which NeOS never boots from (root is mounted by path,
# subvol=/@), so the Operations Hub "rollback" silently did nothing.
# neos-rollback swaps the @ subvolume instead; this exercises it against a fake
# filesystem tree with stubbed mount/btrfs (no Btrfs or root needed).
# Stub bodies and check expressions are deliberately single-quoted: they are
# expanded when the stub runs or check() evals them (SC2016); OUT is read there (SC2034).
# shellcheck disable=SC2016,SC2034
set -euo pipefail

SCRIPT="profile/airootfs/usr/local/bin/neos-rollback"
HUB="profile/airootfs/usr/local/bin/neos-operations-hub"
FAIL=0

echo "Verifying system rollback..."

if grep -vE '^[[:space:]]*#' "$HUB" | grep -qE 'snapper[^|]*[[:space:]]rollback'; then
    echo "[FAIL] $HUB still calls 'snapper rollback' (ineffective with subvol=/@ root mounts)"
    FAIL=1
elif grep -q '/usr/local/bin/neos-rollback' "$HUB"; then
    echo "  [PASS] Operations Hub rolls back through neos-rollback"
else
    echo "[FAIL] $HUB does not use neos-rollback"
    FAIL=1
fi

if grep -q '"/usr/local/bin/neos-rollback"\]="0:0:755"' profile/profiledef.sh; then
    echo "  [PASS] neos-rollback is executable in the image (profiledef.sh)"
else
    echo "[FAIL] profiledef.sh has no 0:0:755 entry for neos-rollback"
    FAIL=1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin" "$WORK/run"

# Test copy: stubs first on PATH, temp dirs under $WORK, no root requirement.
sed -e "s#^export PATH=.*#export PATH=\"$WORK/bin:\$PATH\"#" \
    -e "s#/run/neos-rollback#$WORK/run/neos-rollback#" \
    -e 's#^(( EUID == 0 )) || die.*#:#' \
    "$SCRIPT" > "$WORK/neos-rollback"
chmod +x "$WORK/neos-rollback"

stub() { printf '#!/bin/bash\n%s\n' "$2" > "$WORK/bin/$1"; chmod +x "$WORK/bin/$1"; }
stub findmnt 'case "$*" in *FSTYPE*) echo btrfs ;; *) echo /dev/fake ;; esac'
# "Mounting" the top level replaces the temp mount dir with a link to the fake tree.
stub mount 'rmdir "${@: -1}" && ln -s "$FAKE_TOP" "${@: -1}"'
stub mountpoint '[[ -L "${@: -1}" ]]'
stub umount 'rm -f "$1" && mkdir "$1"'
stub logger ':'
stub btrfs 'case "$2" in
  show) [[ -d "${@: -1}" ]] ;;
  snapshot) [[ -z "${BTRFS_FAIL:-}" ]] && cp -a "${@: -2:1}" "${@: -1}" ;;
  *) exit 1 ;;
esac'

new_tree() {
    export FAKE_TOP="$WORK/top"
    rm -rf "$FAKE_TOP"
    mkdir -p "$FAKE_TOP/@" "$FAKE_TOP/@.snapshots/7/snapshot"
    echo broken > "$FAKE_TOP/@/state"
    echo good > "$FAKE_TOP/@.snapshots/7/snapshot/state"
}

check() {
    if eval "$2"; then echo "  [PASS] $1"; else echo "[FAIL] $1"; FAIL=1; fi
}

new_tree
OUT="$("$WORK/neos-rollback" 7 2>&1)" || true
check "restores snapshot 7 as the new root" '[[ "$(cat "$FAKE_TOP/@/state" 2>/dev/null)" == good ]]'
check "keeps the previous root as @.pre-rollback-*" \
    '[[ "$(cat "$FAKE_TOP"/@.pre-rollback-*/state 2>/dev/null)" == broken ]]'
check "leaves the snapshot itself untouched" '[[ "$(cat "$FAKE_TOP/@.snapshots/7/snapshot/state")" == good ]]'
check "tells the user to reboot" '[[ "$OUT" == *Reboot* ]]'

new_tree
check "refuses a snapshot that does not exist" '! "$WORK/neos-rollback" 99 >/dev/null 2>&1'
check "a refused rollback changes nothing" '[[ "$(cat "$FAKE_TOP/@/state")" == broken ]] && ! compgen -G "$FAKE_TOP/@.pre-rollback-*" >/dev/null'

new_tree
check "reports failure when the snapshot copy fails" '! BTRFS_FAIL=1 "$WORK/neos-rollback" 7 >/dev/null 2>&1'
check "a failed copy puts the original root back" '[[ "$(cat "$FAKE_TOP/@/state")" == broken ]] && ! compgen -G "$FAKE_TOP/@.pre-rollback-*" >/dev/null'

for bad in abc 0 "7;reboot" ""; do
    check "rejects snapshot argument '${bad}'" '! "$WORK/neos-rollback" "$bad" >/dev/null 2>&1'
done
check "unmounts the top level afterwards" '! compgen -G "$WORK/run/neos-rollback.*" >/dev/null'

if (( FAIL )); then
    echo "[FAIL] Rollback checks failed."
    exit 1
fi
echo "[PASS] System rollback verified."
