from __future__ import annotations
import json, math
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[5]
ASSETS = ROOT / 'assets' / 'ui_assets' / 'campaign' / 'world_map'
OUT = Path(__file__).resolve().parent
BG = ASSETS / 'world_map_ocean_background_owner_v02.png'
ISLANDS = [
    # Centers and sizes deliberately vary to follow the owner's organic
    # reference rather than forming repeated rows or columns.
    ('sunny_cove', 'Sunny Cove', 'sunny_cove.png', (540, 300), 225, 'CURRENT'),
    ('tiki_island', 'Tiki Island', 'tiki_island.png', (175, 440), 183, 'LOCKED'),
    ('azure_bay', 'Azure Bay', 'azure_bay.png', (485, 545), 234, 'LOCKED'),
    ('coconut_beach', 'Coconut Beach', 'coconut_beach.png', (145, 645), 192, 'LOCKED'),
    ('sunset_island', 'Sunset Island', 'sunset_island.png', (410, 765), 213, 'LOCKED'),
    ('party_beach', 'Party Beach', 'party_beach.png', (610, 870), 186, 'LOCKED'),
    ('frozen_paradise', 'Frozen Paradise', 'frozen_paradise.png', (400, 1020), 228, 'LOCKED'),
    ('volcano_bay', 'Volcano Bay', 'volcano_bay.png', (180, 920), 207, 'LOCKED'),
    ('billionaire_island', 'Billionaire Island', 'billionaire_island.png', (180, 1180), 177, 'LOCKED'),
    ('final_island', 'Final Island', 'final_island.png', (615, 1178), 201, 'LOCKED'),
]
LABEL_CENTERS = {
    'sunny_cove': (540, 392),
    'tiki_island': (175, 510),
    'azure_bay': (485, 642),
    'coconut_beach': (145, 720),
    'sunset_island': (410, 850),
    'party_beach': (610, 940),
    'frozen_paradise': (400, 1112),
    'volcano_bay': (180, 1003),
    'billionaire_island': (180, 1247),
    'final_island': (615, 1257),
}
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

def set_opacity(image, factor):
    alpha = image.getchannel('A').point(lambda value: round(value * factor))
    image.putalpha(alpha)
    return image

def feather_edges(image, extent=24):
    width, height = image.size
    mask = Image.new('L', image.size)
    mask.putdata([
        round(255 * min(1.0, x / extent, (width - 1 - x) / extent,
                        y / extent, (height - 1 - y) / extent))
        for y in range(height) for x in range(width)
    ])
    image.putalpha(ImageChops.multiply(image.getchannel('A'), mask))
    return image

background_source = Image.open(BG).convert('RGB')
background_source_size = background_source.size
canvas = background_source.resize((W, H), Image.Resampling.LANCZOS).convert('RGBA')

# Add two subdued cloud banks around the outer horizon and an existing boat
# in open water. The approved sky/ocean source remains the unmodified base.
cloud_back = Image.open(ASSETS / 'world_clouds_back.png').convert('RGBA')
cloud_back = cloud_back.crop((0,8,126,154)).resize((126,146), Image.Resampling.LANCZOS)
alpha_paste(canvas, set_opacity(feather_edges(cloud_back), 0.74), (23,316))
cloud_front = Image.open(ASSETS / 'world_clouds_front.png').convert('RGBA')
cloud_front = cloud_front.crop((205,12,320,158)).resize((115,146), Image.Resampling.LANCZOS)
alpha_paste(canvas, set_opacity(feather_edges(cloud_front), 0.74), (698,316))

boat = Image.open(ASSETS / 'world_map_boat.png').convert('RGBA')
boat = boat.resize((115,65), Image.Resampling.LANCZOS)
alpha_paste(canvas, boat, (340,390))

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

# Header ornaments and title frame stay in the sky, above the ocean horizon.
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
alpha_paste(canvas, title, (360,90))
draw = ImageDraw.Draw(canvas, 'RGBA')
center_text(draw, (360,62), 'WORLD MAP', font(15, True), (191,245,231,255), 1, (6,42,55,210))
center_text(draw, (360,91), 'ISLAND JOURNEY', font(29, True), (255,240,193,255), 2, (49,74,60,230))
center_text(draw, (360,119), 'FOLLOW THE TROPICAL ROUTE', font(12, True), (221,249,232,255), 1, (8,57,68,225))

