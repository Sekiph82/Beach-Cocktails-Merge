from __future__ import annotations
import json, math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[5]
ASSETS = ROOT / 'assets' / 'ui_assets' / 'campaign' / 'world_map'
OUT = Path(__file__).resolve().parent
BG = ASSETS / 'world_map_ocean_background_owner_v01.png'
ISLANDS = [
    ('sunny_cove', 'Sunny Cove', 'sunny_cove.png', (160, 455), 'CURRENT'),
    ('tiki_island', 'Tiki Island', 'tiki_island.png', (560, 525), 'LOCKED'),
    ('azure_bay', 'Azure Bay', 'azure_bay.png', (160, 615), 'LOCKED'),
    ('coconut_beach', 'Coconut Beach', 'coconut_beach.png', (560, 685), 'LOCKED'),
    ('sunset_island', 'Sunset Island', 'sunset_island.png', (160, 775), 'LOCKED'),
    ('party_beach', 'Party Beach', 'party_beach.png', (560, 845), 'LOCKED'),
    ('frozen_paradise', 'Frozen Paradise', 'frozen_paradise.png', (160, 935), 'LOCKED'),
    ('volcano_bay', 'Volcano Bay', 'volcano_bay.png', (560, 1005), 'LOCKED'),
    ('billionaire_island', 'Billionaire Island', 'billionaire_island.png', (160, 1095), 'LOCKED'),
    ('final_island', 'Final Island', 'final_island.png', (560, 1170), 'LOCKED'),
]
W, H = 720, 1280
FONT_REG = 'C:/Windows/Fonts/segoeui.ttf'
FONT_BOLD = 'C:/Windows/Fonts/segoeuib.ttf'

def font(size, bold=False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)

def center_text(draw, xy, text, ft, fill, stroke=0, stroke_fill=(0,0,0,0)):
    draw.text(xy, text, font=ft, fill=fill, anchor='mm', stroke_width=stroke, stroke_fill=stroke_fill)

def alpha_paste(dst, src, center):
    x, y = center
    dst.alpha_composite(src, (round(x-src.width/2), round(y-src.height/2)))

canvas = Image.open(BG).convert('RGBA')
if canvas.size != (W, H):
    raise SystemExit(f'Owner background dimensions are {canvas.size}, expected {(W,H)}')

# Subtle darkened route underlay follows the island sequence; the supplied
# beaded route asset supplies the visible gold-and-aqua detail.
route = Image.open(ASSETS / 'route_line.png').convert('RGBA')
for a, b in zip(ISLANDS, ISLANDS[1:]):
    p1, p2 = a[3], b[3]
    dx, dy = p2[0]-p1[0], p2[1]-p1[1]
    length = math.hypot(dx, dy)
    angle = math.degrees(math.atan2(-dy, dx))
    seg = route.resize((max(80, round(length+65)), 21), Image.Resampling.LANCZOS)
    seg = seg.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    alpha_paste(canvas, seg, ((p1[0]+p2[0])/2, (p1[1]+p2[1])/2))

# Header ornaments fit below the horizon and leave the owner's sky/sun open.
draw = ImageDraw.Draw(canvas, 'RGBA')
# restrained back affordance
shadow = Image.new('RGBA', (78,78), (0,0,0,0))
sd = ImageDraw.Draw(shadow)
sd.ellipse((7,9,71,73), fill=(3,35,52,105))
shadow = shadow.filter(ImageFilter.GaussianBlur(5))
alpha_paste(canvas, shadow, (54,89))
draw = ImageDraw.Draw(canvas, 'RGBA')
draw.ellipse((20,55,88,123), fill=(7,52,69,205), outline=(246,210,132,230), width=2)
center_text(draw, (54,87), '‹', font(48, True), (255,242,204,255))

compass = Image.open(ASSETS / 'world_map_compass.png').convert('RGBA').resize((82,82), Image.Resampling.LANCZOS)
alpha_paste(canvas, compass, (659,88))

# Existing tropical title plaque; all copy remains dynamic-looking preview text.
title = Image.open(ASSETS / 'world_map_title_panel.png').convert('RGBA').resize((500,120), Image.Resampling.LANCZOS)
alpha_paste(canvas, title, (360,309))
draw = ImageDraw.Draw(canvas, 'RGBA')
center_text(draw, (360,281), 'WORLD MAP', font(15, True), (191,245,231,255), 1, (6,42,55,210))
center_text(draw, (360,310), 'ISLAND JOURNEY', font(29, True), (255,240,193,255), 2, (49,74,60,230))
center_text(draw, (360,338), 'FOLLOW THE TROPICAL ROUTE', font(12, True), (221,249,232,255), 1, (8,57,68,225))

