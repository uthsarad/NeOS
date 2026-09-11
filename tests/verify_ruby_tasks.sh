#!/bin/bash
set -euo pipefail

echo "Verifying Ruby tasks & Rakefile suite..."

if [ ! -f "tools/neos_tasks.rb" ] || [ ! -f "Rakefile" ]; then
    echo "❌ Ruby tasks or Rakefile missing!"
    exit 1
fi

if ! command -v ruby &> /dev/null; then
    echo "⚠️ ruby not installed, validating Ruby tasks structure statically."
    grep -q 'module Neos' tools/neos_tasks.rb
    grep -q 'def audit_ownership_guard' tools/neos_tasks.rb
    if grep -q 'def audit_profile' tools/neos_tasks.rb; then
        echo "❌ audit_profile reappeared in neos_tasks.rb — profile auditing is owned by tools/neos-profile-audit"
        exit 1
    fi
    echo "✅ Ruby tasks structure verified."
    exit 0
fi

echo "Verifying Ruby task runner (canonical audit: tools/neos-profile-audit)..."
ruby tools/neos_tasks.rb audit .
echo "✅ Ruby tasks audit passed successfully."
