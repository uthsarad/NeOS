#!/bin/bash
set -euo pipefail

echo "Verifying UFW configuration..."

# Check ufw.conf
if [ -f "airootfs/etc/ufw/ufw.conf" ]; then
    if grep -q "ENABLED=yes" "airootfs/etc/ufw/ufw.conf"; then
        echo "✅ ufw.conf has ENABLED=yes"
    else
        echo "❌ ufw.conf does not have ENABLED=yes"
        exit 1
    fi
else
    echo "❌ airootfs/etc/ufw/ufw.conf not found"
    exit 1
fi

# Check systemd symlink
if [ -L "airootfs/etc/systemd/system/multi-user.target.wants/ufw.service" ]; then
    TARGET=$(readlink "airootfs/etc/systemd/system/multi-user.target.wants/ufw.service")
    if [[ "$TARGET" == "/usr/lib/systemd/system/ufw.service" ]]; then
        echo "✅ ufw.service symlink is correct"
    else
        echo "❌ ufw.service symlink points to wrong target: $TARGET"
        exit 1
    fi
else
    echo "❌ ufw.service symlink not found"
    exit 1
fi

echo "UFW verification passed!"
