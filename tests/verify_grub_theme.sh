#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
from pathlib import Path
iso = Path('profile/grub/themes/neos-medieval')
installed = Path('profile/airootfs/usr/share/grub/themes/neos-medieval')
manifest = Path('profile/airootfs/etc/calamares/neos-overlay.txt').read_text().splitlines()
for asset in iso.iterdir():
    assert asset.read_bytes() == (installed / asset.name).read_bytes(), f'Theme mismatch: {asset}'
    assert f'usr/share/grub/themes/neos-medieval/{asset.name}' in manifest, f'Missing installed asset: {asset}'
for name in ('background.png', 'theme.txt', 'dejavu_14.pf2', 'dejavu_16.pf2'):
    assert (iso / name).is_file(), f'Missing theme asset: {name}'
for suffix in ('c', 'n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw'):
    assert (iso / f'selected_{suffix}.png').is_file()
cfg = Path('profile/grub/grub.cfg').read_text()
assert 'insmod png' in cfg
assert cfg.index('loadfont $prefix/themes/neos-medieval/dejavu_16.pf2') < cfg.index('terminal_output gfxterm')
assert 'set theme=$prefix/themes/neos-medieval/theme.txt' in cfg
defaults = Path('profile/airootfs/etc/default/grub').read_text()
assert 'GRUB_THEME="/usr/share/grub/themes/neos-medieval/theme.txt"' in defaults
assert 'GRUB_TERMINAL_OUTPUT="gfxterm"' in defaults
print('[PASS] Medieval graphical theme: ISO assets, installed assets, font loading and installer manifest')
PY
