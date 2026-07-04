#!/usr/bin/env python3
"""Generate the NeOS Plymouth boot-splash animation frames from a source GIF.

The boot splash is a Plymouth `script` theme (themes/neos/neos.script) that
cycles through cat-NN.png frames centered on a dark background — the cat body
is perfectly still and ONLY the tail animates.

CI never runs this (it builds the ISO with mkarchiso from checked-in files), so
the generated cat-*.png frames are COMMITTED. Re-run this only when the source
GIF changes:

    python3 tools/gen-bootlogo-frames.py

Source : tools/loader-cat.gif
Output : profile/airootfs/usr/share/plymouth/themes/neos/cat-NN.png
"""
from pathlib import Path
from collections import Counter
from PIL import Image

REPO = Path(__file__).resolve().parent.parent
SRC = REPO / "tools" / "loader-cat.gif"
DEST = REPO / "profile/airootfs/usr/share/plymouth/themes/neos"
SCALE = 2  # source cels are drawn small; 2x keeps them readable on a 1080p+ boot screen
MARGIN = 20  # transparent breathing room around the animation on the output canvas


def _rgba_key(pixel):
    """Return a hashable key for an RGBA pixel tuple."""
    return pixel  # tuple is already hashable


def _mode_pixel(pixel_list):
    """Return the most common RGBA value from a list of pixel tuples."""
    c = Counter(pixel_list)
    return c.most_common(1)[0][0]


def main() -> None:
    im = Image.open(SRC)
    n = im.n_frames
    DEST.mkdir(parents=True, exist_ok=True)

    # ------------------------------------------------------------------
    # Pass 1: composite + crop each frame to its opaque content.  The
    # source GIF anchors the cat in the top-left of its canvas, so
    # resizing the raw canvas would leave the cat off-centre and
    # wobbling as its content size changes frame to frame.  Cropping to
    # the visible pixels lets us re-centre it.
    # ------------------------------------------------------------------
    cels = []
    for i in range(n):
        im.seek(i)
        frame = im.convert("RGBA")
        bbox = frame.getbbox()
        cels.append(frame.crop(bbox) if bbox else frame)

    # Remove trailing identical "freeze" frames so the loop is seamless.
    while len(cels) > 1 and cels[-1].tobytes() == cels[-2].tobytes():
        cels.pop()

    n_frames = len(cels)

    # A single canvas sized to the largest cel keeps every output frame the
    # same dimensions, so neos.script centres them identically — the cat
    # stays put.
    out_w = max(c.width for c in cels) * SCALE + 2 * MARGIN
    out_h = max(c.height for c in cels) * SCALE + 2 * MARGIN

    # ------------------------------------------------------------------
    # Pass 2: scale cels to output size.
    # ------------------------------------------------------------------
    scaled = []
    for cel in cels:
        scaled.append(cel.resize((cel.width * SCALE, cel.height * SCALE), Image.LANCZOS))

    # ------------------------------------------------------------------
    # Pass 3: centre each cel on the shared canvas (full-frame originals).
    # ------------------------------------------------------------------
    originals = []
    for cel in scaled:
        canvas = Image.new("RGBA", (out_w, out_h), (0, 0, 0, 0))
        canvas.paste(cel, ((out_w - cel.width) // 2, (out_h - cel.height) // 2), cel)
        originals.append(canvas)

    # ------------------------------------------------------------------
    # Pass 4: compute a per-pixel "mode" (most common value across all
    # frames) to serve as the static body.  Pixels that *change* across
    # frames are the tail animation.
    # ------------------------------------------------------------------
    w, h = out_w, out_h
    # Collect all pixel values per coordinate
    pixel_values = [[[] for _ in range(h)] for _ in range(w)]
    for orig in originals:
        px = orig.load()
        for y in range(h):
            for x in range(w):
                pixel_values[x][y].append(px[x, y])

    # Build static image from the mode of each pixel
    static = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    spx = static.load()
    for y in range(h):
        for x in range(w):
            spx[x, y] = _mode_pixel(pixel_values[x][y])

    # Determine which pixels vary across frames (these are the tail)
    varying_pixels = set()
    for orig in originals:
        opx = orig.load()
        for y in range(h):
            for x in range(w):
                if opx[x, y] != spx[x, y]:
                    varying_pixels.add((x, y))

    print(f"Static cat body: {w}x{h}")
    print(f"Varying (tail) pixels: {len(varying_pixels)} / {w * h}")

    # ------------------------------------------------------------------
    # Pass 5: build the final frames — static body + animated tail.
    # ------------------------------------------------------------------
    for stale in DEST.glob("cat-*.png"):
        stale.unlink()

    for i, orig in enumerate(originals):
        opx = orig.load()
        canvas = static.copy()
        cpx = canvas.load()
        for (x, y) in varying_pixels:
            cpx[x, y] = opx[x, y]
        canvas.save(DEST / f"cat-{i:02d}.png")

    print(f"Wrote {n_frames} tail-only-animation frames ({w}x{h}) to {DEST}")


if __name__ == "__main__":
    main()
