"""Composite a raw device screenshot into a captioned, on-brand store
screenshot at an exact target canvas size (so the Play Store aspect-ratio
requirement is satisfied by the canvas, not by cropping real app content)."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BRAND = (232, 196, 104)
BRAND_DARK = (210, 168, 68)
TEXT_DARK = (58, 41, 8)
TITLE_FONT = "assets/fonts/Poppins-Bold.ttf"


def make(raw_path, out_path, caption, canvas_w, canvas_h, landscape=False):
    raw = Image.open(raw_path).convert("RGBA")

    canvas = Image.new("RGB", (canvas_w, canvas_h), BRAND)
    grad = Image.new("L", (canvas_w, canvas_h), 0)
    gdraw = ImageDraw.Draw(grad)
    for y in range(canvas_h):
        gdraw.line([(0, y), (canvas_w, y)], fill=int(255 * (y / canvas_h) * 0.3))
    overlay = Image.new("RGB", (canvas_w, canvas_h), BRAND_DARK)
    canvas = Image.composite(overlay, canvas, grad)
    draw = ImageDraw.Draw(canvas)

    # Caption area at top ~16% of canvas height. Shrink font until the text
    # fits within the canvas width (captions are short but vary in length).
    caption_h = int(canvas_h * 0.16)
    max_text_w = canvas_w * 0.88
    font_size = int(caption_h * 0.42)
    font = ImageFont.truetype(TITLE_FONT, font_size)
    bbox = draw.textbbox((0, 0), caption, font=font)
    tw = bbox[2] - bbox[0]
    while tw > max_text_w and font_size > 10:
        font_size -= 2
        font = ImageFont.truetype(TITLE_FONT, font_size)
        bbox = draw.textbbox((0, 0), caption, font=font)
        tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text(((canvas_w - tw) / 2, (caption_h - th) / 2 - bbox[1]), caption, font=font, fill=TEXT_DARK)

    # Device area below caption
    device_area_h = canvas_h - caption_h - int(canvas_h * 0.04)
    device_area_w = canvas_w - int(canvas_w * 0.10)
    scale = min(device_area_w / raw.width, device_area_h / raw.height)
    new_w, new_h = int(raw.width * scale), int(raw.height * scale)
    raw_resized = raw.resize((new_w, new_h), Image.LANCZOS)

    radius = int(min(new_w, new_h) * 0.05)
    mask = Image.new("L", (new_w, new_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, new_w, new_h], radius=radius, fill=255)

    dx = (canvas_w - new_w) // 2
    dy = caption_h + int(canvas_h * 0.02)

    shadow = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [dx + 6, dy + 10, dx + new_w + 6, dy + new_h + 10], radius=radius, fill=(0, 0, 0, 100)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")

    canvas.paste(raw_resized, (dx, dy), mask)
    canvas.save(out_path)
    print("saved", out_path, canvas.size)


if __name__ == "__main__":
    raw_path, out_path, caption, canvas_w, canvas_h = sys.argv[1:6]
    make(raw_path, out_path, caption, int(canvas_w), int(canvas_h))
