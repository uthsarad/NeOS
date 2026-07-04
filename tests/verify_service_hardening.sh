#!/bin/bash
set -e

# ⚡ Bolt: Load file content once to eliminate repeated fork/exec overhead

verify_service() {
    local SERVICE_FILE="$1"
    echo "Verifying service hardening in $SERVICE_FILE..."

    # Skip symlinks
    if [ -L "$SERVICE_FILE" ]; then
        echo "⏭️ Skipping symlink $SERVICE_FILE"
        return 0
    fi

    # Exempt units that perform system-level account/setup work and therefore
    # cannot run under ProtectSystem=strict / ProtectHome / NoNewPrivileges.
    # neos-liveuser-setup runs `useradd -m` + `sudo -u` and must write /etc and
    # /home; sandboxing it silently breaks live autologin (no user is created).
    case "${SERVICE_FILE##*/}" in
        neos-liveuser-setup.service)
            # Regression guard (inverse check): an upstream merge once re-added
            # sandboxing to this unit and silently broke live boot. Fail loudly
            # if any sandboxing directive reappears. Comment lines are ignored —
            # the unit's own comments name the forbidden directives.
            CONTENT=$(grep -v '^[[:space:]]*#' "$SERVICE_FILE")
            for directive in ProtectSystem ProtectHome PrivateTmp NoNewPrivileges; do
                if [[ "$CONTENT" == *"$directive="* ]]; then
                    echo "❌ $SERVICE_FILE contains $directive= — sandboxing this unit breaks live autologin (it must write /etc and /home)"
                    return 1
                fi
            done
            echo "⏭️ $SERVICE_FILE verified unsandboxed (account-setup unit, must not be sandboxed)"
            return 0
            ;;
    esac

    CONTENT=$(<"$SERVICE_FILE")

    # Check for ProtectSystem=strict
    if [[ "$CONTENT" == *"ProtectSystem=strict"* ]]; then
        echo "✅ ProtectSystem=strict found"
    else
        echo "❌ ProtectSystem=strict NOT found"
        return 1
    fi

    # Check for ProtectHome=yes or read-only
    if [[ "$CONTENT" == *"ProtectHome=yes"* ]] || [[ "$CONTENT" == *"ProtectHome=read-only"* ]]; then
        echo "✅ ProtectHome=yes or read-only found"
    else
        echo "❌ ProtectHome=yes or read-only NOT found"
        return 1
    fi

    # Check for PrivateTmp=yes
    if [[ "$CONTENT" == *"PrivateTmp=yes"* ]]; then
        echo "✅ PrivateTmp=yes found"
    else
        echo "❌ PrivateTmp=yes NOT found"
        return 1
    fi

    # Check for NoNewPrivileges=yes
    if [[ "$CONTENT" == *"NoNewPrivileges=yes"* ]]; then
        echo "✅ NoNewPrivileges=yes found"
    else
        echo "❌ NoNewPrivileges=yes NOT found"
        return 1
    fi
}

SERVICES_DIR="profile/airootfs/etc/systemd/system/"

for service_file in "$SERVICES_DIR"neos-*.service; do
    if ! verify_service "$service_file"; then
        echo "Hardening verification failed for $service_file"
        kill -s TERM $$
    fi
done

echo "All security checks passed for all services!"
