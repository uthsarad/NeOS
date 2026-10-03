#!/usr/bin/env python3
"""Generate the NeOS logo mark.

Replaces the old AI-generated blue/white swirl-vortex "neo" clip-art with a
NeOS-owned, macOS-app-icon-style badge: a rounded-square (squircle), the
brand accent as a vertical gradient, a soft top highlight for restrained
depth, and a clean geometric "N" monogram — no wordmark, so it stays legible
at small sizes. Palette comes from tools/palette.json, the same source of
truth the rest of the rebrand uses.

Usage: tools/gen-logo.py [output.png] [--size WxH]
       tools/gen-logo.py --all     regenerate every shipped copy of the logo:
                                   the Calamares branding logo, docs/assets,
                                   the Plymouth splash, and the `neos-logo`
                                   icon set (hicolor + pixmaps) that
                                   /etc/os-release LOGO= names
"""
import sys
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

SS = 4  # supersample factor for anti-aliased edges on the squircle/monogram


def _hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


_PALETTE = json.loads((Path(__file__).parent / "palette.json").read_text())
ACCENT = _hex_to_rgb(_PALETTE["accent"])
ACCENT_DEEP = _hex_to_rgb(_PALETTE["accentDeep"])


def render(size):
    W, H = size
    BW, BH = W * SS, H * SS
    return _render(W, H, BW, BH)


def _render(W, H, BW, BH):


    # ---- Squircle badge (superellipse-ish via a heavily rounded rectangle) ----
    margin = int(BW * 0.03)
    badge_box = (margin, margin, BW - margin, BH - margin)
    radius = int(min(BW, BH) * 0.30)  # macOS-style continuous-corner radius

    mask = Image.new("L", (BW, BH), 0)
    ImageDraw.Draw(mask).rounded_rectangle(badge_box, radius=radius, fill=255)

    # ---- Vertical gradient fill: accent at the top -> accentDeep at the bottom
    fill = Image.new("RGB", (BW, BH))
    fpx = fill.load()
    for y in range(BH):
        t = y / BH
        c = tuple(int(ACCENT[i] + (ACCENT_DEEP[i] - ACCENT[i]) * t) for i in range(3))
        for x in range(BW):
            fpx[x, y] = c

    badge = Image.new("RGBA", (BW, BH), (0, 0, 0, 0))
    badge.paste(fill, (0, 0), mask)

    # ---- Soft top highlight (restrained specular gloss, macOS-style) ----------
    highlight = Image.new("L", (BW, BH), 0)
    hd = ImageDraw.Draw(highlight)
    hd.ellipse(
        [BW * 0.08, -BH * 0.35, BW * 0.92, BH * 0.55],
        fill=60,
    )
    highlight = highlight.filter(ImageFilter.GaussianBlur(BW * 0.04))
    white = Image.new("RGBA", (BW, BH), (255, 255, 255, 255))
    # Only show the highlight inside the badge shape.
    highlight_masked = Image.new("L", (BW, BH), 0)
    highlight_masked.paste(highlight, (0, 0), mask)
    badge = Image.composite(white, badge, highlight_masked)

    # ---- "N" monogram: three bold geometric strokes, centered ----------------
    mono = Image.new("L", (BW, BH), 0)
    md = ImageDraw.Draw(mono)
    cx, cy, s = BW * 0.5, BH * 0.5, min(BW, BH) * 0.30
    lw = int(s * 0.34)
    md.line([(cx - s * 0.55, cy + s * 0.62), (cx - s * 0.55, cy - s * 0.62)], fill=255, width=lw, joint="curve")
    md.line([(cx - s * 0.55, cy - s * 0.62), (cx + s * 0.55, cy + s * 0.62)], fill=255, width=lw, joint="curve")
    md.line([(cx + s * 0.55, cy - s * 0.62), (cx + s * 0.55, cy + s * 0.62)], fill=255, width=lw, joint="curve")
    # Round the stroke ends so joints don't look clipped.
    capr = lw // 2
    for jx, jy in [
        (cx - s * 0.55, cy + s * 0.62), (cx - s * 0.55, cy - s * 0.62),
        (cx + s * 0.55, cy + s * 0.62), (cx + s * 0.55, cy - s * 0.62),
    ]:
        md.ellipse([jx - capr, jy - capr, jx + capr, jy + capr], fill=255)

    badge = Image.composite(Image.new("RGBA", (BW, BH), (255, 255, 255, 255)), badge, mono)

    return badge.resize((W, H), Image.LANCZOS)


def save(img, out):
    Path(out).parent.mkdir(parents=True, exist_ok=True)
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out} ({img.width}x{img.height})")


def main(argv):
    out = "profile/airootfs/etc/calamares/branding/neos/logo.png"
    size = (256, 256)
    if "--all" in argv:
        master = render((512, 512))
        save(render((256, 256)), "profile/airootfs/etc/calamares/branding/neos/logo.png")
        save(render((256, 256)), "docs/assets/neos-logo.png")
        save(render((160, 160)), "profile/airootfs/usr/share/plymouth/themes/neos/logo.png")
        save(render((256, 256)), "profile/airootfs/usr/share/pixmaps/neos-logo.png")
        for px in (16, 22, 24, 32, 48, 64, 128, 256, 512):
            img = master if px == 512 else render((px, px))
            save(img, f"profile/airootfs/usr/share/icons/hicolor/{px}x{px}/apps/neos-logo.png")
        return
    for arg in argv:
        if arg.startswith("--size"):
            w, h = arg.split("=", 1)[1].split("x")
            size = (int(w), int(h))
        else:
            out = arg
    save(render(size), out)


if __name__ == "__main__":
    main(sys.argv[1:])
