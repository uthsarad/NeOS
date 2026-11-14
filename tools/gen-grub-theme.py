#!/usr/bin/env python3
"""Render NeOS's original medieval boot artwork (Pillow required to regenerate).

Generated assets are committed; building an ISO needs no graphics toolchain.
"""
from pathlib import Path
import shutil
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ISO = ROOT / 'profile/grub/themes/neos-medieval'
INSTALLED = ROOT / 'profile/airootfs/usr/share/grub/themes/neos-medieval'


def render():
    ISO.mkdir(parents=True, exist_ok=True)
    image = Image.new('RGB', (1600, 1000), '#171b20')
    draw = ImageDraw.Draw(image)
    # Dark stone, warm brass, manuscript ornament. Keep the menu field clear.
    for y in range(1000):
        t = y / 1000
        draw.line((0, y, 1600, y), fill=(int(25-9*t), int(29-9*t), int(34-10*t)))
    for inset, color in ((26, '#66543b'), (32, '#b89a61'), (42, '#403a30')):
        draw.rectangle((inset, inset, 1599-inset, 999-inset), outline=color, width=2)
    for x in (60, 1540):
        for y in (60, 940):
            draw.polygon(((x, y-10), (x+10, y), (x, y+10), (x-10, y)), fill='#b89a61')
    # Castle silhouette in the lower margin, outside the interactive menu.
    for x, top in ((110, 790), (200, 825), (1320, 825), (1410, 790)):
        draw.rectangle((x, top, x+80, 948), fill='#22282c', outline='#4c493c', width=2)
        for offset in range(0, 80, 20):
            draw.rectangle((x+offset, top-12, x+offset+10, top), fill='#4c493c')
        draw.rectangle((x+34, top+30, x+46, top+60), fill='#b89a61')
    title_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf', 62)
    subtitle_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf', 19)
    draw.text((800, 93), 'NeOS', font=title_font, anchor='mt', fill='#ecd9ae')
    draw.text((800, 176), 'A NEW CHAPTER BEGINS', font=subtitle_font, anchor='mt', fill='#b89a61')
    draw.line((520, 225, 1080, 225), fill='#66543b', width=2)
    draw.polygon(((800, 218), (808, 225), (800, 232), (792, 225)), fill='#b89a61')
    image.save(ISO / 'background.png')
    # BIOS uses Syslinux rather than GRUB; share the visual identity there.
    image.resize((640, 480), Image.Resampling.LANCZOS).save(
        ROOT / 'profile/syslinux/splash.png')
    # Nine-slice selected row: translucent brass with a restrained gold edge.
    for direction in ('c', 'n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw'):
        tile = Image.new('RGBA', (8, 8), (184, 154, 97, 38))
        edge = ImageDraw.Draw(tile)
        if 'n' in direction:
            edge.line((0, 0, 7, 0), fill='#b89a61', width=2)
        if 's' in direction:
            edge.line((0, 6, 7, 6), fill='#b89a61', width=2)
        if 'w' in direction:
            edge.line((0, 0, 0, 7), fill='#b89a61', width=2)
        if 'e' in direction:
            edge.line((6, 0, 6, 7), fill='#b89a61', width=2)
        tile.save(ISO / f'selected_{direction}.png')
    for font in ('dejavu_14.pf2', 'dejavu_16.pf2'):
        shutil.copy2(ROOT / 'profile/grub/themes/starfield' / font, ISO / font)
    INSTALLED.mkdir(parents=True, exist_ok=True)
    for asset in ISO.iterdir():
        if asset.is_file():
            shutil.copy2(asset, INSTALLED / asset.name)


if __name__ == '__main__':
    render()
