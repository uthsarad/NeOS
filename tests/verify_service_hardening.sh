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

    CONTENT=$(<"$SERVICE_FILE")

    # Check for ProtectSystem=strict
    if [[ "$CONTENT" == *"ProtectSystem=strict"* ]]; then
        echo "✅ ProtectSystem=strict found"
    else
        echo "❌ ProtectSystem=strict NOT found"
        return 1
    fi

    # Check for ProtectHome=yes
    if [[ "$CONTENT" == *"ProtectHome=yes"* ]]; then
        echo "✅ ProtectHome=yes found"
    else
        echo "❌ ProtectHome=yes NOT found"
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
