#!/usr/bin/env python3
"""Generates placeholder art for a town game (map, sprite, icons, weather photos).

These are programmatic stand-ins so the game is playable end to end without
real photography/artwork. Swap the PNGs in <game>/assets/ for real assets
later without touching any game code -- filenames are the contract.

Usage: python3 gen_placeholder_art.py <output_assets_dir>
"""
import sys
import os
import math
import random
from PIL import Image, ImageDraw, ImageFont

random.seed(42)


def font(size):
    try:
        return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size)
    except Exception:
        return ImageFont.load_default()


def save(img, path):
    img.save(path)
    print("wrote", path)


def gen_map(path, size=1600):
    img = Image.new("RGB", (size, size), (227, 214, 178))  # beige countryside
    d = ImageDraw.Draw(img)

    # Box Hill - green hill mass, north
    d.ellipse([550, 60, 1150, 520], fill=(118, 168, 92))
    d.ellipse([620, 120, 1000, 420], fill=(96, 148, 78))

    # Denbies Wine Estate - vineyard rows, northwest
    d.rectangle([150, 250, 620, 560], fill=(168, 196, 118))
    for y in range(260, 550, 22):
        d.line([(170, y), (600, y)], fill=(120, 150, 70), width=4)

    # River Pipp Brook, winding through east side
    pts = [(1150, 100), (1180, 400), (1120, 650), (1250, 950), (1200, 1300), (1260, 1600)]
    d.line(pts, fill=(110, 160, 210), width=14, joint="curve")

    # Town center built-up area
    d.rectangle([650, 600, 1350, 1000], fill=(214, 200, 170))

    # Roads (grey grid through town center -> High Street is the main one)
    d.rectangle([700, 740, 1300, 790], fill=(150, 145, 140))  # High Street, east-west
    d.rectangle([900, 600, 950, 1300], fill=(150, 145, 140))  # north-south road
    d.rectangle([600, 1150, 1400, 1200], fill=(150, 145, 140))  # southern road

    # Station rail lines
    d.line([(0, 1020), (1600, 1020)], fill=(90, 90, 95), width=10)
    d.line([(1100, 1020), (1180, 600)], fill=(90, 90, 95), width=8)

    # Deepdene / Presselly area - parkland east, gives "home" its setting
    d.ellipse([1100, 650, 1450, 950], fill=(140, 178, 110))

    # Sports field for tennis club
    d.rectangle([600, 1080, 820, 1240], fill=(108, 168, 96))
    d.rectangle([615, 1095, 805, 1225], outline=(255, 255, 255), width=3)

    save(img, path)


def gen_squirrel(path, size=160):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    white = (250, 250, 248, 255)
    pink = (235, 180, 190, 255)
    outline = (210, 205, 200, 255)

    # tail (big fluffy curl behind)
    d.ellipse([size * 0.45, size * 0.05, size * 0.98, size * 0.62], fill=white, outline=outline, width=3)
    d.ellipse([size * 0.55, size * 0.12, size * 0.90, size * 0.50], fill=(0, 0, 0, 0))

    # body
    d.ellipse([size * 0.18, size * 0.40, size * 0.62, size * 0.85], fill=white, outline=outline, width=3)
    # head
    d.ellipse([size * 0.08, size * 0.22, size * 0.42, size * 0.56], fill=white, outline=outline, width=3)
    # ears
    d.ellipse([size * 0.10, size * 0.16, size * 0.20, size * 0.28], fill=white, outline=outline, width=2)
    d.ellipse([size * 0.28, size * 0.14, size * 0.38, size * 0.26], fill=white, outline=outline, width=2)
    # inner ears (pink)
    d.ellipse([size * 0.12, size * 0.19, size * 0.17, size * 0.25], fill=pink)
    d.ellipse([size * 0.30, size * 0.17, size * 0.35, size * 0.23], fill=pink)
    # nose
    d.ellipse([size * 0.06, size * 0.36, size * 0.13, size * 0.43], fill=pink)
    # eye (red-ish, albino trait)
    d.ellipse([size * 0.18, size * 0.32, size * 0.23, size * 0.37], fill=(200, 90, 90, 255))
    # paws
    d.ellipse([size * 0.20, size * 0.72, size * 0.32, size * 0.84], fill=white, outline=outline, width=2)
    # red tracking collar (ranger theme)
    d.rectangle([size * 0.14, size * 0.50, size * 0.40, size * 0.56], fill=(200, 60, 50, 255))

    save(img, path)


