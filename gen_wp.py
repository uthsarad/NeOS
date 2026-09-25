from PIL import Image, ImageDraw
import random

width = 1920
height = 1080

img = Image.new('RGB', (width, height))
draw = ImageDraw.Draw(img)

# Gradient background (180deg,#030711 0%,#061224 45%,#0a1d33 100%)
for y in range(height):
    if y < height * 0.45:
        # Interpolate #030711 (3,7,17) to #061224 (6,18,36)
        r = int(3 + (6 - 3) * (y / (height * 0.45)))
        g = int(7 + (18 - 7) * (y / (height * 0.45)))
        b = int(17 + (36 - 17) * (y / (height * 0.45)))
    else:
        # Interpolate #061224 (6,18,36) to #0a1d33 (10,29,51)
        r = int(6 + (10 - 6) * ((y - height * 0.45) / (height * 0.55)))
        g = int(18 + (29 - 18) * ((y - height * 0.45) / (height * 0.55)))
        b = int(36 + (51 - 36) * ((y - height * 0.45) / (height * 0.55)))
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Stars
random.seed(3)
for _ in range(120):
    x = random.randint(0, width)
    y = random.randint(0, int(height * 0.6))
    r = random.uniform(1.0, 2.5)
    draw.ellipse((x-r, y-r, x+r, y+r), fill=(219, 234, 254, 150))

img.save('profile/airootfs/usr/share/backgrounds/neos-wallpaper.png')
print("Saved wallpaper!")
