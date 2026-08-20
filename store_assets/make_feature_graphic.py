from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H = 1024, 500
BRAND = (232, 196, 104)       # #E8C468 — same as adaptive icon background
BRAND_DARK = (196, 150, 58)
TEXT_DARK = (58, 41, 8)

img = Image.new("RGB", (W, H), BRAND)
draw = ImageDraw.Draw(img)

# Soft diagonal gradient overlay for depth
grad = Image.new("L", (W, H), 0)
gdraw = ImageDraw.Draw(grad)
for x in range(W):
    gdraw.line([(x, 0), (x, H)], fill=int(255 * (x / W) * 0.35))
overlay = Image.new("RGB", (W, H), BRAND_DARK)
img = Image.composite(overlay, img, grad)
draw = ImageDraw.Draw(img)

# Icon on the left, rounded square with soft shadow
icon = Image.open("store_assets/icon_512.png").convert("RGBA")
icon_size = 300
icon = icon.resize((icon_size, icon_size), Image.LANCZOS)
icon_x, icon_y = 60, (H - icon_size) // 2
shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
sdraw = ImageDraw.Draw(shadow)
sdraw.rounded_rectangle(
    [icon_x + 8, icon_y + 14, icon_x + icon_size + 8, icon_y + icon_size + 14],
    radius=56, fill=(0, 0, 0, 90),
)
shadow = shadow.filter(ImageFilter.GaussianBlur(18))
img = Image.alpha_composite(img.convert("RGBA"), shadow).convert("RGB")
icon_mask = Image.new("L", (icon_size, icon_size), 0)
ImageDraw.Draw(icon_mask).rounded_rectangle([0, 0, icon_size, icon_size], radius=56, fill=255)
img.paste(icon, (icon_x, icon_y), icon_mask)

draw = ImageDraw.Draw(img)
title_font = ImageFont.truetype("assets/fonts/Poppins-Bold.ttf", 72)
tagline_font = ImageFont.truetype("assets/fonts/Nunito.ttf", 32)

text_x = icon_x + icon_size + 50
draw.text((text_x, 150), "Daily Habits", font=title_font, fill=TEXT_DARK)
draw.text((text_x, 240), "Build routines that stick.", font=tagline_font, fill=TEXT_DARK)

img.save("store_assets/feature_graphic_1024x500.png")
print("saved", img.size)