def gen_explosion(path, size=200):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = size / 2, size / 2
    spikes = 10
    outer = size * 0.48
    inner = size * 0.18
    points = []
    for i in range(spikes * 2):
        angle = math.pi * i / spikes
        r = outer if i % 2 == 0 else inner
        points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    d.polygon(points, fill=(255, 200, 60, 255))
    d.ellipse([cx - inner, cy - inner, cx + inner, cy + inner], fill=(255, 120, 40, 255))
    d.ellipse([cx - inner * 0.5, cy - inner * 0.5, cx + inner * 0.5, cy + inner * 0.5], fill=(255, 245, 200, 255))
    save(img, path)


def gen_fox(path, size=160):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    orange = (216, 110, 40, 255)
    dark = (90, 50, 25, 255)
    white = (250, 248, 240, 255)
    outline = (140, 75, 30, 255)

    # tail
    d.polygon([
        (size * 0.55, size * 0.55), (size * 0.98, size * 0.30),
        (size * 0.92, size * 0.55), (size * 0.62, size * 0.70),
    ], fill=orange, outline=outline)
    d.ellipse([size * 0.80, size * 0.26, size * 0.96, size * 0.42], fill=white)

    # body
    d.ellipse([size * 0.18, size * 0.42, size * 0.62, size * 0.85], fill=orange, outline=outline, width=3)
    # head
    d.ellipse([size * 0.06, size * 0.22, size * 0.40, size * 0.56], fill=orange, outline=outline, width=3)
    # ears
    d.polygon([(size * 0.08, size * 0.24), (size * 0.16, size * 0.06), (size * 0.22, size * 0.24)], fill=orange, outline=outline)
    d.polygon([(size * 0.26, size * 0.22), (size * 0.32, size * 0.04), (size * 0.38, size * 0.22)], fill=orange, outline=outline)
    # snout
    d.polygon([(size * 0.02, size * 0.40), (size * 0.18, size * 0.36), (size * 0.18, size * 0.48)], fill=white)
    d.ellipse([size * 0.02, size * 0.42, size * 0.08, size * 0.48], fill=dark)
    # eye
    d.ellipse([size * 0.20, size * 0.32, size * 0.26, size * 0.38], fill=dark)
    # paws
    d.ellipse([size * 0.20, size * 0.74, size * 0.32, size * 0.86], fill=dark)

    save(img, path)


def gen_acorn(path, size=64):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([size * 0.18, size * 0.30, size * 0.82, size * 0.92], fill=(150, 100, 60, 255), outline=(90, 60, 35, 255), width=2)
    d.polygon([
        (size * 0.16, size * 0.34), (size * 0.84, size * 0.34),
        (size * 0.78, size * 0.16), (size * 0.22, size * 0.16),
    ], fill=(110, 80, 45, 255), outline=(70, 50, 25, 255))
    d.rectangle([size * 0.46, size * 0.02, size * 0.54, size * 0.18], fill=(70, 50, 25, 255))
    save(img, path)


def gen_pin(path, size=72, color=(40, 130, 120, 255)):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([size * 0.18, size * 0.04, size * 0.82, size * 0.62], fill=color, outline=(20, 60, 55, 255), width=3)
    d.polygon([(size * 0.5, size * 0.95), (size * 0.30, size * 0.50), (size * 0.70, size * 0.50)], fill=color)
    d.ellipse([size * 0.38, size * 0.22, size * 0.62, size * 0.44], fill=(255, 255, 255, 255))
    save(img, path)


