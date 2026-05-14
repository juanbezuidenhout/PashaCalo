#!/usr/bin/env python3
"""Normalize brand logos so they have consistent visual proportions.

Each output is a 1024x1024 transparent PNG with the brand mark filling
~92% of the canvas (centered), so SwiftUI can render them all at the same
frame size and they will appear at the same visual weight, just like
Cal AI's onboarding "where did you hear about us" screen.
"""

from __future__ import annotations

import sys
from pathlib import Path
from PIL import Image, ImageDraw

REPO_ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = REPO_ROOT / "PashaCalo" / "Resources" / "BrandLogos.xcassets"
SOURCE_DIR = Path("/Users/jb/.cursor/projects/Users-jb-PashaCalo-PashaCalo/assets")

CANVAS = 1024
FILL_RATIO = 0.96  # how much of the canvas the brand mark should occupy


def bbox_of_content(img: Image.Image) -> tuple[int, int, int, int]:
    """Return tight bbox of the visible (non-background) content."""
    if img.mode != "RGBA":
        img = img.convert("RGBA")

    # Build an alpha mask: treat near-white and fully-transparent pixels as background.
    alpha = img.split()[-1]
    rgb = img.convert("RGB")
    pixels = rgb.load()
    w, h = img.size

    mask = Image.new("L", (w, h), 0)
    m = mask.load()
    for y in range(h):
        for x in range(w):
            a = alpha.getpixel((x, y))
            if a < 8:
                continue
            r, g, b = pixels[x, y]
            # Background if ~white (every channel >= 245)
            if r >= 245 and g >= 245 and b >= 245:
                continue
            m[x, y] = 255

    bbox = mask.getbbox()
    if bbox is None:
        return (0, 0, w, h)
    return bbox


def normalize_to_square(src: Path, dst: Path, fill_ratio: float = FILL_RATIO) -> None:
    """Tight-crop content, then center on a transparent square canvas at FILL_RATIO."""
    img = Image.open(src).convert("RGBA")
    bbox = bbox_of_content(img)
    cropped = img.crop(bbox)

    # Scale longest side to fill_ratio of the canvas.
    cw, ch = cropped.size
    target = int(CANVAS * fill_ratio)
    scale = target / max(cw, ch)
    new_w = max(1, int(round(cw * scale)))
    new_h = max(1, int(round(ch * scale)))
    cropped = cropped.resize((new_w, new_h), Image.LANCZOS)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    ox = (CANVAS - new_w) // 2
    oy = (CANVAS - new_h) // 2
    canvas.paste(cropped, (ox, oy), cropped)

    dst.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dst, "PNG", optimize=True)
    print(f"  -> {dst.relative_to(REPO_ROOT)}  ({src.name} -> {CANVAS}x{CANVAS})")


def rounded_rect_mask(size: int, radius_ratio: float = 0.225) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    r = int(size * radius_ratio)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=r, fill=255)
    return mask


def build_youtube_icon(dst: Path) -> None:
    """Build a YouTube app-icon: red rounded square with a white play triangle.

    The option cards in the onboarding view have a pure white background, so a
    white-background YouTube icon would be invisible. Using YouTube's brand red
    as the icon fill keeps the visual weight consistent with the other icons
    (X black, Facebook blue, Instagram gradient, TikTok black, App Store blue).
    """
    youtube_red = (255, 0, 0, 255)

    bg = Image.new("RGBA", (CANVAS, CANVAS), youtube_red)
    mask = rounded_rect_mask(CANVAS)
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(bg, (0, 0), mask)

    # White play triangle, optically centered (slight rightward bias is normal
    # in app icons, but we keep it visually centered for this small size).
    draw = ImageDraw.Draw(canvas)
    tri_w = int(CANVAS * 0.32)
    tri_h = int(CANVAS * 0.36)
    cx = CANVAS // 2
    cy = CANVAS // 2
    # Optical correction: shift triangle slightly right of geometric center.
    optical_offset = int(CANVAS * 0.018)
    left = cx - tri_w // 2 + optical_offset
    right = left + tri_w
    top = cy - tri_h // 2
    bottom = top + tri_h
    apex_x = right
    apex_y = cy
    draw.polygon(
        [(left, top), (left, bottom), (apex_x, apex_y)],
        fill=(255, 255, 255, 255),
    )

    dst.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dst, "PNG", optimize=True)
    print(f"  -> {dst.relative_to(REPO_ROOT)}  (YouTube red app-icon)")


def find_source(glob: str) -> Path:
    matches = sorted(SOURCE_DIR.glob(glob))
    if not matches:
        raise FileNotFoundError(f"no source file matching {glob} in {SOURCE_DIR}")
    return matches[0]


def main() -> int:
    print(f"assets dir: {ASSETS_DIR}")
    print(f"source dir: {SOURCE_DIR}")

    new_x = find_source("x-new-social-network*.png")
    new_facebook = find_source("facebook-logo-facebook-icon*.png")

    print("\nX (replace with new square app-icon source):")
    normalize_to_square(new_x, ASSETS_DIR / "XLogo.imageset" / "x.png")

    print("\nFacebook (replace with new app-icon-style square source):")
    normalize_to_square(new_facebook, ASSETS_DIR / "FacebookLogo.imageset" / "facebook.png")

    print("\nTikTok (auto-trim excess padding):")
    tk_path = ASSETS_DIR / "TikTokLogo.imageset" / "tiktok.png"
    normalize_to_square(tk_path, tk_path)

    print("\nInstagram (re-normalize for consistent fill):")
    ig_path = ASSETS_DIR / "InstagramLogo.imageset" / "instagram.png"
    normalize_to_square(ig_path, ig_path)

    print("\nApp Store (re-normalize for consistent fill):")
    app_path = ASSETS_DIR / "AppStoreLogo.imageset" / "appstore.png"
    normalize_to_square(app_path, app_path)

    print("\nYouTube (red rounded square app-icon with play triangle):")
    yt_path = ASSETS_DIR / "YouTubeLogo.imageset" / "youtube.png"
    build_youtube_icon(yt_path)

    print("\nDone.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
