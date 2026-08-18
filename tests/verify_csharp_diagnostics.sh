#!/bin/bash
set -euo pipefail

echo "Verifying C# .NET diagnostics tool..."

if [ ! -f "tools/NeosDiagnostics/NeosDiagnostics.csproj" ] || [ ! -f "tools/NeosDiagnostics/Program.cs" ] || [ ! -f "tools/NeosDiagnostics/SecurityInspector.cs" ]; then
    echo "❌ tools/NeosDiagnostics files missing!"
    exit 1
fi

if ! command -v dotnet &> /dev/null; then
    echo "⚠️ dotnet not installed, validating C# source structure statically."
    grep -q 'namespace Neos.Diagnostics' tools/NeosDiagnostics/Program.cs
    grep -q 'class SecurityInspector' tools/NeosDiagnostics/SecurityInspector.cs
    echo "✅ C# .NET diagnostics source structure verified."
    exit 0
fi

echo "Running C# .NET security audit..."
dotnet run --project tools/NeosDiagnostics -- "$PWD"
echo "✅ C# diagnostics passed successfully."