def gen_home_icon(path, size=72):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(size * 0.5, size * 0.08), (size * 0.10, size * 0.45), (size * 0.90, size * 0.45)], fill=(150, 90, 50, 255))
    d.rectangle([size * 0.20, size * 0.45, size * 0.80, size * 0.92], fill=(200, 150, 100, 255), outline=(120, 80, 40, 255), width=2)
    d.rectangle([size * 0.42, size * 0.62, size * 0.58, size * 0.92], fill=(90, 60, 35, 255))
    save(img, path)


SKY_PRESETS = {
    "sunny": {"top": (90, 170, 235), "bottom": (200, 230, 250), "sun": True, "rain": False, "snow": False, "stars": False},
    "cloudy": {"top": (140, 150, 160), "bottom": (190, 195, 200), "sun": False, "rain": False, "snow": False, "stars": False},
    "rainy": {"top": (70, 80, 95), "bottom": (110, 120, 130), "sun": False, "rain": True, "snow": False, "stars": False},
    "snowy": {"top": (190, 200, 215), "bottom": (235, 238, 245), "sun": False, "rain": False, "snow": True, "stars": False},
    "night": {"top": (10, 14, 35), "bottom": (35, 40, 70), "sun": False, "rain": False, "snow": False, "stars": True},
    "default": {"top": (120, 150, 180), "bottom": (180, 200, 210), "sun": False, "rain": False, "snow": False, "stars": False},
}


def gen_photo(path, preset_name, w=900, h=1400, caption="Box Hill, Dorking"):
    p = SKY_PRESETS[preset_name]
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        col = tuple(int(p["top"][i] * (1 - t) + p["bottom"][i] * t) for i in range(3))
        d.line([(0, y), (w, y)], fill=col)

    if p["sun"]:
        d.ellipse([w * 0.65, h * 0.08, w * 0.85, h * 0.22], fill=(255, 235, 150))
    if p["stars"]:
        for _ in range(80):
            x, y = random.randint(0, w), random.randint(0, int(h * 0.5))
            d.ellipse([x, y, x + 2, y + 2], fill=(230, 230, 255))
        d.ellipse([w * 0.7, h * 0.10, w * 0.85, h * 0.22], fill=(235, 235, 220))

    # rolling hill silhouette (stand-in for Box Hill)
    base_y = int(h * 0.62)
    hill = [(0, h)]
    for x in range(0, w + 20, 20):
        hill.append((x, base_y - int(70 * math.sin(x / 140.0)) - int(0.05 * (w - x))))
    hill.append((w, h))
    hill_color = (40, 70, 40) if preset_name != "night" else (15, 25, 20)
    d.polygon(hill, fill=hill_color)

    if p["rain"]:
        for _ in range(140):
            x, y = random.randint(0, w), random.randint(0, h)
            d.line([(x, y), (x - 6, y + 18)], fill=(200, 210, 230), width=2)
    if p["snow"]:
        for _ in range(160):
            x, y = random.randint(0, w), random.randint(0, h)
            r = random.choice([2, 3, 4])
            d.ellipse([x, y, x + r, y + r], fill=(255, 255, 255))

    fnt = font(34)
    small = font(22)
    d.rectangle([0, h - 90, w, h], fill=(0, 0, 0, 140))
    d.text((20, h - 78), caption, font=fnt, fill=(255, 255, 255))
    d.text((20, h - 38), "(placeholder photo)", font=small, fill=(220, 220, 220))
    save(img, path)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "."
    os.makedirs(out, exist_ok=True)

    core_fx_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "core", "assets", "fx")
    os.makedirs(core_fx_dir, exist_ok=True)
    gen_explosion(os.path.join(core_fx_dir, "explosion.png"))

    gen_map(os.path.join(out, "map_background.png"))
    gen_squirrel(os.path.join(out, "sprite_squirrel.png"))
    gen_fox(os.path.join(out, "sprite_fox.png"))
    gen_acorn(os.path.join(out, "icon_acorn.png"))
    gen_pin(os.path.join(out, "icon_landmark_pin.png"))
    gen_home_icon(os.path.join(out, "icon_home.png"))
    for preset in SKY_PRESETS:
        gen_photo(os.path.join(out, f"photo_{preset}.png"), preset)


if __name__ == "__main__":
    main()
