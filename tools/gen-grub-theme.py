#!/usr/bin/env python3
"""Generate the NeOS GRUB theme background (Nations Trust Bank palette).

The "NeOS" wordmark is baked into the background image so the GRUB theme
needs only a single loaded font (GRUB bitmap fonts are one-size-per-file),
which keeps the theme robust. Pure Pillow, no numpy — mirrors
tools/gen-wallpaper.py / tools/gen-boot-logo.py. Re-run to regenerate.

Output: profile/airootfs/usr/share/grub/themes/neos/background.png  (1920x1080)
"""
import os
import shutil
import subprocess
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEME_DIR = os.path.join(ROOT, "profile/airootfs/usr/share/grub/themes/neos")
OUT = os.path.join(THEME_DIR, "background.png")
PF2 = os.path.join(THEME_DIR, "neos.pf2")

BLUE    = (0x00, 0x88, 0xCF)
MAGENTA = (0xEB, 0x00, 0x8B)
TOP     = (0x0A, 0x0E, 0x1A)
BOTTOM  = (0x16, 0x20, 0x3A)
TEXT    = (0xE6, 0xE9, 0xF2)
W, H = 1920, 1080


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def load_font(size):
    for p in ("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"):
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def main():
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    # vertical navy gradient (rendered small + upscaled for smoothness)
    small = Image.new("RGB", (2, H))
    px = small.load()
    for y in range(H):
        c = lerp(TOP, BOTTOM, y / (H - 1))
        px[0, y] = c
        px[1, y] = c
    img = small.resize((W, H), Image.BILINEAR)
    d = ImageDraw.Draw(img)

    # NeOS wordmark, centered in the upper third, with NTB gradient accent rule
    f = load_font(120)
    text = "NeOS"
    bb = d.textbbox((0, 0), text, font=f)
    tw, th = bb[2] - bb[0], bb[3] - bb[1]
    tx = W // 2 - tw // 2 - bb[0]
    ty = int(H * 0.18)
    d.text((tx, ty), text, font=f, fill=TEXT)

    # accent rule (blue -> magenta)
    rw = int(tw * 0.6)
    rx = W // 2 - rw // 2
    ry = ty + th + 28
    for i in range(rw):
        col = lerp(BLUE, MAGENTA, i / (rw - 1))
        d.line([(rx + i, ry), (rx + i, ry + 6)], fill=col)

    img.save(OUT)
    print("wrote", OUT, img.size)

    gen_font()


def gen_font():
    """Generate the GRUB bitmap font (PF2) via grub-mkfont. Committed to the
    repo because CI builds with mkarchiso directly and never runs build.sh, so
    the font must already exist in profile/airootfs. The embedded name MUST
    match theme.txt ("DejaVu Sans Regular 18")."""
    mkfont = shutil.which("grub-mkfont") or shutil.which("grub2-mkfont")
    ttf = next((p for p in (
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/TTF/DejaVuSans.ttf",
    ) if os.path.exists(p)), None)
    if not mkfont or not ttf:
        print("WARNING: grub-mkfont or DejaVu TTF missing; left", PF2, "unchanged")
        return
    subprocess.run([mkfont, "-s", "18", "-n", "DejaVu Sans Regular 18",
                    "-o", PF2, ttf], check=True)
    print("wrote", PF2, os.path.getsize(PF2), "bytes")


if __name__ == "__main__":
    main()
