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
    grep -q 'def audit_profile' tools/neos_tasks.rb
    echo "✅ Ruby tasks structure verified."
    exit 0
fi

echo "Running Ruby-based profile audit..."
ruby tools/neos_tasks.rb audit .
echo "✅ Ruby tasks audit passed successfully."
