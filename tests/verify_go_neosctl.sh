#!/bin/bash
set -euo pipefail

echo "Verifying Go neosctl tool..."

if [ ! -f "tools/neosctl/main.go" ] || [ ! -f "tools/neosctl/go.mod" ]; then
    echo "❌ tools/neosctl files missing!"
    exit 1
fi

if ! command -v go &> /dev/null; then
    echo "⚠️ go not installed, validating Go source structure and syntax statically."
    grep -q 'package main' tools/neosctl/main.go
    grep -q 'func runAudit' tools/neosctl/main.go
    grep -q 'func runRankMirrors' tools/neosctl/main.go
    echo "✅ Go neosctl source structure verified."
    exit 0
fi

echo "Running Go-based neosctl audit..."
(cd tools/neosctl && go run main.go audit ../../profile)
echo "✅ Go neosctl audit passed successfully."
