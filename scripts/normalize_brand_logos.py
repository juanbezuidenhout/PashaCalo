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


WHITE_THRESHOLD = 230  # treat any pixel with all RGB >= this as background
ALPHA_THRESHOLD = 32  # treat alpha below this as background


def bbox_of_content(img: Image.Image) -> tuple[int, int, int, int]:
    """Return tight bbox of the visible non-white, non-transparent content.

    Many of the source PNGs ship with a white (or near-white) surround around
    the actual colored brand mark. A strict alpha-only bbox would include that
    surround and make the visible content render smaller than peer icons. We
    skip both transparent pixels and pixels that are near-white.
    """
    if img.mode != "RGBA":
        img = img.convert("RGBA")

    alpha = img.split()[-1]
    rgb = img.convert("RGB")
    pixels = rgb.load()
    w, h = img.size

    mask = Image.new("L", (w, h), 0)
    m = mask.load()
    for y in range(h):
        for x in range(w):
            a = alpha.getpixel((x, y))
            if a < ALPHA_THRESHOLD:
                continue
            r, g, b = pixels[x, y]
            if r >= WHITE_THRESHOLD and g >= WHITE_THRESHOLD and b >= WHITE_THRESHOLD:
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


def bbox_excluding_corner_bg(img: Image.Image, tolerance: int = 10) -> tuple[int, int, int, int]:
    """Return bbox of pixels that differ from the corner-sampled background.

    Used for sources where the background is a near-uniform light tint (not
    pure white) and the icon itself is white — the standard `bbox_of_content`
    would discard the icon because it skips white. By sampling the top-left
    corner as background and keeping any pixel that deviates from it, we
    catch both the icon's white body and any colored interior.
    """
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    bg_r, bg_g, bg_b, _ = pixels[0, 0]

    mask = Image.new("L", (w, h), 0)
    m = mask.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a < ALPHA_THRESHOLD:
                continue
            if (abs(r - bg_r) + abs(g - bg_g) + abs(b - bg_b)) <= tolerance:
                continue
            m[x, y] = 255

    bbox = mask.getbbox()
    if bbox is None:
        return (0, 0, w, h)
    return bbox


def normalize_keeping_white_bg(src: Path, dst: Path) -> None:
    """Like `normalize_to_square`, but uses corner-color detection.

    For sources whose icon container is white (e.g. Gemini) on a slightly
    off-white page background — keeps the white rounded square intact.
    """
    img = Image.open(src).convert("RGBA")
    bbox = bbox_excluding_corner_bg(img)
    cropped = img.crop(bbox)

    cw, ch = cropped.size
    target = int(CANVAS * FILL_RATIO)
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
    print(f"  -> {dst.relative_to(REPO_ROOT)}  (keep white bg, {src.name} -> {CANVAS}x{CANVAS})")


def build_chatgpt_icon(src: Path, dst: Path) -> None:
    """Build a ChatGPT app-icon: black rounded square with the white knot mark.

    The source is a black knot on a white background with no rounded-square
    container. We trim to the knot, recolor it to white using its silhouette
    as a mask, then composite it onto a black rounded square — matching the
    visual style of the official ChatGPT app icon (and the rest of our icons).
    """
    img = Image.open(src).convert("RGBA")
    bbox = bbox_of_content(img)
    knot = img.crop(bbox)

    # Build a binary silhouette from the dark pixels of the source.
    knot_rgb = knot.convert("RGB")
    kw, kh = knot.size
    silhouette = Image.new("L", (kw, kh), 0)
    sp = silhouette.load()
    kp = knot_rgb.load()
    for y in range(kh):
        for x in range(kw):
            r, g, b = kp[x, y]
            if r < 128 and g < 128 and b < 128:
                sp[x, y] = 255

    # Scale silhouette so its longest side hits ~62% of the canvas — leaves
    # a tasteful margin inside the black rounded square.
    target_w = int(CANVAS * 0.62)
    scale = target_w / max(kw, kh)
    new_w = max(1, int(round(kw * scale)))
    new_h = max(1, int(round(kh * scale)))
    silhouette = silhouette.resize((new_w, new_h), Image.LANCZOS)

    # Black rounded square at FILL_RATIO, matching peer icons.
    inner = int(CANVAS * FILL_RATIO)
    offset = (CANVAS - inner) // 2
    bg = Image.new("RGBA", (inner, inner), (0, 0, 0, 255))
    mask = rounded_rect_mask(inner)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(bg, (offset, offset), mask)

    # Paste a pure white layer using the silhouette as its alpha mask.
    white_layer = Image.new("RGBA", (new_w, new_h), (255, 255, 255, 255))
    ox = (CANVAS - new_w) // 2
    oy = (CANVAS - new_h) // 2
    canvas.paste(white_layer, (ox, oy), silhouette)

    dst.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dst, "PNG", optimize=True)
    print(f"  -> {dst.relative_to(REPO_ROOT)}  (ChatGPT black app-icon)")


def build_youtube_icon(dst: Path) -> None:
    """Build a YouTube app-icon: red rounded square with a white play triangle.

    The option cards in the onboarding view have a pure white background, so a
    white-background YouTube icon would be invisible. Using YouTube's brand red
    as the icon fill keeps the visual weight consistent with the other icons
    (X black, Facebook blue, Instagram gradient, TikTok black, App Store blue).

    Sized to match the other normalized logos: the red rounded square occupies
    FILL_RATIO of the 1024x1024 canvas, with transparent margin so the visible
    icon renders at the same size as Instagram / X / Facebook / etc.
    """
    youtube_red = (255, 0, 0, 255)

    inner = int(CANVAS * FILL_RATIO)
    offset = (CANVAS - inner) // 2

    bg_layer = Image.new("RGBA", (inner, inner), youtube_red)
    mask = rounded_rect_mask(inner)

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(bg_layer, (offset, offset), mask)

    # White play triangle: right-pointing, roughly equilateral.
    # Width ~32% of canvas, height ~30% — matches the official YouTube
    # play button proportions and avoids looking horizontally stretched.
    draw = ImageDraw.Draw(canvas)
    tri_w = int(CANVAS * 0.32)
    tri_h = int(CANVAS * 0.30)
    cx = CANVAS // 2
    cy = CANVAS // 2
    # Optical correction: shift triangle a hair right of geometric center so
    # its centroid (at 1/3 from the base) sits at the icon's true center.
    optical_offset = int(CANVAS * 0.012)
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
    new_gemini = find_source("Google-Gemini-New-Logo*.png")
    new_chatgpt = find_source("chatgpt-logo*.png")

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

    print("\nGemini (preserve white rounded square + gradient star):")
    normalize_keeping_white_bg(new_gemini, ASSETS_DIR / "GeminiLogo.imageset" / "gemini.png")

    print("\nChatGPT (black rounded square with white knot mark):")
    build_chatgpt_icon(new_chatgpt, ASSETS_DIR / "ChatGPTLogo.imageset" / "chatgpt.png")

    print("\nDone.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