# Draw all route markers and islands over the route. Sunny Cove receives a
# warm halo and brighter treatment; the future islands remain fully legible.
layout = []
for idx, (island_id, name, filename, center, state) in enumerate(ISLANDS, 1):
    x, y = center
    if idx == 1:
        halo = Image.new('RGBA', (210,210), (0,0,0,0))
        hd = ImageDraw.Draw(halo)
        hd.ellipse((20,20,190,190), fill=(255,199,67,34), outline=(255,220,130,150), width=5)
        halo = halo.filter(ImageFilter.GaussianBlur(5))
        alpha_paste(canvas, halo, center)
    sprite = Image.open(ASSETS / filename).convert('RGBA')
    size = 150 if idx == 1 else 142
    sprite = sprite.resize((size,size), Image.Resampling.LANCZOS)
    if idx > 1:
        rgb = Image.new('RGB', sprite.size, (16,63,86))
        rgb.paste(sprite.convert('RGB'), mask=sprite.getchannel('A'))
        rgb = ImageEnhance.Color(rgb).enhance(0.78)
        rgb = ImageEnhance.Brightness(rgb).enhance(0.91)
        sprite.putdata([(*rgb.getpixel((i % size, i // size)), sprite.getchannel('A').getpixel((i % size, i // size))) for i in range(size*size)])
    alpha_paste(canvas, sprite, center)

    # Compact navy/gold caption tab sits on the transparent lower island edge.
    label_w, label_h = 190, 36
    lx = max(label_w//2+8, min(W-label_w//2-8, x))
    ly = y + 66
    tab = Image.new('RGBA', (label_w+12,label_h+12), (0,0,0,0))
    td = ImageDraw.Draw(tab)
    fill = (31,82,91,237) if idx == 1 else (13,52,70,228)
    edge = (255,218,124,255) if idx == 1 else (177,211,203,210)
    td.rounded_rectangle((5,5,label_w+7,label_h+7), radius=19, fill=fill, outline=edge, width=2)
    alpha_paste(canvas, tab, (lx,ly))
    draw = ImageDraw.Draw(canvas, 'RGBA')
    # number medallion
    med_x = lx - label_w/2 + 20
    draw.ellipse((med_x-11,ly-11,med_x+11,ly+11), fill=(244,193,82,255) if idx==1 else (104,167,172,255), outline=(255,246,211,220), width=1)
    center_text(draw, (med_x,ly), f'{idx:02}', font(9,True), (28,54,61,255))
    label = name.upper()
    if len(label) > 16:
        ft = font(11, True)
    elif len(label) > 12:
        ft = font(12, True)
    else:
        ft = font(13, True)
    text_x = lx + 13
    center_text(draw, (text_x,ly-4), label, ft, (255,242,211,255), 1, (7,38,48,255))
    center_text(draw, (text_x,ly+9), 'START HERE' if idx==1 else 'CURRENT' if state=='CURRENT' else 'LOCKED', font(7,True), (255,219,135,255) if idx==1 else (187,219,224,255))

    layout.append({
        'island_id': island_id,
        'source_png': f'assets/ui_assets/campaign/world_map/{filename}',
        'preview_center': {'x': x, 'y': y},
        'rendered_size': {'width': size, 'height': size},
        'label_center': {'x': round(lx), 'y': round(ly)},
        'route_anchor': {'x': x, 'y': y},
        'representative_state': state,
    })

out_png = OUT / 'WORLD_MAP_OWNER_PREVIEW_V02.png'
canvas.convert('RGB').save(out_png, format='PNG', optimize=True)
layout_doc = {
    'artifact': 'BCM-M21-001 owner-first visual preview V02',
    'canvas': {'width': W, 'height': H},
    'background_source': 'assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v01.png',
    'background_used_without_pixel_edits': True,
    'island_order': [item[0] for item in ISLANDS],
    'islands': layout,
    'preview_only_not_production_authority': True,
}
(OUT / 'WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json').write_text(json.dumps(layout_doc, indent=2) + '\n', encoding='utf-8')
print(f'PREVIEW={out_png}')
print(f'LAYOUT={OUT / "WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json"}')
print(f'DIMENSIONS={canvas.size}')
