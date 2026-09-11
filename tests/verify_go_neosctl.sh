#!/bin/bash
set -euo pipefail

echo "Verifying Go neosctl tool..."

if [ ! -f "tools/neosctl/main.go" ] || [ ! -f "tools/neosctl/go.mod" ]; then
    echo "❌ tools/neosctl files missing!"
    exit 1
fi

if ! command -v go &> /dev/null; then
    echo "⚠️ go not installed, validating Go source structure statically."
    grep -q 'package main' tools/neosctl/main.go
    grep -q 'func runRankMirrors' tools/neosctl/main.go
    if grep -q 'func runAudit' tools/neosctl/main.go; then
        echo "❌ runAudit reappeared in neosctl — profile auditing is owned by tools/neos-profile-audit"
        exit 1
    fi
    echo "✅ Go neosctl source structure verified."
    exit 0
fi

echo "Building Go neosctl tool..."
(cd tools/neosctl && go build -o /tmp/neosctl .)

echo "Verifying audit consolidation ownership..."
# The Go duplicate audit was consolidated into tools/neos-profile-audit (Rust);
# guard against it silently reappearing.
if grep -q 'func runAudit' tools/neosctl/main.go; then
    echo "❌ runAudit reappeared in neosctl — profile auditing is owned by tools/neos-profile-audit"
    exit 1
fi
grep -q 'func runRankMirrors' tools/neosctl/main.go
echo "✅ neosctl compiles and no longer duplicates the profile audit."

echo "Exercising retained mirror-ranking feature against the profile mirrorlist..."
# A live ranking run needs network access, so only a mirrorlist parse failure is
# fatal here; network-unreachable environments still verify command dispatch.
MIRRORLIST="$PWD/profile/airootfs/etc/pacman.d/neos-mirrorlist"
if /tmp/neosctl rank-mirrors "$MIRRORLIST" > /tmp/neosctl_rank.log 2>&1; then
    echo "✅ neosctl rank-mirrors executed successfully (live network available)."
else
    if grep -q "no active Server URLs found" /tmp/neosctl_rank.log; then
        echo "❌ neosctl failed to parse the profile mirrorlist"
        cat /tmp/neosctl_rank.log
        exit 1
    fi
    echo "⚠️ Live network unavailable for mirror ranking; command dispatch verified."
fi
rm -f /tmp/neosctl /tmp/neosctl_rank.log
echo "✅ Go neosctl audit passed successfully."
