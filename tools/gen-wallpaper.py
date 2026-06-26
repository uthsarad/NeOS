#!/usr/bin/env python3
"""Generate the NeOS desktop wallpaper.

Produces a clean, modern dark-blue "mesh gradient" wallpaper that matches the
NeOS brand mark (deep navy field with a brand-blue glow and a subtle "N"
monogram). Rendered small for smooth gradients then upscaled, with a light
grain pass to avoid banding on flat panels.

Usage: tools/gen-wallpaper.py [output.png]
"""
import sys
import math
import random
from PIL import Image, ImageDraw, ImageFilter

OUT = sys.argv[1] if len(sys.argv) > 1 else \
    "profile/airootfs/usr/share/backgrounds/neos-wallpaper.png"

W, H = 3840, 2160
SW, SH = 640, 360  # render gradients small, upscale for perfect smoothness

# Brand palette: deep navy base, NeOS brand blue meeting a "Neo Red" accent.
# Blue (identity) lower-left, red (named after Neo Red) upper-right, with a
# magenta transition where they blend — a clean, premium fintech-app look.
BASE_TOP = (6, 9, 18)
BASE_BOTTOM = (12, 14, 28)
BLOBS = [
    # (cx, cy as fractions, radius fraction, color, strength)
    (0.20, 0.78, 0.55, (31, 111, 214), 0.90),   # brand blue, lower-left
    (0.84, 0.26, 0.52, (214, 46, 58), 0.78),    # Neo Red, upper-right
    (0.55, 0.50, 0.42, (150, 42, 120), 0.30),   # magenta blend, center
    (0.78, 0.80, 0.34, (190, 60, 70), 0.28),    # warm red glow, lower-right
    (0.30, 0.16, 0.40, (30, 60, 130), 0.34),    # cool blue top fill
]
MONO_GLOW = (235, 90, 95)  # Neo Red tinted "N" monogram


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def screen(base, add, k):
    """Screen-blend `add` onto `base` scaled by k (0..1)."""
    return tuple(
        int(255 - (255 - base[i]) * (255 - add[i] * k) / 255)
        for i in range(3)
    )


# --- base diagonal gradient + screen-blended blobs (small res) ---
small = Image.new("RGB", (SW, SH))
px = small.load()
for y in range(SH):
    for x in range(SW):
        t = (x / SW * 0.35 + y / SH * 0.65)
        c = lerp(BASE_TOP, BASE_BOTTOM, t)
        for bx, by, br, col, strength in BLOBS:
            dx = (x / SW - bx)
            dy = (y / SH - by) * (SW / SH)  # keep blobs circular
            d = math.sqrt(dx * dx + dy * dy)
            f = max(0.0, 1.0 - d / br)
            f = f * f * (3 - 2 * f)  # smoothstep falloff
            if f > 0:
                c = screen(c, col, f * strength)
        px[x, y] = c

img = small.resize((W, H), Image.BICUBIC).filter(ImageFilter.GaussianBlur(2))

# --- subtle "N" monogram watermark, centered, very low opacity ---
mono = Image.new("L", (W, H), 0)
md = ImageDraw.Draw(mono)
cx, cy, s = W * 0.5, H * 0.5, H * 0.30
lw = int(s * 0.16)
# Three strokes of an "N": left vertical, diagonal, right vertical
md.line([(cx - s * 0.5, cy + s * 0.5), (cx - s * 0.5, cy - s * 0.5)], fill=70, width=lw)
md.line([(cx - s * 0.5, cy - s * 0.5), (cx + s * 0.5, cy + s * 0.5)], fill=70, width=lw)
md.line([(cx + s * 0.5, cy - s * 0.5), (cx + s * 0.5, cy + s * 0.5)], fill=70, width=lw)
mono = mono.filter(ImageFilter.GaussianBlur(3))
glow = Image.new("RGB", (W, H), MONO_GLOW)
img = Image.composite(glow, img, mono.point(lambda v: int(v * 0.35)))

# --- vignette to keep edges calm ---
vig = Image.new("L", (SW, SH), 0)
vd = ImageDraw.Draw(vig)
vd.ellipse([-SW * 0.25, -SH * 0.25, SW * 1.25, SH * 1.25], fill=255)
vig = vig.resize((W, H), Image.BICUBIC).filter(ImageFilter.GaussianBlur(120))
dark = Image.new("RGB", (W, H), (3, 5, 11))
img = Image.composite(img, dark, vig)

# --- fine grain to kill banding ---
random.seed(7)
grain = Image.effect_noise((W, H), 8).convert("L")
img = Image.composite(
    Image.blend(img, Image.new("RGB", (W, H), (255, 255, 255)), 0.02),
    img, grain.point(lambda v: int(abs(v - 128)))
)

img.save(OUT, "PNG", optimize=True)
print(f"wrote {OUT} ({W}x{H})")
