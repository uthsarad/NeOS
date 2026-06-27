#!/usr/bin/env python3
"""Generate the NeOS animated boot logo (Plymouth) + a preview GIF.

Brand: Nations Trust Bank (NTB) palette — blue #0088CF, cyan #0096D5,
magenta #EB008B — on a deep navy base, matching the desktop + installer.

Outputs:
  profile/airootfs/usr/share/plymouth/themes/neos/logo.png      (wordmark)
  profile/airootfs/usr/share/plymouth/themes/neos/spinner-NN.png (ring frames)
  docs/branding/neos-boot-logo.gif                               (preview)
  docs/branding/neos-boot-logo-preview.png                       (single frame)

No numpy (not on the dev box) — pure Pillow. Re-run to regenerate.
"""
import math, os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEME = os.path.join(ROOT, "profile/airootfs/usr/share/plymouth/themes/neos")
DOCS = os.path.join(ROOT, "docs/branding")

# ---- NTB palette -----------------------------------------------------------
BLUE    = (0x00, 0x88, 0xCF)
CYAN    = (0x00, 0x96, 0xD5)
MAGENTA = (0xEB, 0x00, 0x8B)
WHITE   = (0xFF, 0xFF, 0xFF)
BG_TOP    = (0x0A, 0x0E, 0x1A)
BG_BOTTOM = (0x16, 0x20, 0x3A)

NFRAMES = 36          # rotation frames (10 degrees each)
RING_PX = 160         # final ring size
SS = 3                # supersample factor for smooth anti-aliasing


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def ring_color(t):
    """Loop blue -> magenta -> blue over t in [0,1)."""
    t %= 1.0
    return lerp(BLUE, MAGENTA, t * 2) if t < 0.5 else lerp(MAGENTA, BLUE, (t - 0.5) * 2)


def load_font(size):
    for p in ("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"):
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def gradient_h(size, c0, c1):
    """Horizontal gradient RGBA image."""
    w, h = size
    img = Image.new("RGBA", size)
    px = img.load()
    for x in range(w):
        c = lerp(c0, c1, x / max(1, w - 1))
        for y in range(h):
            px[x, y] = (c[0], c[1], c[2], 255)
    return img


def make_logo():
    """NeOS wordmark in an NTB blue->magenta gradient + accent rule."""
    W, H = 600, 360
    font = load_font(132)
    text = "NeOS"

    # measure
    tmp = Image.new("L", (1, 1))
    d = ImageDraw.Draw(tmp)
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]

    mask = Image.new("L", (W, H), 0)
    md = ImageDraw.Draw(mask)
    tx = (W - tw) // 2 - bbox[0]
    ty = (H - th) // 2 - bbox[1] - 18
    md.text((tx, ty), text, fill=255, font=font)

    grad = gradient_h((W, H), CYAN, MAGENTA)
    logo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    logo = Image.composite(grad, logo, mask)

    # accent rule (blue->magenta) under the wordmark
    rule = gradient_h((int(tw * 0.62), 8), BLUE, MAGENTA)
    rx = (W - rule.width) // 2
    ry = (H + th) // 2 - 6
    logo.alpha_composite(rule, (rx, ry))
    return logo


def make_ring_frame(offset_turns):
    """Rotating gradient ring as a transparent PNG (offset in [0,1))."""
    big = RING_PX * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = int(big * 0.10)
    box = [pad, pad, big - pad, big - pad]
    width = int(big * 0.085)
    step = 3  # degrees per segment
    for deg in range(0, 360, step):
        t = ((deg / 360.0) + offset_turns) % 1.0
        col = ring_color(t)
        # comet-style brightness: fade trailing edge for a sense of motion
        d.arc(box, deg - 90, deg - 90 + step + 1, fill=(col[0], col[1], col[2], 255), width=width)
    return img.resize((RING_PX, RING_PX), Image.LANCZOS)


def bg_canvas(size):
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        c = lerp(BG_TOP, BG_BOTTOM, y / max(1, h - 1))
        for x in range(w):
            px[x, y] = c
    return img


def main():
    os.makedirs(THEME, exist_ok=True)
    os.makedirs(DOCS, exist_ok=True)

    # 1) static logo
    logo = make_logo()
    logo.save(os.path.join(THEME, "logo.png"))
    print("wrote logo.png", logo.size)

    # 2) spinner frames
    frames = []
    for i in range(NFRAMES):
        f = make_ring_frame(i / NFRAMES)
        f.save(os.path.join(THEME, f"spinner-{i:02d}.png"))
        frames.append(f)
    print(f"wrote {NFRAMES} spinner frames")

    # 3) preview GIF (downscaled logo + spinning ring on dark bg)
    GW, GH = 720, 460
    logo_small = logo.resize((int(logo.width * 0.62), int(logo.height * 0.62)), Image.LANCZOS)
    gif_frames = []
    for i in range(NFRAMES):
        canvas = bg_canvas((GW, GH)).convert("RGBA")
        canvas.alpha_composite(logo_small, ((GW - logo_small.width) // 2, 60))
        ring = frames[i]
        canvas.alpha_composite(ring, ((GW - ring.width) // 2, 300))
        gif_frames.append(canvas.convert("P", palette=Image.ADAPTIVE, colors=128))
    gif_path = os.path.join(DOCS, "neos-boot-logo.gif")
    gif_frames[0].save(gif_path, save_all=True, append_images=gif_frames[1:],
                       duration=45, loop=0, optimize=True, disposal=2)
    print("wrote", gif_path)

    # 4) single-frame PNG preview (for quick viewing)
    prev = bg_canvas((GW, GH)).convert("RGBA")
    prev.alpha_composite(logo_small, ((GW - logo_small.width) // 2, 60))
    prev.alpha_composite(frames[NFRAMES // 4], ((GW - RING_PX) // 2, 300))
    prev.convert("RGB").save(os.path.join(DOCS, "neos-boot-logo-preview.png"))
    print("wrote neos-boot-logo-preview.png")


if __name__ == "__main__":
    main()
