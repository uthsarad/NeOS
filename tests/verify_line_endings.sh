#!/bin/bash
# Linux entrypoints and overlay text must remain usable on Windows checkouts.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
from pathlib import Path

bad = []
for base in (Path('profile'), Path('tests'), Path('tools')):
    for path in base.rglob('*'):
        if not path.is_file() or path.is_symlink():
            continue
        if any(part in {'target', 'node_modules', '__pycache__', 'obj', 'bin'}
               for part in path.relative_to(base).parts[:-1]) and base.name != 'profile':
            continue
        data = path.read_bytes()
        if b'\0' in data:
            continue
        try:
            data.decode('utf-8')
        except UnicodeDecodeError:
            continue
        if b'\r\n' in data:
            bad.append(str(path))
if bad:
    raise SystemExit('[FAIL] CRLF in Linux source/overlay files:\n' + '\n'.join(bad))
print('[PASS] Linux source and overlay text use LF line endings')
PY