# Draw all route markers and islands over the route. Sunny Cove receives a
# warm halo and brighter treatment; the future islands remain fully legible.
layout = []
for idx, (island_id, name, filename, center, size, state) in enumerate(ISLANDS, 1):
    x, y = center
    if idx == 1:
        halo_size = size + 50
        halo = Image.new('RGBA', (halo_size,halo_size), (0,0,0,0))
        hd = ImageDraw.Draw(halo)
        inset = 12
        hd.ellipse((inset,inset,halo_size-inset,halo_size-inset), fill=(255,199,67,34), outline=(255,220,130,150), width=5)
        halo = halo.filter(ImageFilter.GaussianBlur(5))
        alpha_paste(canvas, halo, center)
    sprite = Image.open(ASSETS / filename).convert('RGBA')
    sprite = sprite.resize((size,size), Image.Resampling.LANCZOS)
    if idx > 1:
        rgb = Image.new('RGB', sprite.size, (16,63,86))
        rgb.paste(sprite.convert('RGB'), mask=sprite.getchannel('A'))
        rgb = ImageEnhance.Color(rgb).enhance(0.78)
        rgb = ImageEnhance.Brightness(rgb).enhance(0.91)
        sprite.putdata([(*rgb.getpixel((i % size, i // size)), sprite.getchannel('A').getpixel((i % size, i // size))) for i in range(size*size)])
    alpha_paste(canvas, sprite, center)

    # Caption size follows each name; placement stays just below the island.
    label_h = 38
    label_font = font(12 if len(name) < 14 else 10, True)
    label_w = min(188, max(142, round(ImageDraw.Draw(canvas).textlength(name.upper(), font=label_font) + 52)))
    lx = max(label_w//2+8, min(W-label_w//2-8, x))
    lx, ly = LABEL_CENTERS[island_id]
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
    ft = label_font
    text_x = lx + 13
    center_text(draw, (text_x,ly-4), label, ft, (255,242,211,255), 1, (7,38,48,255))
    status = 'START HERE' if idx == 1 else 'LOCKED'
    center_text(draw, (text_x,ly+10), status, font(7,True), (255,219,135,255) if idx == 1 else (187,219,224,255))

    layout.append({
        'island_id': island_id,
        'source_png': f'assets/ui_assets/campaign/world_map/{filename}',
        'preview_center': {'x': x, 'y': y},
        'rendered_size': {'width': size, 'height': size},
        'label_center': {'x': round(lx), 'y': round(ly)},
        'label_size': {'width': label_w + 2, 'height': label_h + 2},
        'route_anchor': {'x': x, 'y': y},
        'representative_state': state,
    })

out_png = OUT / 'WORLD_MAP_OWNER_PREVIEW_V02.png'
canvas.convert('RGB').save(out_png, format='PNG', optimize=True)
layout_doc = {
    'artifact': 'BCM-M21-001 owner-first visual preview V02, owner-directed composition revision',
    'canvas': {'width': W, 'height': H},
    'island_size_multiplier_from_prior_preview': 1.5,
    'background_source': 'assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png',
    'background_source_dimensions': {'width': background_source_size[0], 'height': background_source_size[1]},
    'background_rendered_dimensions': {'width': W, 'height': H},
    'background_source_file_preserved_byte_for_byte': True,
    'composition_reference': 'assets/ui_assets/campaign/world_map/world_map_background.png (layout guidance only)',
    'decorative_assets': [
        'assets/ui_assets/campaign/world_map/world_clouds_back.png',
        'assets/ui_assets/campaign/world_map/world_clouds_front.png',
        'assets/ui_assets/campaign/world_map/world_map_boat.png',
    ],
    'island_order': [item[0] for item in ISLANDS],
    'islands': layout,
    'preview_only_not_production_authority': True,
}
(OUT / 'WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json').write_text(json.dumps(layout_doc, indent=2) + '\n', encoding='utf-8')
print(f'PREVIEW={out_png}')
print(f'LAYOUT={OUT / "WORLD_MAP_OWNER_PREVIEW_LAYOUT_V02.json"}')
print(f'DIMENSIONS={canvas.size}')
