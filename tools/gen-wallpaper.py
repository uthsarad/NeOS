#!/usr/bin/env python3
"""Generate the NeOS desktop wallpaper (night-sky starfield).

A vertical navy gradient with a field of soft stars in the upper sky. It is the
raster twin of tools/wallpaper-reference.html (same gradient stops and star
colour), seeded so the output is reproducible byte for byte: re-running this
script with no arguments regenerates the shipped asset unchanged.

Usage: tools/gen-wallpaper.py [output.png]
"""
import random
import sys

from PIL import Image, ImageDraw

OUT = sys.argv[1] if len(sys.argv) > 1 else \
    "profile/airootfs/usr/share/backgrounds/neos-wallpaper.png"

WIDTH, HEIGHT = 1920, 1080

# Gradient stops, as in the reference: 180deg, #030711 0%, #061224 45%, #0a1d33 100%.
TOP, MIDDLE, BOTTOM = (3, 7, 17), (6, 18, 36), (10, 29, 51)
MIDPOINT = 0.45

STAR_SEED = 3
STAR_COUNT = 120
STAR_COLOUR = (219, 234, 254, 150)  # #dbeafe


def _lerp(a, b, t):
    return tuple(int(x + (y - x) * t) for x, y in zip(a, b))


def main():
    img = Image.new("RGB", (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(img)

    for y in range(HEIGHT):
        if y < HEIGHT * MIDPOINT:
            colour = _lerp(TOP, MIDDLE, y / (HEIGHT * MIDPOINT))
        else:
            colour = _lerp(MIDDLE, BOTTOM, (y - HEIGHT * MIDPOINT) / (HEIGHT * (1 - MIDPOINT)))
        draw.line([(0, y), (WIDTH, y)], fill=colour)

    random.seed(STAR_SEED)
    for _ in range(STAR_COUNT):
        x = random.randint(0, WIDTH)
        y = random.randint(0, int(HEIGHT * 0.6))
        r = random.uniform(1.0, 2.5)
        draw.ellipse((x - r, y - r, x + r, y + r), fill=STAR_COLOUR)

    img.save(OUT)
    print(f"Saved wallpaper -> {OUT}")


if __name__ == "__main__":
    main()
