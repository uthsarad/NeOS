#!/bin/bash
# Every shipped .desktop entry must launch something the image actually has
# (reports/v2026.10.03/00-polish-plan.md Q1). The Omarchy import put 16
# launchers into every user's app menu whose commands did not exist
# (neos-launch-webapp, xdg-terminal-exec, foot, imv, mpv, ...).
#
# An absolute Exec/TryExec must exist in the overlay. A bare command must be
# listed below together with the package that provides it, and that package
# must be in profile/packages.x86_64.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="profile/airootfs"
PACKAGES="profile/packages.x86_64"
FAIL=0

# command -> package (extend when a new launcher uses a packaged command)
declare -A PROVIDER=(
    [konsole]=konsole
    [dolphin]=dolphin
    [systemsettings]=systemsettings
    [calamares]=calamares-garuda
    [firefox]=firefox
    [kate]=kate
)

echo "Verifying shipped .desktop launchers..."

while IFS= read -r -d '' entry; do
    while IFS= read -r line; do
        cmd="${line#*=}"
        # Drop a leading `env VAR=...` prefix, then keep the first word.
        if [[ "$cmd" == env\ * ]]; then
            cmd="${cmd#env }"
            while [[ "$cmd" == *=*\ * && "${cmd%% *}" == *=* ]]; do cmd="${cmd#* }"; done
        fi
        cmd="${cmd%% *}"
        cmd="${cmd//\"/}"
        [[ -z "$cmd" ]] && continue
        if [[ "$cmd" == /* ]]; then
            if [[ -e "$ROOT$cmd" ]]; then
                continue
            fi
            echo "[FAIL] ${entry#"$ROOT"/}: $cmd is not in the overlay"
            FAIL=1
        elif [[ -n "${PROVIDER[$cmd]:-}" ]]; then
            if ! grep -qx "${PROVIDER[$cmd]}" "$PACKAGES"; then
                echo "[FAIL] ${entry#"$ROOT"/}: $cmd needs package '${PROVIDER[$cmd]}', which is not in $PACKAGES"
                FAIL=1
            fi
        else
            echo "[FAIL] ${entry#"$ROOT"/}: unknown command '$cmd' (add it to PROVIDER with its package if it is shipped)"
            FAIL=1
        fi
    done < <(grep -E '^(Exec|TryExec)=' "$entry" || true)
done < <(find "$ROOT" -name '*.desktop' -print0)

(( FAIL )) || echo "  [PASS] every shipped .desktop launcher resolves"

# Configs in /etc/skel/.config land in every new home directory, so each one
# must belong to software the image installs (the import shipped configs for
# 15 applications that were not installed).
declare -A SKEL_OWNER=(
    [autostart]=plasma-desktop
    [ksplashrc]=plasma-desktop
    [wireplumber]=wireplumber
)
for item in "$ROOT"/etc/skel/.config/*; do
    [[ -e "$item" ]] || continue
    name="${item##*/}"
    owner="${SKEL_OWNER[$name]:-}"
    if [[ -z "$owner" ]]; then
        echo "[FAIL] /etc/skel/.config/$name has no owning package in SKEL_OWNER (is the application installed?)"
        FAIL=1
    elif ! grep -qx "$owner" "$PACKAGES"; then
        echo "[FAIL] /etc/skel/.config/$name belongs to '$owner', which is not in $PACKAGES"
        FAIL=1
    fi
done
(( FAIL )) || echo "  [PASS] every /etc/skel/.config entry belongs to an installed package"

if (( FAIL )); then
    echo "[FAIL] Desktop entry / skel verification failed."
    exit 1
fi
echo "[PASS] Desktop entries and skel configs verified."
