#!/usr/bin/env python3
"""Create a contact sheet from actual simulator PNGs. Requires Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'docs' / 'screenshots'
FONT = ROOT / 'assets' / 'fonts' / 'DMSans.ttf'
SCREENS = [
    ('04-home', 'NEARBY CAMERAS'),
    ('06-route', 'ROUTE TO STORE'),
    ('10-wallet', 'WALLET'),
    ('18-history', 'RENTAL HISTORY'),
    ('19-settings', 'PROFILE'),
]

canvas = Image.new('RGB', (1320, 720), '#EDEBF6')
draw = ImageDraw.Draw(canvas)
draw.text((34, 24), 'CAMSHARE', font=ImageFont.truetype(str(FONT), 34), fill='#243453')
draw.text((36, 70), 'Camera sharing app  /  Flutter  /  iPhone simulator', font=ImageFont.truetype(str(FONT), 17), fill='#8193AE')
for index, (name, label) in enumerate(SCREENS):
    image = Image.open(FOLDER / f'{name}.png').convert('RGB')
    image.thumbnail((232, 510), Image.Resampling.LANCZOS)
    x, y = 34 + index * 258, 122
    draw.rounded_rectangle((x - 3, y - 3, x + image.width + 3, y + image.height + 3), radius=22, fill='#FFFFFF')
    mask = Image.new('L', image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, image.width, image.height), radius=20, fill=255)
    canvas.paste(image, (x, y), mask)
    draw.text((x, 660), label, font=ImageFont.truetype(str(FONT), 15), fill='#243453')
canvas.save(FOLDER / 'overview.png', optimize=True)
print(FOLDER / 'overview.png')
