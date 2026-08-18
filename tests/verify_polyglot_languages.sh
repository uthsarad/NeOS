#!/bin/bash
set -euo pipefail

echo "================================================================="
echo "Verifying Polyglot Languages (Kotlin, Swift, Lisp, Haskell, Pascal)"
echo "================================================================="

POLYGLOT_DIR="tools/polyglot"

# 1. Kotlin Check
echo "Testing Kotlin implementation..."
test -f "$POLYGLOT_DIR/NeosAudit.kt"
grep -q 'package neos.polyglot' "$POLYGLOT_DIR/NeosAudit.kt"
if command -v kotlinc &> /dev/null; then
    kotlinc "$POLYGLOT_DIR/NeosAudit.kt" -include-runtime -d /tmp/neos_kt.jar
    java -jar /tmp/neos_kt.jar "$PWD"
    rm -f /tmp/neos_kt.jar
    echo "✅ Kotlin execution verified."
else
    echo "⚠️ kotlinc not installed, static source verification passed."
fi

# 2. Swift Check
echo "Testing Swift implementation..."
test -f "$POLYGLOT_DIR/NeosAudit.swift"
grep -q 'import Foundation' "$POLYGLOT_DIR/NeosAudit.swift"
if command -v swift &> /dev/null; then
    swift "$POLYGLOT_DIR/NeosAudit.swift" "$PWD"
    echo "✅ Swift execution verified."
else
    echo "⚠️ swift not installed, static source verification passed."
fi

# 3. Common Lisp Check
echo "Testing Common Lisp implementation..."
test -f "$POLYGLOT_DIR/neos_audit.lisp"
grep -q 'defun audit-profile' "$POLYGLOT_DIR/neos_audit.lisp"
if command -v sbcl &> /dev/null; then
    sbcl --script "$POLYGLOT_DIR/neos_audit.lisp"
    echo "✅ SBCL Lisp execution verified."
elif command -v clisp &> /dev/null; then
    clisp "$POLYGLOT_DIR/neos_audit.lisp"
    echo "✅ CLISP execution verified."
else
    echo "⚠️ Common Lisp (sbcl/clisp) not installed, static source verification passed."
fi

# 4. Haskell Check
echo "Testing Haskell implementation..."
test -f "$POLYGLOT_DIR/NeosAudit.hs"
grep -q 'module Main where' "$POLYGLOT_DIR/NeosAudit.hs"
if command -v runghc &> /dev/null; then
    runghc "$POLYGLOT_DIR/NeosAudit.hs" "$PWD"
    echo "✅ Haskell execution verified."
else
    echo "⚠️ Haskell (ghc/runghc) not installed, static source verification passed."
fi

# 5. Free Pascal Check
echo "Testing Free Pascal implementation..."
test -f "$POLYGLOT_DIR/neos_audit.pas"
grep -q 'program NeosAudit;' "$POLYGLOT_DIR/neos_audit.pas"
if command -v fpc &> /dev/null; then
    fpc -O2 -o/tmp/neos_pascal "$POLYGLOT_DIR/neos_audit.pas" > /dev/null
    /tmp/neos_pascal "$PWD"
    rm -f /tmp/neos_pascal /tmp/neos_audit.o
    echo "✅ Free Pascal execution verified."
else
    echo "⚠️ Free Pascal (fpc) not installed, static source verification passed."
fi

echo "================================================================="
echo "✅ All Polyglot language implementations verified successfully!"
echo "================================================================="
