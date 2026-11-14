#!/usr/bin/env bash
# Exercise the real probe with mocked system services: graphical.target and a
# nonblank TTY alone must never count as a successful live desktop boot.
set -euo pipefail
cd "$(dirname "$0")/.."
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
cat > "$scratch/mock" <<'MOCK'
#!/usr/bin/env bash
case "${0##*/}" in
    systemctl)
        [[ "$CASE" != failed-sddm || "${*: -1}" != sddm.service ]] ;;
    loginctl)
        case "$1" in
            list-sessions) echo '1 1000 liveuser seat0 tty2' ;;
            show-session)
                case "$4" in
                    Name) echo liveuser ;;
                    Active) [[ "$CASE" == inactive ]] && echo no || echo yes ;;
                    Type)
                        case "$CASE" in
                            tty) echo tty ;;
                            wayland) echo wayland ;;
                            *) echo x11 ;;
                        esac ;;
                esac ;;
        esac ;;
    pgrep)
        [[ "$CASE" != no-desktop ]] || exit 1
        if [[ "$CASE" == wayland ]]; then
            [[ "${*: -1}" == plasmashell ]]
        else
            [[ "${*: -1}" == xfce4-session ]]
        fi ;;
    sleep|journalctl) exit 0 ;;
esac
MOCK
chmod +x "$scratch/mock"
for cmd in systemctl loginctl pgrep sleep journalctl; do
    ln -s mock "$scratch/$cmd"
done
for scenario in failed-sddm tty inactive no-desktop x11 wayland; do
    status=0
    CASE="$scenario" PATH="$scratch:$PATH" bash profile/airootfs/usr/local/bin/neos-boot-probe > "$scratch/output" 2>&1 || status=$?
    case "$scenario" in
        x11|wayland)
            [[ "$status" == 0 ]] && grep -q 'live desktop session ready' "$scratch/output" ;;
        *) [[ "$status" != 0 ]] && ! grep -q 'live desktop session ready' "$scratch/output" ;;
    esac
    echo "[PASS] desktop readiness: $scenario"
done
