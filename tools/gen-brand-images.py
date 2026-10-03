#!/usr/bin/env python3
"""Generate NeOS's raster brand images from the palette and the logo.

Writes:
  profile/airootfs/etc/calamares/branding/neos/welcome.png  (600x300)
      the installer's welcome-page banner: logo and wordmark on the night-sky
      background.
  profile/syslinux/splash.png  (640x480)
      the BIOS boot-menu background: the same sky, kept quiet because the
      menu is drawn on top of it.
  profile/airootfs/usr/share/plymouth/themes/neos/dot.png  (24x24)
      the boot splash's progress dot (Plymouth scripts cannot draw shapes).

Both use the wallpaper's gradient and star colour (tools/gen-wallpaper.py) and
the logo from tools/gen-logo.py, so every boot and install surface matches.
Run after changing the palette or the logo:  tools/gen-brand-images.py
"""
import importlib.util
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
TOP, MIDDLE, BOTTOM = (3, 7, 17), (6, 18, 36), (10, 29, 51)
STAR = (219, 234, 254)
TEXT = (230, 233, 242)
FONT_CANDIDATES = (
    "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",            # Arch
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",  # Debian/Ubuntu
)


def sky(width, height, seed, stars, star_band=0.75):
    img = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(img)
    for y in range(height):
        t = y / height
        a, b, u = (TOP, MIDDLE, t / 0.45) if t < 0.45 else (MIDDLE, BOTTOM, (t - 0.45) / 0.55)
        draw.line([(0, y), (width, y)], fill=tuple(int(x + (z - x) * u) for x, z in zip(a, b)))
    rng = random.Random(seed)
    layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    for _ in range(stars):
        x, y = rng.uniform(0, width), rng.uniform(0, height * star_band)
        r = rng.uniform(0.5, 1.4)
        ld.ellipse((x - r, y - r, x + r, y + r), fill=STAR + (int(rng.uniform(70, 170)),))
    return Image.alpha_composite(img.convert("RGBA"), layer)


def logo(px):
    spec = importlib.util.spec_from_file_location("gen_logo", ROOT / "tools/gen-logo.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.render((px, px))


def font(size):
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    raise SystemExit("DejaVu Sans Bold not found (install ttf-dejavu / fonts-dejavu-core)")


def welcome():
    img = sky(600, 300, seed=7, stars=70)
    mark = logo(112)
    img.alpha_composite(mark, ((600 - 112) // 2, 52))
    draw = ImageDraw.Draw(img)
    f = font(40)
    text = "NeOS"
    w = draw.textlength(text, font=f)
    draw.text(((600 - w) / 2, 182), text, font=f, fill=TEXT)
    out = ROOT / "profile/airootfs/etc/calamares/branding/neos/welcome.png"
    img.convert("RGB").save(out, optimize=True)
    print(f"wrote {out.relative_to(ROOT)}")


def splash():
    img = sky(640, 480, seed=11, stars=90, star_band=1.0)
    out = ROOT / "profile/syslinux/splash.png"
    img.convert("RGB").save(out, optimize=True)
    print(f"wrote {out.relative_to(ROOT)}")


def plymouth_dot():
    ss = 8
    big = Image.new("RGBA", (24 * ss, 24 * ss), (0, 0, 0, 0))
    ImageDraw.Draw(big).ellipse((2 * ss, 2 * ss, 22 * ss, 22 * ss), fill=(56, 189, 248, 255))
    out = ROOT / "profile/airootfs/usr/share/plymouth/themes/neos/dot.png"
    big.resize((24, 24), Image.LANCZOS).save(out, optimize=True)
    print(f"wrote {out.relative_to(ROOT)}")


if __name__ == "__main__":
    welcome()
    splash()
    plymouth_dot()
