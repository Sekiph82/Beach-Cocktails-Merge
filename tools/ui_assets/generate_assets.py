from __future__ import annotations

import csv
import hashlib
import json
import math
import random
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui_assets"
W, H = 720, 1280
RNG = random.Random(26092026)

THEMES = {
    "sunny_cove": {"name": "Sunny Cove", "deep": "#12637c", "mid": "#22a8ad", "light": "#f7e9bd", "wood": "#b96b3c", "accent": "#ffcf64", "dark": "#174858"},
    "tiki_island": {"name": "Tiki Island", "deep": "#3a211d", "mid": "#7d4930", "light": "#d8ad68", "wood": "#4b281f", "accent": "#efaa42", "dark": "#241519"},
    "azure_bay": {"name": "Azure Bay", "deep": "#175d83", "mid": "#5bd3d0", "light": "#f6fbf4", "wood": "#e5e7d3", "accent": "#3b9de4", "dark": "#19435f"},
    "coconut_beach": {"name": "Coconut Beach", "deep": "#3f8f91", "mid": "#bdd7b0", "light": "#fff0c8", "wood": "#cba06b", "accent": "#edb85e", "dark": "#355e59"},
    "sunset_island": {"name": "Sunset Island", "deep": "#41274b", "mid": "#b75257", "light": "#ffd09e", "wood": "#6e302a", "accent": "#ff9d65", "dark": "#2d1d35"},
    "party_beach": {"name": "Party Beach", "deep": "#171b3f", "mid": "#4a2e83", "light": "#d8f4f1", "wood": "#202047", "accent": "#47e1d0", "dark": "#101124"},
    "frozen_paradise": {"name": "Frozen Paradise", "deep": "#315f86", "mid": "#8fd7e7", "light": "#f4ffff", "wood": "#c6eaf1", "accent": "#b7f1ff", "dark": "#244866"},
    "volcano_bay": {"name": "Volcano Bay", "deep": "#211f2b", "mid": "#54404a", "light": "#e7b887", "wood": "#29252b", "accent": "#ff6948", "dark": "#14131b"},
    "billionaire_island": {"name": "Billionaire Island", "deep": "#202c45", "mid": "#765b4c", "light": "#fbf5e5", "wood": "#3a2b2a", "accent": "#e9c66d", "dark": "#171d2d"},
    "final_island": {"name": "Final Island", "deep": "#131d35", "mid": "#147f93", "light": "#f4e7b4", "wood": "#191b26", "accent": "#e6bd55", "dark": "#0c1020"},
}

GROUPS = {
    "brand": "app_icon splash_logo logo_beach_cocktails_merge brand_badge_small brand_wordmark_small legal_logo_mark",
    "screens/splash": "splash_background loading_bar_frame loading_bar_fill loading_spinner loading_cocktail_icon loading_tip_panel",
    "ui/global": "panel_generic_large panel_generic_medium panel_generic_small popup_frame tooltip_frame divider_gold tab_active tab_inactive button_primary button_secondary button_danger button_disabled button_locked button_small button_icon_round close_x back_arrow next_arrow previous_arrow home_icon settings_icon play_icon pause_icon restart_icon map_icon info_icon help_icon check_icon lock_icon new_badge complete_badge current_badge milestone_badge finale_badge notification_dot new_content_badge reward_ready_badge sale_badge_small daily_ready_badge",
    "ui/rewards": "coin_icon gem_icon star_empty star_filled star_large_empty star_large_filled reward_frame_small reward_frame_large small_chest_closed small_chest_open big_chest_closed big_chest_open premium_chest_closed premium_chest_open reward_glow",
    "ui/boosters": "booster_time booster_hammer booster_upgrade booster_shuffle booster_count_badge booster_slot booster_locked booster_selected",
    "screens/main_menu": "main_menu_background main_menu_logo_frame main_menu_play_button main_menu_world_map_button main_menu_shop_button main_menu_settings_button main_menu_daily_button profile_frame coin_counter_panel gem_counter_panel main_menu_decor_left main_menu_decor_right",
    "campaign/world_map": "world_map_background world_map_title_panel route_line route_marker route_marker_current route_marker_complete island_name_panel island_locked_overlay world_clouds_front world_clouds_back world_map_compass world_map_boat sunny_cove tiki_island azure_bay coconut_beach sunset_island party_beach frozen_paradise volcano_bay billionaire_island final_island",
    "campaign/island_map": "level_node_locked level_node_unlocked level_node_current level_node_completed level_node_milestone level_node_finale level_connector level_connector_complete star_small_empty star_small_filled milestone_chest_marker finale_crown map_scroll_top_decor map_scroll_bottom_decor island_summary_panel stars_counter_panel next_milestone_panel",
    "screens/prelevel": "prelevel_panel level_number_badge timer_icon timer_panel_small order_slot vip_badge vip_reward_slot booster_selector_panel button_play_level button_close_prelevel",
    "ui/gameplay": "timer_panel timer_icon level_label_panel pause_button vip_badge vip_reward_frame timer_warning_glow",
    "effects": "merge_flash merge_ring sparkle_small sparkle_large score_pop_bg order_complete_flash vip_complete_flash timer_warning_glow to_go_trail_variant combo_badge combo_glow win_rays confetti_strip milestone_glow",
    "screens/pause": "pause_panel button_resume button_restart button_settings button_world_map button_quit",
    "screens/results": "level_complete_panel level_complete_title reward_slot vip_complete_badge score_summary_panel button_next_level button_replay button_island_map level_failed_panel time_up_title remaining_order_slot button_retry button_world_map_fail button_add_time video_ad_icon fail_timer_icon",
    "screens/milestones": "milestone_reward_panel milestone_banner milestone_chest_closed milestone_chest_open reward_slot button_claim milestone_glow island_complete_panel island_complete_ribbon next_island_unlock_frame button_continue",
    "ui/star_track": "star_track_panel star_track_fill star_track_marker star_track_checkpoint star_track_chest_small star_track_chest_large star_track_claimed",
    "screens/shop": "shop_background shop_header shop_tab_boosters shop_tab_currency shop_tab_special shop_item_card shop_item_card_featured coin_pack_icon_small coin_pack_icon_medium coin_pack_icon_large gem_pack_icon_small gem_pack_icon_medium gem_pack_icon_large starter_pack_badge sale_badge best_value_badge button_buy",
    "screens/rewarded_ad": "rewarded_ad_panel video_ad_icon button_watch_ad button_no_thanks reward_ad_time_icon reward_ad_double_icon",
    "screens/daily_reward": "daily_reward_background daily_reward_panel daily_day_slot daily_day_current daily_day_claimed daily_day_locked daily_chest button_claim streak_badge",
    "screens/settings": "settings_panel toggle_on toggle_off slider_track slider_handle sound_icon music_icon haptic_icon language_icon accessibility_icon privacy_icon restore_purchase_icon button_close_settings",
    "screens/tutorial": "tutorial_panel tutorial_arrow tutorial_hand tutorial_highlight_ring tutorial_timer_icon tutorial_vip_badge tutorial_merge_icon tutorial_order_icon tutorial_skip_button",
    "screens/social": "leaderboard_panel rank_badge_1 rank_badge_2 rank_badge_3 player_avatar_frame friend_icon share_icon",
}

ISLAND_FILES = "map_background map_title world_icon gameplay_background gameplay_table gameplay_table_shadow launch_zone table_edge_overlay decor_left decor_right decor_back theme_badge complete_badge".split()


def rgb(hex_color: str) -> tuple[int, int, int]:
    value = hex_color.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def font(size: int, bold: bool = False):
    candidates = [
        Path("C:/Windows/Fonts/seguisb.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()


def text_center(draw: ImageDraw.ImageDraw, box, text: str, fill, size: int, bold: bool = True):
    f = font(size, bold)
    bounds = draw.multiline_textbbox((0, 0), text, font=f, align="center")
    x = (box[0] + box[2] - (bounds[2] - bounds[0])) / 2
    y = (box[1] + box[3] - (bounds[3] - bounds[1])) / 2 - bounds[1]
    draw.multiline_text((x, y), text, font=f, fill=fill, align="center", spacing=2)


def gradient(size, top, bottom, alpha=255):
    top, bottom = rgb(top), rgb(bottom)
    image = Image.new("RGBA", size)
    px = image.load()
    for y in range(size[1]):
        t = y / max(1, size[1] - 1)
        color = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(3)) + (alpha,)
        for x in range(size[0]):
            px[x, y] = color
    return image


def rounded_panel(size, fill="#f9efd0", rim="#fff5cc", stroke="#8b542e", shadow="#13253c", radius=28, label=None, accent=None):
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    d.rounded_rectangle((10, 14, size[0] - 2, size[1] - 1), radius=radius, fill=shadow + "99")
    d.rounded_rectangle((3, 3, size[0] - 10, size[1] - 12), radius=radius, fill=stroke)
    d.rounded_rectangle((8, 8, size[0] - 15, size[1] - 17), radius=radius - 4, fill=fill)
    d.rounded_rectangle((14, 14, size[0] - 21, size[1] // 2), radius=max(8, radius - 10), fill=rim + "55")
    if accent:
        d.rounded_rectangle((18, 20, size[0] - 25, 30), radius=5, fill=accent)
    if label:
        text_center(d, (20, size[1] * 0.28, size[0] - 20, size[1] * 0.86), label, stroke, max(16, size[1] // 7))
    return image


def star_points(cx, cy, outer, inner, count=5):
    result = []
    for i in range(count * 2):
        angle = -math.pi / 2 + i * math.pi / count
        radius = outer if i % 2 == 0 else inner
        result.append((cx + math.cos(angle) * radius, cy + math.sin(angle) * radius))
    return result


def cleanup_owner_logo(source: Path) -> Image.Image:
    source_image = Image.open(source).convert("RGBA")
    pix = source_image.load()
    width, height = source_image.size
    candidates = set()
    for y in range(height):
        for x in range(width):
            r, g, b, _ = pix[x, y]
            if max(r, g, b) - min(r, g, b) <= 7 and r >= 190:
                candidates.add((x, y))
    stack = [(x, y) for x, y in candidates if x in (0, width - 1) or y in (0, height - 1)]
    background = set(stack)
    while stack:
        x, y = stack.pop()
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if (nx, ny) in candidates and (nx, ny) not in background:
                background.add((nx, ny))
                stack.append((nx, ny))
    for x, y in background:
        pix[x, y] = (pix[x, y][0], pix[x, y][1], pix[x, y][2], 0)
    return source_image


def owner_logo_variant(stem: str) -> Image.Image:
    source = cleanup_owner_logo(ROOT / "assets" / "beach cocktails merge logo.png")
    if stem == "logo_beach_cocktails_merge":
        return source
    if stem == "app_icon":
        canvas = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        source.thumbnail((214, 214), Image.Resampling.LANCZOS)
        canvas.alpha_composite(source, ((256 - source.width) // 2, (256 - source.height) // 2))
        return canvas
    if stem == "brand_wordmark_small":
        canvas = Image.new("RGBA", (360, 150), (0, 0, 0, 0))
        source.thumbnail((330, 140), Image.Resampling.LANCZOS)
        canvas.alpha_composite(source, ((360 - source.width) // 2, (150 - source.height) // 2))
        return canvas
    canvas = Image.new("RGBA", (220, 220), (0, 0, 0, 0))
    source.thumbnail((205, 205), Image.Resampling.LANCZOS)
    canvas.alpha_composite(source, ((220 - source.width) // 2, (220 - source.height) // 2))
    return canvas


def theme_for(path: str):
    for key, theme in THEMES.items():
        if key in path:
            return theme
    return THEMES["sunny_cove"]


def themed_background(theme, variant: str, size=(W, H)):
    image = gradient(size, theme["deep"], theme["mid"])
    d = ImageDraw.Draw(image, "RGBA")
    seed = sum(ord(c) for c in theme["name"] + variant)
    rng = random.Random(seed)
    # soft sun/moon and water bands establish a distinct but coherent backdrop
    horizon = int(size[1] * (0.44 if "gameplay" in variant else 0.52))
    for i in range(8):
        y = horizon + i * max(18, size[1] // 35)
        d.arc((-100, y - 24, size[0] + 100, y + 34), 0, 180, fill=theme["light"] + "55", width=3)
    d.ellipse((size[0] * 0.68, size[1] * 0.12, size[0] * 0.91, size[1] * 0.35), fill=theme["accent"] + "66")
    for side in (0, 1):
        base_x = int(size[0] * (0.05 if side == 0 else 0.95))
        for i in range(7):
            y = int(size[1] * 0.17 + i * 25 + rng.randint(-7, 7))
            end_x = base_x + (rng.randint(90, 190) * (1 if side == 0 else -1))
            d.line((base_x, size[1] * 0.62, end_x, y), fill=theme["dark"] + "aa", width=8)
            d.ellipse((end_x - 20, y - 10, end_x + 20, y + 10), fill=theme["light"] + "bb")
    for _ in range(40):
        x = rng.randrange(size[0])
        y = rng.randrange(horizon)
        radius = rng.randrange(2, 8)
        d.ellipse((x - radius, y - radius, x + radius, y + radius), fill=theme["light"] + "18")
    return image


def table_mask() -> Image.Image:
    mask = Image.new("L", (W, H), 0)
    ImageDraw.Draw(mask).polygon([(0, H), (W, H), (590, 398), (130, 398)], fill=255)
    return mask


def table_image(theme, island_id: str) -> Image.Image:
    mask = table_mask()
    image = gradient((W, H), theme["light"], theme["wood"])
    px = image.load()
    rng = random.Random(sum(ord(c) for c in island_id))
    for _ in range(2600):
        x = rng.randrange(W)
        y = rng.randrange(398, H)
        if mask.getpixel((x, y)):
            grain = rng.choice([-1, 0, 0, 0, 1])
            r, g, b, _ = px[x, y]
            px[x, y] = (max(0, min(255, r + grain * 9)), max(0, min(255, g + grain * 9)), max(0, min(255, b + grain * 9)), 255)
    d = ImageDraw.Draw(image, "RGBA")
    # fixed perspective edge and trim: same coordinates for every island
    d.line([(130, 398), (590, 398)], fill=theme["accent"] + "ff", width=18)
    d.line([(130, 398), (0, H)], fill=theme["dark"] + "dd", width=16)
    d.line([(590, 398), (W, H)], fill=theme["dark"] + "dd", width=16)
    for x in range(60, 680, 88):
        y = 430 + int((x - 130) * 0.95 if x > 130 else (130 - x) * 0.4)
        d.line((x, y, x + 30, min(H, y + 700)), fill=theme["light"] + "28", width=6)
    if island_id in {"party_beach", "final_island"}:
        for x in range(160, 590, 90):
            d.line((x, 420, x + 44, 1120), fill=theme["accent"] + "44", width=5)
    if island_id == "volcano_bay":
        for x in (220, 345, 475):
            d.line((x, 500, x + 30, 1120), fill="#ff6b4d88", width=5)
    image.putalpha(mask)
    return image


def table_shadow(theme) -> Image.Image:
    mask = table_mask().filter(ImageFilter.GaussianBlur(28))
    shadow = Image.new("RGBA", (W, H), (5, 12, 24, 0))
    shadow.putalpha(mask.point(lambda p: int(p * 0.34)))
    return shadow


def edge_overlay(theme) -> Image.Image:
    image = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    d.line([(130, 398), (590, 398), (720, 1280)], fill=theme["accent"] + "cc", width=5)
    d.line([(130, 398), (0, 1280)], fill=theme["accent"] + "cc", width=5)
    return image


def launch_zone(theme) -> Image.Image:
    image = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    d.rounded_rectangle((250, 1040, 470, 1210), radius=38, fill=theme["accent"] + "22", outline=theme["light"] + "b0", width=4)
    d.arc((285, 1060, 435, 1210), 195, 345, fill=theme["accent"] + "bb", width=6)
    return image


def island_icon(theme, island_id: str) -> Image.Image:
    image = Image.new("RGBA", (220, 220), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    d.ellipse((8, 10, 210, 212), fill=theme["dark"] + "dd", outline=theme["light"] + "ff", width=7)
    d.ellipse((26, 28, 192, 194), fill=theme["mid"] + "ff")
    d.polygon([(38, 140), (86, 72), (126, 116), (162, 62), (190, 156), (170, 183), (54, 177)], fill=theme["wood"] + "ff")
    d.ellipse((112, 52, 170, 110), fill=theme["accent"] + "dd")
    text_center(d, (32, 142, 188, 190), theme["name"].split()[0].upper(), theme["light"], 18)
    return image


def decor(theme, side: str, island_id: str) -> Image.Image:
    image = Image.new("RGBA", (300, 380), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    direction = -1 if side == "left" else 1
    x = 80 if side == "left" else 220
    d.line((x, 365, x + direction * 15, 65), fill=theme["wood"] + "ff", width=22)
    for i in range(6):
        y = 85 + i * 42
        d.ellipse((x - 64 + direction * i * 6, y - 16, x + direction * 10, y + 22), fill=theme["mid"] + "dd")
    d.ellipse((x - 32, 20, x + 35, 86), fill=theme["accent"] + "bb")
    return image


def reusable_base(theme, stem: str, size, group: str) -> Image.Image:
    lower = stem.lower()
    transparent = any(token in lower for token in ("icon", "arrow", "badge", "glow", "flash", "sparkle", "trail", "decor", "overlay", "spinner", "fill", "ring", "rays", "confetti", "hand", "highlight"))
    image = Image.new("RGBA", size, (0, 0, 0, 0) if transparent else (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    w, h = size
    accent = rgb(theme["accent"])
    dark = rgb(theme["dark"])
    light = rgb(theme["light"])
    if "background" in lower:
        return themed_background(theme, lower, size)
    if any(token in lower for token in ("star", "milestone", "finale")):
        outer = min(w, h) * 0.38
        d.polygon(star_points(w / 2, h / 2, outer, outer * 0.42), fill=accent + (255,), outline=light + (255,))
        d.polygon(star_points(w / 2, h / 2, outer * 0.62, outer * 0.27), fill=light + (130,))
        return image
    if "coin" in lower:
        d.ellipse((8, 8, w - 8, h - 8), fill=accent + (255,), outline=light + (255,), width=max(2, w // 18))
        d.ellipse((w * .25, h * .18, w * .75, h * .82), outline=dark + (150,), width=max(2, w // 24))
        return image
    if "gem" in lower:
        d.polygon([(w/2, 4), (w-7, h*.38), (w*.72, h-7), (w*.28, h-7), (7, h*.38)], fill=(75, 205, 220, 255), outline=light + (255,))
        d.line((w/2, 4, w*.45, h-7, 7, h*.38), fill=light + (160,), width=3)
        return image
    if "chest" in lower:
        d.rounded_rectangle((w*.12, h*.35, w*.88, h*.9), radius=max(6, w//18), fill=theme["wood"] + "ff", outline=accent + (255,), width=max(3, w//24))
        d.arc((w*.12, h*.12, w*.88, h*.64), 180, 360, fill=accent + (255,), width=max(4, w//20))
        d.rectangle((w*.45, h*.5, w*.55, h*.72), fill=accent + (255,))
        return image
    if "arrow" in lower or lower in {"back_arrow", "next_arrow", "previous_arrow"}:
        direction = -1 if "back" in lower or "previous" in lower else 1
        pts = [(w*.72 if direction > 0 else w*.28, h*.18), (w*.86 if direction > 0 else w*.14, h*.5), (w*.72 if direction > 0 else w*.28, h*.82)]
        d.line(pts, fill=accent + (255,), width=max(8, w//8), joint="curve")
        d.line((w*.2 if direction > 0 else w*.8, h*.5, w*.78 if direction > 0 else w*.22, h*.5), fill=light + (255,), width=max(7, w//10))
        return image
    if "close_x" in lower or lower.endswith("_x"):
        d.line((w*.25, h*.25, w*.75, h*.75), fill=accent + (255,), width=max(7, w//10))
        d.line((w*.75, h*.25, w*.25, h*.75), fill=light + (255,), width=max(7, w//10))
        return image
    if any(token in lower for token in ("toggle", "slider", "badge", "dot", "status", "notification")):
        d.rounded_rectangle((4, h*.18, w-4, h*.82), radius=int(h*.3), fill=dark + (235,), outline=light + (180,), width=max(2, int(h*.05)))
        d.ellipse((w*.58, h*.28, w*.84, h*.72), fill=accent + (255,))
        return image
    if any(token in lower for token in ("flash", "glow", "ring", "rays", "sparkle")):
        d.ellipse((w*.12, h*.12, w*.88, h*.88), outline=accent + (190,), width=max(4, w//18))
        for i in range(8):
            angle = i * math.pi / 4
            d.line((w/2, h/2, w/2 + math.cos(angle)*w*.48, h/2 + math.sin(angle)*h*.48), fill=light + (105,), width=max(2, w//34))
        return image
    if any(token in lower for token in ("icon", "rank", "avatar", "profile", "lock", "play", "pause", "restart", "home", "settings", "map", "info", "help", "check", "sound", "music", "haptic", "language", "privacy", "accessibility", "share", "friend", "video")):
        d.ellipse((6, 6, w-6, h-6), fill=dark + (230,), outline=accent + (255,), width=max(3, w//18))
        if "play" in lower or "video" in lower:
            d.polygon([(w*.4, h*.27), (w*.72, h*.5), (w*.4, h*.73)], fill=light + (255,))
        elif "pause" in lower:
            d.rounded_rectangle((w*.3, h*.28, w*.42, h*.72), radius=4, fill=light + (255,)); d.rounded_rectangle((w*.58, h*.28, w*.7, h*.72), radius=4, fill=light + (255,))
        elif "check" in lower:
            d.line((w*.22, h*.52, w*.44, h*.72, w*.78, h*.28), fill=light + (255,), width=max(5, w//11), joint="curve")
        elif "lock" in lower:
            d.rounded_rectangle((w*.28, h*.46, w*.72, h*.78), radius=6, fill=accent + (255,)); d.arc((w*.34, h*.2, w*.66, h*.58), 180, 360, fill=light + (255,), width=max(4, w//16))
        elif "arrow" not in lower:
            d.ellipse((w*.36, h*.25, w*.64, h*.53), fill=light + (210,)); d.arc((w*.25, h*.42, w*.75, h*.88), 180, 360, fill=light + (210,), width=max(3, w//20))
        return image
    if "button" in lower or "panel" in lower or "frame" in lower or "slot" in lower or "counter" in lower or "card" in lower or "track" in lower or "header" in lower or "tab" in lower or "title" in lower or "tooltip" in lower or "divider" in lower:
        label = BUTTON_LABELS.get(stem)
        fill = theme["light"] if "danger" not in lower else "#f08b70"
        if "disabled" in lower or "locked" in lower:
            fill = "#8093a0"
        return rounded_panel(size, fill=fill, rim="#ffffff", stroke=theme["dark"], shadow="#071526", radius=max(10, min(w, h)//6), label=label if "button" in lower else None, accent=theme["accent"])
    raise ValueError(f"No explicit renderer for final asset: {group}/{stem}")


def dimensions_for(stem: str, group: str):
    lower = stem.lower()
    if "background" in lower:
        return (W, H)
    if "gameplay_table" in lower or "table_shadow" in lower or "launch_zone" in lower or "table_edge_overlay" in lower:
        return (W, H)
    if "decor_" in lower:
        return (300, 380)
    if lower == "world_icon" or group.endswith("world_map") and lower in THEMES:
        return (220, 220)
    if "spinner" in lower or "icon" in lower or "arrow" in lower or "badge" in lower or "star" in lower or "chest" in lower or "toggle" in lower or "handle" in lower or "dot" in lower:
        return (128, 128)
    if "fill" in lower or "track" in lower:
        return (420, 54)
    if "divider" in lower or "connector" in lower or lower == "route_line":
        return (520, 36)
    if "button" in lower:
        return (360, 104)
    if "title" in lower or "header" in lower:
        return (500, 120)
    if "panel" in lower or "frame" in lower or "card" in lower or "slot" in lower or "counter" in lower:
        return (440, 190)
    if "world_map" in group or group.startswith("campaign/"):
        return (320, 180)
    return (220, 160)


def make_geometry():
    return {
        "geometry_version": 1,
        "viewport_width": W,
        "viewport_height": H,
        "normalized": {
            "front_left": [0.0, 1.0], "front_right": [1.0, 1.0],
            "rear_left": [0.18, 0.311], "rear_right": [0.82, 0.311],
            "rear_center_x": 0.5, "rear_width": 0.64,
        },
        "raster_edge_coordinates": {
            "front_left": [0, H], "front_right": [W, H],
            "rear_left": [130, 398], "rear_right": [590, 398],
            "rear_width_px": 460, "rear_width_target_px": 460.8,
        },
        "canonical_rear_y": 398,
        "canonical_launch_y": 947,
        "canonical_danger_y": 900,
        "canonical_playable_boundary_points": [[130, 398], [590, 398], [720, 1280], [0, 1280]],
        "perspective_centerline_x": 360,
        "launch_alignment_x": 360,
        "table_depth_px": 882,
        "source_reference": {
            "runtime_file": "scripts/game_manager.gd",
            "observed_rear_source_y": 478.0,
            "observed_danger_source_y": 1080.0,
            "observed_launch_source_y": 1136.0,
            "note": "Frozen art-only geometry for UIA-M14; live runtime boundary remains untouched in V01.",
        },
    }


def save(image: Image.Image, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, "PNG", optimize=True)


def build_asset_catalog():
    catalog = []
    for group, names in GROUPS.items():
        for stem in names.split():
            catalog.append((f"{group}/{stem}.png", group, stem, None))
    for island_id in THEMES:
        for stem in ISLAND_FILES:
            catalog.append((f"campaign/islands/{island_id}/{stem}.png", "campaign/islands", stem, island_id))
    return catalog


def render(rel: str, group: str, stem: str, island_id: str | None):
    theme = THEMES.get(island_id or "sunny_cove", THEMES["sunny_cove"])
    size = dimensions_for(stem, group)
    if stem in {"app_icon", "splash_logo", "logo_beach_cocktails_merge", "brand_wordmark_small", "legal_logo_mark"}:
        return owner_logo_variant(stem)
    if island_id and stem == "gameplay_table":
        return table_image(theme, island_id)
    if island_id and stem == "gameplay_table_shadow":
        return table_shadow(theme)
    if island_id and stem == "table_edge_overlay":
        return edge_overlay(theme)
    if island_id and stem == "launch_zone":
        return launch_zone(theme)
    if island_id and stem == "world_icon":
        return island_icon(theme, island_id)
    if island_id and stem.startswith("decor_"):
        return decor(theme, stem.split("_")[-1], island_id)
    if stem in THEMES:
        return island_icon(theme, stem)
    if island_id and stem in {"map_background", "gameplay_background"}:
        return themed_background(theme, stem)
    if "background" in stem:
        return themed_background(theme, stem)
    return reusable_base(theme, stem, size, group)


def write_readme():
    text = """# UI Assets V1 production library

This branch-only library is generated for the `ui-assets` visual-production stream. It does not replace or modify runtime assets.

## Structure

- `brand/`, `ui/`: reusable brand and interface elements.
- `campaign/`: world-map, reusable progression UI, and ten island packs.
- `screens/`: splash, menu, pre-level, results, shop, settings, tutorial, and social screens.
- `effects/`: restrained feedback overlays.
- `tables/`: frozen common geometry JSON, silhouette mask, and edge overlay masters.
- `source/`: generator provenance and style-reference notes only, including the generated remediation direction board.

## Generation and export

`tools/ui_assets/generate_assets.py` creates original raster art with Pillow using explicit semantic pictogram, island landmark, material-skin, screen-composition, and effect renderers. The owner-supplied logo is copied from the local source after checkerboard-background removal only; no logo artwork is regenerated. The table skins are rasterized from one shared 720x1280 alpha polygon defined by `tables/table_geometry_v1.json`; only the clipped material treatment changes per island.

`tools/ui_assets/validate_assets.py` checks manifest coverage, PNG decoding, dimensions, alpha expectations, table canvas/mask equality, preserved logo/mask/geometry blobs, front-corner/rear-width geometry, untouched protected paths, and remediation scope restrictions.

The global, island, table, screen, semantic-icon, and major-screen contact sheets are audit evidence, not runtime integration. `source/style_reference_board*.png` are visual direction references only. Runtime table/play-area and logo replacement remain deferred to UIA-M14.
"""
    (OUT / "README.md").write_text(text, encoding="utf-8")


def make_contact_sheet(name: str, items: list[tuple[str, Image.Image]], columns: int, tile=(220, 240)):
    pad = 18
    rows = math.ceil(len(items) / columns)
    sheet = Image.new("RGB", (columns * (tile[0] + pad) + pad, rows * (tile[1] + 48 + pad) + pad), "#0d2036")
    d = ImageDraw.Draw(sheet)
    text_center(d, (pad, 4, sheet.width - pad, 42), name, "#fff1c6", 24)
    for i, (label, item) in enumerate(items):
        col, row = i % columns, i // columns
        x = pad + col * (tile[0] + pad)
        y = 52 + pad + row * (tile[1] + 48 + pad)
        thumb = item.convert("RGBA")
        thumb.thumbnail(tile, Image.Resampling.LANCZOS)
        cell = Image.new("RGBA", tile, "#1a3850")
        cell.alpha_composite(thumb, ((tile[0] - thumb.width) // 2, (tile[1] - thumb.height) // 2))
        sheet.paste(cell.convert("RGB"), (x, y))
        d.text((x + tile[0] // 2, y + tile[1] + 6), label, fill="#f7e9bd", font=font(14, True), anchor="ma")
    save(sheet.convert("RGBA"), OUT / name)


STATEFUL_GROUPS = [
    {"name": "stars", "paths": [
        "campaign/island_map/star_small_empty.png", "campaign/island_map/star_small_filled.png",
        "ui/rewards/star_empty.png", "ui/rewards/star_filled.png",
        "ui/rewards/star_large_empty.png", "ui/rewards/star_large_filled.png",
    ], "min_distance": 0.02, "expected": "empty is hollow/desaturated; filled is bright/earned"},
    {"name": "chests", "paths": [
        "ui/rewards/small_chest_closed.png", "ui/rewards/small_chest_open.png",
        "ui/rewards/big_chest_closed.png", "ui/rewards/big_chest_open.png",
        "ui/rewards/premium_chest_closed.png", "ui/rewards/premium_chest_open.png",
        "screens/milestones/milestone_chest_closed.png", "screens/milestones/milestone_chest_open.png",
    ], "min_distance": 0.02, "expected": "closed lid versus open lid/interior reward glow"},
    {"name": "toggle", "paths": ["screens/settings/toggle_off.png", "screens/settings/toggle_on.png"], "min_distance": 0.02, "expected": "muted left OFF knob versus illuminated right ON knob"},
    {"name": "level_nodes", "paths": [
        "campaign/island_map/level_node_locked.png", "campaign/island_map/level_node_unlocked.png",
        "campaign/island_map/level_node_current.png", "campaign/island_map/level_node_completed.png",
    ], "min_distance": 0.02, "expected": "lock/inaccessible versus selectable/progress states"},
    {"name": "tabs", "paths": ["ui/global/tab_inactive.png", "ui/global/tab_active.png"], "min_distance": 0.02, "expected": "receded inactive versus raised/highlighted active"},
    {"name": "daily_reward_states", "paths": [
        "screens/daily_reward/daily_day_locked.png", "screens/daily_reward/daily_day_current.png", "screens/daily_reward/daily_day_claimed.png",
    ], "min_distance": 0.015, "expected": "locked, current, and claimed calendar states"},
    {"name": "booster_states", "paths": [
        "ui/boosters/booster_locked.png", "ui/boosters/booster_selected.png", "ui/boosters/booster_time.png",
    ], "min_distance": 0.015, "expected": "locked, selected, and usable/default booster states"},
    {"name": "route_markers", "paths": [
        "campaign/world_map/route_marker.png", "campaign/world_map/route_marker_current.png", "campaign/world_map/route_marker_complete.png",
    ], "min_distance": 0.015, "expected": "normal, current, and complete route progress states"},
]


def image_signature(path: Path):
    image = Image.open(path).convert("RGBA").resize((24, 24), Image.Resampling.BILINEAR)
    return [channel for pixel in image.getdata() for channel in pixel]


def perceptual_distance(left, right):
    return sum(abs(a - b) for a, b in zip(left, right)) / (len(left) * 255)


def write_stateful_report():
    report = {"report_version": 1, "groups": []}
    for group in STATEFUL_GROUPS:
        signatures = {rel: image_signature(OUT / rel) for rel in group["paths"]}
        distances = []
        for index, left in enumerate(group["paths"]):
            for right in group["paths"][index + 1:]:
                distances.append({"left": left, "right": right, "distance": perceptual_distance(signatures[left], signatures[right])})
        distances.sort(key=lambda item: item["distance"])
        report["groups"].append({
            "name": group["name"],
            "expected_relationship": group["expected"],
            "minimum_required_distance": group["min_distance"],
            "assets": [{"path": rel, "sha256": hashlib.sha256((OUT / rel).read_bytes()).hexdigest()} for rel in group["paths"]],
            "pair_distances": distances,
            "status": "PASS" if distances and distances[0]["distance"] >= group["min_distance"] else "FAIL",
        })
    (OUT / "STATEFUL_PAIR_REPORT.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def generate():
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "source").mkdir(parents=True, exist_ok=True)
    (OUT / "tables").mkdir(parents=True, exist_ok=True)
    geometry = make_geometry()
    save(Image.new("RGBA", (720, 1280), (255, 255, 255, 0)), OUT / "tables" / "table_silhouette_mask.png")
    mask = table_mask()
    save(mask.convert("RGBA"), OUT / "tables" / "table_silhouette_mask.png")
    save(edge_overlay(THEMES["sunny_cove"]), OUT / "tables" / "table_edge_overlay_master.png")
    (OUT / "tables" / "table_geometry_v1.json").write_text(json.dumps(geometry, indent=2) + "\n", encoding="utf-8")
    (OUT / "source" / "generation_method.txt").write_text("Deterministic Pillow generation with explicit semantic pictograms, island landmarks, major-screen compositions, differentiated effects, and clipped island material skins. Canonical logo is owner-supplied with technical checkerboard alpha cleanup only. style_reference_board*.png are imagegen visual-direction references and are not runtime assets.\n", encoding="utf-8")

    catalog = build_asset_catalog()
    for rel, group, stem, island_id in catalog:
        save(render(rel, group, stem, island_id), OUT / rel)
    write_readme()

    table_items = []
    island_items = []
    for island_id, theme in THEMES.items():
        table_items.append((theme["name"], Image.open(OUT / "campaign" / "islands" / island_id / "gameplay_table.png")))
        island_items.append((theme["name"], Image.open(OUT / "campaign" / "islands" / island_id / "world_icon.png")))
    proof = Image.new("RGBA", (W, H), "#10283d")
    proof_draw = ImageDraw.Draw(proof)
    proof_draw.polygon([(0, H), (W, H), (590, 398), (130, 398)], outline="#f7e9bd", width=12)
    proof_draw.ellipse((116, 384, 144, 412), fill="#ffcf64")
    proof_draw.ellipse((576, 384, 604, 412), fill="#ffcf64")
    proof_draw.text((W // 2, 700), "10 TABLES\nONE MASK", fill="#f7e9bd", font=font(34, True), anchor="mm", align="center")
    table_items.append(("Shared mask proof", proof))
    make_contact_sheet("CONTACT_SHEET_TABLES.png", table_items, 5, (220, 360))
    make_contact_sheet("CONTACT_SHEET_ISLANDS.png", island_items, 5, (220, 240))
    global_items = []
    for rel in ["brand/logo_beach_cocktails_merge.png", "ui/global/button_primary.png", "ui/global/panel_generic_large.png", "ui/rewards/coin_icon.png", "ui/rewards/big_chest_open.png", "ui/boosters/booster_hammer.png", "ui/global/current_badge.png", "effects/merge_flash.png"]:
        global_items.append((Path(rel).stem.replace("_", " ").title(), Image.open(OUT / rel)))
    make_contact_sheet("CONTACT_SHEET_GLOBAL.png", global_items, 4, (220, 220))
    screen_items = []
    for rel in ["screens/splash/splash_background.png", "screens/main_menu/main_menu_background.png", "campaign/world_map/world_map_background.png", "screens/prelevel/prelevel_panel.png", "screens/pause/pause_panel.png", "screens/results/level_complete_panel.png", "screens/shop/shop_background.png", "screens/daily_reward/daily_reward_background.png", "screens/settings/settings_panel.png", "screens/tutorial/tutorial_panel.png", "screens/social/leaderboard_panel.png"]:
        screen_items.append((Path(rel).stem.replace("_", " ").title(), Image.open(OUT / rel)))
    make_contact_sheet("CONTACT_SHEET_SCREENS.png", screen_items, 4, (220, 270))
    semantic_items = []
    semantic_paths = [
        "ui/global/home_icon.png", "ui/global/settings_icon.png", "ui/global/map_icon.png", "ui/global/info_icon.png",
        "ui/global/help_icon.png", "screens/settings/sound_icon.png", "screens/settings/music_icon.png",
        "screens/settings/haptic_icon.png", "screens/settings/language_icon.png", "screens/settings/privacy_icon.png",
        "screens/settings/accessibility_icon.png", "screens/social/share_icon.png", "screens/social/friend_icon.png",
        "screens/results/video_ad_icon.png", "ui/global/play_icon.png", "ui/global/pause_icon.png",
        "ui/global/restart_icon.png", "ui/global/lock_icon.png", "ui/global/check_icon.png", "ui/global/close_x.png",
        "ui/global/back_arrow.png", "ui/global/next_arrow.png", "ui/global/previous_arrow.png",
        "ui/boosters/booster_time.png", "ui/boosters/booster_hammer.png", "ui/boosters/booster_upgrade.png", "ui/boosters/booster_shuffle.png",
    ]
    for rel in semantic_paths:
        semantic_items.append((Path(rel).stem.replace("_", " ").title(), Image.open(OUT / rel)))
    make_contact_sheet("CONTACT_SHEET_SEMANTIC_ICONS.png", semantic_items, 6, (150, 150))
    major_screen_items = []
    for rel in [
        "screens/splash/splash_background.png", "screens/main_menu/main_menu_background.png",
        "campaign/world_map/world_map_background.png", "screens/shop/shop_background.png",
        "screens/daily_reward/daily_reward_background.png", "campaign/islands/sunny_cove/map_background.png",
        "campaign/islands/sunny_cove/gameplay_background.png",
    ]:
        major_screen_items.append((Path(rel).stem.replace("_", " ").title(), Image.open(OUT / rel)))
    make_contact_sheet("CONTACT_SHEET_MAJOR_SCREENS.png", major_screen_items, 4, (220, 270))

    stateful_items = []
    for group in STATEFUL_GROUPS:
        for rel in group["paths"]:
            stateful_items.append((Path(rel).stem.replace("_", " ").title(), Image.open(OUT / rel)))
    make_contact_sheet("CONTACT_SHEET_STATEFUL_UI.png", stateful_items, 4, (190, 170))
    write_stateful_report()

    manifest = []
    pngs = sorted(OUT.rglob("*.png"))
    for path in pngs:
        rel = path.relative_to(ROOT).as_posix()
        image = Image.open(path)
        island = next((key for key in THEMES if f"/islands/{key}/" in f"/{rel}"), None)
        is_table = path.name in {"gameplay_table.png", "gameplay_table_shadow.png", "table_edge_overlay.png"} or "table_" in path.name
        source_reference = path.parent.relative_to(OUT).as_posix() == "source"
        manifest.append({
            "path": rel,
            "category": "evidence" if path.name.startswith("CONTACT_SHEET") else ("source_reference" if source_reference else path.parent.relative_to(OUT).as_posix()),
            "intended_screen_use": "audit contact sheet" if path.name.startswith("CONTACT_SHEET") else ("visual direction reference" if source_reference else path.stem.replace("_", " ")),
            "dimensions": {"width": image.width, "height": image.height},
            "alpha_expected": image.mode in {"RGBA", "LA"},
            "island_id": island,
            "table_geometry_version": 1 if is_table else None,
            "generation_source_method": "owner-supplied canonical logo with technical alpha cleanup and proportional size variant only" if path.name in {"app_icon.png", "splash_logo.png", "logo_beach_cocktails_merge.png", "brand_wordmark_small.png", "legal_logo_mark.png"} else ("imagegen visual direction reference; not a runtime asset" if path.name.startswith("style_reference_board") else "deterministic original Pillow procedural generation"),
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        })
    (OUT / "ASSET_MANIFEST.json").write_text(json.dumps({"manifest_version": 1, "base_viewport": [W, H], "assets": manifest}, indent=2) + "\n", encoding="utf-8")
    with (OUT / "ASSET_DIMENSIONS.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["path", "width", "height", "mode", "alpha_expected"])
        for item in manifest:
            path = ROOT / item["path"]
            image = Image.open(path)
            writer.writerow([item["path"], image.width, image.height, image.mode, item["alpha_expected"]])
    print(f"generated {len(catalog)} manifest assets plus {len(pngs) - len(catalog)} evidence/master PNGs")


SEMANTIC_STEMS = {
    "home_icon", "settings_icon", "map_icon", "info_icon", "help_icon", "sound_icon", "music_icon",
    "haptic_icon", "language_icon", "privacy_icon", "accessibility_icon", "share_icon", "friend_icon",
    "video_ad_icon", "play_icon", "pause_icon", "restart_icon", "lock_icon", "check_icon", "close_x",
    "back_arrow", "next_arrow", "previous_arrow", "timer_icon", "fail_timer_icon", "restore_purchase_icon",
    "booster_time", "booster_hammer", "booster_upgrade", "booster_shuffle", "loading_cocktail_icon",
    "tutorial_merge_icon", "tutorial_order_icon", "tutorial_timer_icon", "tutorial_vip_badge",
    "reward_ad_time_icon", "reward_ad_double_icon",
}

BUTTON_LABELS = {
    "button_primary": "PLAY", "button_secondary": "BACK", "button_danger": "QUIT", "button_small": "OK",
    "button_resume": "RESUME", "button_restart": "RESTART", "button_settings": "SETTINGS", "button_world_map": "MAP",
    "button_quit": "QUIT", "button_next_level": "NEXT", "button_replay": "REPLAY", "button_island_map": "ISLAND MAP",
    "button_retry": "RETRY", "button_world_map_fail": "MAP", "button_add_time": "+ TIME", "button_claim": "CLAIM",
    "button_continue": "CONTINUE", "button_buy": "BUY", "button_watch_ad": "WATCH", "button_no_thanks": "NO THANKS",
    "button_play_level": "PLAY", "button_close_prelevel": "CLOSE", "button_close_settings": "CLOSE", "tutorial_skip_button": "SKIP",
}

EFFECT_STEMS = {
    "merge_flash", "merge_ring", "sparkle_small", "sparkle_large", "score_pop_bg", "order_complete_flash",
    "vip_complete_flash", "timer_warning_glow", "to_go_trail_variant", "combo_badge", "combo_glow",
    "win_rays", "confetti_strip", "milestone_glow", "tutorial_highlight_ring",
}

# These are intentionally reusable skin primitives, not semantic stand-ins.
# Every other catalog stem must resolve through a dedicated renderer below.
REUSABLE_BASE_STEMS = set("""
brand_badge_small
loading_bar_frame loading_tip_panel
panel_generic_large panel_generic_medium panel_generic_small popup_frame tooltip_frame divider_gold
tab_active tab_inactive button_primary button_secondary button_danger button_disabled button_locked button_small button_icon_round
new_badge complete_badge current_badge milestone_badge finale_badge notification_dot new_content_badge reward_ready_badge sale_badge_small daily_ready_badge
coin_counter_panel gem_counter_panel main_menu_logo_frame main_menu_play_button main_menu_world_map_button main_menu_shop_button main_menu_settings_button main_menu_daily_button profile_frame
world_map_title_panel island_name_panel island_locked_overlay
star_small_empty star_small_filled milestone_chest_marker finale_crown map_scroll_top_decor map_scroll_bottom_decor island_summary_panel stars_counter_panel next_milestone_panel
map_title theme_badge complete_badge
prelevel_panel level_number_badge timer_panel_small order_slot vip_badge vip_reward_slot booster_selector_panel
timer_panel level_label_panel pause_button vip_badge vip_reward_frame
pause_panel button_resume button_restart button_settings button_world_map button_quit
level_complete_panel level_complete_title reward_slot vip_complete_badge score_summary_panel button_next_level button_replay button_island_map
level_failed_panel time_up_title remaining_order_slot button_retry button_world_map_fail button_add_time video_ad_icon fail_timer_icon
milestone_reward_panel milestone_banner milestone_chest_closed milestone_chest_open reward_slot button_claim island_complete_panel next_island_unlock_frame button_continue
star_track_panel star_track_fill star_track_marker star_track_checkpoint star_track_chest_small star_track_chest_large star_track_claimed
shop_header shop_tab_boosters shop_tab_currency shop_tab_special shop_item_card shop_item_card_featured starter_pack_badge sale_badge best_value_badge button_buy
rewarded_ad_panel button_watch_ad button_no_thanks
daily_reward_panel daily_day_slot daily_day_locked streak_badge
settings_panel toggle_on toggle_off slider_track slider_handle button_close_settings
tutorial_panel tutorial_arrow tutorial_skip_button
leaderboard_panel rank_badge_1 rank_badge_2 rank_badge_3 player_avatar_frame
booster_count_badge booster_slot booster_locked
button_close_prelevel button_play_level
coin_icon gem_icon star_empty star_filled star_large_empty star_large_filled reward_frame_small reward_frame_large small_chest_closed small_chest_open big_chest_closed big_chest_open premium_chest_closed premium_chest_open reward_glow
""".split())

REWARD_STEMS = {
    "coin_icon", "gem_icon", "star_empty", "star_filled", "star_large_empty", "star_large_filled",
    "star_small_empty", "star_small_filled", "small_chest_closed", "small_chest_open", "big_chest_closed",
    "big_chest_open", "premium_chest_closed", "premium_chest_open", "daily_chest",
    "milestone_chest_closed", "milestone_chest_open",
    "coin_pack_icon_small", "coin_pack_icon_medium", "coin_pack_icon_large",
    "gem_pack_icon_small", "gem_pack_icon_medium", "gem_pack_icon_large",
}


def _rgba(value: str, alpha: int = 255):
    r, g, b = rgb(value)
    return (r, g, b, alpha)


def add_soft_texture(image: Image.Image, seed: int, opacity: int = 24, count: int = 900):
    """Add restrained painterly grain without changing an existing alpha mask."""
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer, "RGBA")
    rng = random.Random(seed)
    w, h = image.size
    for _ in range(count):
        x, y = rng.randrange(max(1, w)), rng.randrange(max(1, h))
        radius = rng.choice((1, 1, 2, 3, 5))
        color = (255, 242, 198, rng.randrange(max(4, opacity // 2), opacity + 1)) if rng.random() > .5 else (4, 26, 46, rng.randrange(max(4, opacity // 2), opacity + 1))
        d.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
    image.alpha_composite(layer)
    return image


def finish_icon(image: Image.Image, theme, seed: int):
    d = ImageDraw.Draw(image, "RGBA")
    w, h = image.size
    d.arc((10, 10, w - 10, h - 10), 198, 318, fill=_rgba(theme["light"], 150), width=max(2, w // 30))
    add_soft_texture(image, seed, opacity=18, count=240)
    return image


def _icon_frame(draw, w, h, theme):
    draw.ellipse((5, 5, w - 5, h - 5), fill=_rgba(theme["dark"], 242), outline=_rgba(theme["light"]), width=max(3, w // 24))
    draw.ellipse((15, 15, w - 15, h - 15), outline=_rgba(theme["accent"], 220), width=max(2, w // 35))


def semantic_icon(theme, stem: str, size) -> Image.Image:
    """Dedicated pictograms for final semantic assets; labels are never required."""
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    w, h = size
    _icon_frame(d, w, h, theme)
    light, accent, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["dark"])
    cx, cy = w / 2, h / 2
    sw = max(3, w // 15)
    if stem == "home_icon":
        d.polygon([(w*.21, h*.48), (w*.5, h*.22), (w*.79, h*.48)], fill=accent, outline=light)
        d.rounded_rectangle((w*.29, h*.45, w*.71, h*.77), radius=sw, fill=light)
        d.rectangle((w*.46, h*.58, w*.56, h*.77), fill=dark)
    elif stem == "settings_icon":
        pts = []
        for i in range(16):
            ang = -math.pi/2 + i*math.pi/8
            rad = w*.30 if i % 2 == 0 else w*.22
            pts.append((cx + math.cos(ang)*rad, cy + math.sin(ang)*rad))
        d.polygon(pts, fill=light, outline=accent)
        d.ellipse((cx-w*.10, cy-h*.10, cx+w*.10, cy+h*.10), fill=dark, outline=accent, width=sw//2)
    elif stem == "map_icon":
        d.polygon([(w*.19,h*.28),(w*.39,h*.21),(w*.62,h*.29),(w*.81,h*.21),(w*.81,h*.72),(w*.61,h*.80),(w*.39,h*.72),(w*.19,h*.80)], fill=light, outline=accent)
        for x in (w*.39, w*.62): d.line((x,h*.22,x,h*.76), fill=dark, width=max(2,sw//2))
        d.arc((w*.46,h*.32,w*.66,h*.66), 200, 510, fill=accent, width=sw//2)
    elif stem == "info_icon":
        d.ellipse((w*.25,h*.25,w*.75,h*.75), outline=light, width=sw)
        d.ellipse((cx-sw*.45, h*.34, cx+sw*.45, h*.34+sw), fill=accent)
        d.line((cx,h*.46,cx,h*.68), fill=light, width=sw)
    elif stem == "help_icon":
        d.arc((w*.29,h*.22,w*.71,h*.62), 200, 520, fill=light, width=sw)
        d.line((cx,h*.59,cx,h*.67), fill=light, width=sw)
        d.ellipse((cx-sw*.45,h*.75,cx+sw*.45,h*.75+sw), fill=accent)
    elif stem == "sound_icon":
        d.polygon([(w*.23,h*.43),(w*.39,h*.43),(w*.59,h*.26),(w*.59,h*.74),(w*.39,h*.57),(w*.23,h*.57)], fill=light)
        d.arc((w*.43,h*.28,w*.82,h*.72), 300, 60, fill=accent, width=sw)
        d.arc((w*.49,h*.19,w*.94,h*.81), 300, 60, fill=light, width=max(2,sw//2))
    elif stem == "music_icon":
        d.line((w*.59,h*.25,w*.59,h*.66), fill=light, width=sw)
        d.line((w*.59,h*.25,w*.78,h*.20), fill=accent, width=sw)
        d.ellipse((w*.30,h*.58,w*.50,h*.77), fill=accent, outline=light)
        d.ellipse((w*.49,h*.60,w*.69,h*.79), fill=accent, outline=light)
    elif stem == "haptic_icon":
        d.rounded_rectangle((w*.34,h*.24,w*.66,h*.76), radius=sw, fill=light, outline=accent, width=sw//2)
        d.ellipse((cx-sw*.35,h*.67,cx+sw*.35,h*.67+sw), fill=accent)
        d.arc((w*.18,h*.30,w*.48,h*.70), 270, 90, fill=accent, width=sw//2)
        d.arc((w*.52,h*.30,w*.82,h*.70), 90, 270, fill=accent, width=sw//2)
    elif stem == "language_icon":
        d.ellipse((w*.24,h*.22,w*.76,h*.78), outline=light, width=sw)
        d.arc((w*.37,h*.22,w*.63,h*.78), 90, 270, fill=accent, width=sw//2)
        d.line((w*.27,cy,w*.73,cy), fill=accent, width=sw//2)
        d.line((w*.31,h*.42,w*.69,h*.42), fill=light, width=max(2,sw//3))
    elif stem == "privacy_icon":
        d.polygon([(cx,h*.20),(w*.76,h*.34),(w*.70,h*.65),(cx,h*.81),(w*.30,h*.65),(w*.24,h*.34)], fill=light, outline=accent)
        d.rounded_rectangle((w*.40,h*.46,w*.60,h*.68), radius=sw//2, fill=dark, outline=accent)
        d.arc((w*.42,h*.31,w*.58,h*.57), 180, 360, fill=accent, width=sw//2)
    elif stem == "accessibility_icon":
        d.ellipse((cx-sw*.55,h*.22,cx+sw*.55,h*.22+sw*1.1), fill=accent)
        d.line((cx,h*.36,cx,h*.63), fill=light, width=sw)
        d.line((w*.28,h*.45,w*.72,h*.45), fill=light, width=sw)
        d.line((cx,h*.61,w*.33,h*.78), fill=light, width=sw)
        d.line((cx,h*.61,w*.67,h*.78), fill=light, width=sw)
    elif stem == "share_icon":
        nodes = [(w*.28,h*.52),(w*.66,h*.30),(w*.66,h*.73)]
        d.line((nodes[0][0],nodes[0][1],nodes[1][0],nodes[1][1]), fill=light, width=sw//2)
        d.line((nodes[0][0],nodes[0][1],nodes[2][0],nodes[2][1]), fill=light, width=sw//2)
        for x,y in nodes: d.ellipse((x-sw,y-sw,x+sw,y+sw), fill=accent, outline=light)
    elif stem == "friend_icon":
        d.ellipse((w*.27,h*.26,w*.47,h*.46), fill=light)
        d.ellipse((w*.53,h*.21,w*.73,h*.41), fill=accent)
        d.arc((w*.18,h*.40,w*.56,h*.82), 180, 360, fill=light, width=sw)
        d.arc((w*.44,h*.36,w*.82,h*.78), 180, 360, fill=accent, width=sw)
    elif stem in {"video_ad_icon", "play_icon"}:
        if stem == "video_ad_icon": d.rounded_rectangle((w*.20,h*.29,w*.80,h*.71), radius=sw, outline=light, width=sw)
        d.polygon([(w*.41,h*.33),(w*.70,h*.50),(w*.41,h*.67)], fill=accent, outline=light)
    elif stem == "pause_icon":
        d.rounded_rectangle((w*.31,h*.29,w*.44,h*.71), radius=sw//2, fill=light)
        d.rounded_rectangle((w*.56,h*.29,w*.69,h*.71), radius=sw//2, fill=accent)
    elif stem == "restart_icon":
        d.arc((w*.24,h*.25,w*.76,h*.77), 35, 320, fill=light, width=sw)
        d.polygon([(w*.26,h*.28),(w*.43,h*.26),(w*.32,h*.43)], fill=accent)
    elif stem == "lock_icon":
        d.rounded_rectangle((w*.28,h*.43,w*.72,h*.76), radius=sw, fill=accent, outline=light)
        d.arc((w*.34,h*.23,w*.66,h*.58), 180, 360, fill=light, width=sw)
        d.ellipse((cx-sw*.35,h*.54,cx+sw*.35,h*.54+sw), fill=dark)
    elif stem == "check_icon":
        d.line((w*.24,h*.52,w*.43,h*.70,w*.78,h*.29), fill=light, width=sw, joint="curve")
        d.ellipse((w*.17,h*.17,w*.83,h*.83), outline=accent, width=max(2,sw//2))
    elif stem == "close_x":
        d.line((w*.29,h*.29,w*.71,h*.71), fill=light, width=sw)
        d.line((w*.71,h*.29,w*.29,h*.71), fill=accent, width=sw)
    elif stem in {"back_arrow", "previous_arrow", "next_arrow"}:
        direction = -1 if stem != "next_arrow" else 1
        if direction > 0:
            d.line((w*.25,h*.50,w*.68,h*.50), fill=light, width=sw)
            d.line((w*.52,h*.31,w*.72,h*.50,w*.52,h*.69), fill=accent, width=sw)
        else:
            d.line((w*.75,h*.50,w*.32,h*.50), fill=light, width=sw)
            d.line((w*.48,h*.31,w*.28,h*.50,w*.48,h*.69), fill=accent, width=sw)
            if stem == "previous_arrow":
                d.line((w*.61,h*.31,w*.41,h*.50,w*.61,h*.69), fill=accent, width=sw)
    elif stem in {"timer_icon", "fail_timer_icon"}:
        d.ellipse((w*.25,h*.25,w*.75,h*.75), outline=light, width=sw)
        d.line((cx,cy,cx,h*.36), fill=accent, width=sw//2)
        d.line((cx,cy,w*.65,h*.59), fill=accent, width=sw//2)
        d.rectangle((w*.42,h*.17,w*.58,h*.24), fill=light)
    elif stem == "restore_purchase_icon":
        d.arc((w*.24,h*.24,w*.76,h*.76), 45, 315, fill=light, width=sw)
        d.polygon([(w*.70,h*.25),(w*.79,h*.25),(w*.76,h*.39)], fill=accent)
        d.rectangle((w*.35,h*.46,w*.65,h*.70), fill=accent, outline=light)
    elif stem == "booster_time" or stem in {"reward_ad_time_icon", "tutorial_timer_icon"}:
        d.ellipse((w*.25,h*.25,w*.75,h*.75), fill=accent, outline=light, width=sw)
        d.line((cx,cy,cx,h*.35), fill=dark, width=sw//2); d.line((cx,cy,w*.66,h*.60), fill=dark, width=sw//2)
        d.polygon([(w*.72,h*.22),(w*.85,h*.27),(w*.75,h*.37)], fill=light)
    elif stem == "booster_hammer":
        d.polygon([(w*.30,h*.29),(w*.62,h*.20),(w*.78,h*.37),(w*.46,h*.46)], fill=accent, outline=light)
        d.line((w*.47,h*.43,w*.72,h*.76), fill=light, width=max(6,w//10))
    elif stem == "booster_upgrade":
        d.polygon([(cx,h*.20),(w*.78,h*.49),(w*.61,h*.49),(w*.61,h*.78),(w*.39,h*.78),(w*.39,h*.49),(w*.22,h*.49)], fill=accent, outline=light)
    elif stem == "booster_shuffle":
        d.line((w*.22,h*.35,w*.40,h*.35,w*.62,h*.65,w*.80,h*.65), fill=light, width=sw//2)
        d.line((w*.22,h*.65,w*.40,h*.65,w*.62,h*.35,w*.80,h*.35), fill=accent, width=sw//2)
        d.polygon([(w*.76,h*.27),(w*.84,h*.35),(w*.76,h*.43)], fill=light); d.polygon([(w*.76,h*.57),(w*.84,h*.65),(w*.76,h*.73)], fill=accent)
    elif stem == "loading_cocktail_icon":
        d.polygon([(w*.27,h*.29),(w*.73,h*.29),(w*.63,h*.69),(w*.37,h*.69)], fill=accent, outline=light)
        d.line((w*.45,h*.25,w*.68,h*.14), fill=light, width=sw//2); d.ellipse((w*.64,h*.10,w*.78,h*.24), fill=light)
    elif stem in {"tutorial_merge_icon", "tutorial_order_icon"}:
        if stem.endswith("merge_icon"):
            d.ellipse((w*.22,h*.40,w*.48,h*.66), fill=accent, outline=light); d.ellipse((w*.52,h*.34,w*.78,h*.60), fill=light, outline=accent)
            d.line((w*.42,h*.35,w*.60,h*.65), fill=dark, width=sw//2)
        else:
            d.rounded_rectangle((w*.24,h*.29,w*.76,h*.70), radius=sw, fill=light, outline=accent, width=sw//2)
            d.line((w*.34,h*.43,w*.66,h*.43), fill=dark, width=sw//2); d.line((w*.34,h*.56,w*.57,h*.56), fill=dark, width=sw//2)
    elif stem == "tutorial_vip_badge":
        d.polygon([(cx,h*.20),(w*.73,h*.37),(w*.64,h*.72),(cx,h*.82),(w*.36,h*.72),(w*.27,h*.37)], fill=accent, outline=light)
        d.polygon(star_points(cx,cy,w*.18,w*.08), fill=light)
    elif stem == "reward_ad_double_icon":
        d.polygon([(cx,h*.19),(w*.77,h*.50),(cx,h*.81),(w*.23,h*.50)], fill=accent, outline=light)
        d.line((w*.35,h*.35,w*.65,h*.65), fill=light, width=sw//2)
    else:
        raise ValueError(f"No semantic pictogram for {stem}")
    return finish_icon(image, theme, sum(ord(char) for char in stem))


def reward_art(theme, stem: str, size) -> Image.Image:
    """Polished reward primitives; these are intentionally different from panels and badges."""
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(image, "RGBA")
    w, h = size
    light, accent, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["dark"])
    cx, cy = w / 2, h / 2
    if stem == "coin_icon" or stem.startswith("coin_pack"):
        d.ellipse((10, 12, w - 10, h - 8), fill=_rgba("#d99034"), outline=light, width=max(3, w // 18))
        d.ellipse((17, 18, w - 17, h - 15), fill=_rgba("#f7c85e"), outline=_rgba("#fff2bd"), width=max(2, w // 30))
        d.arc((28, 24, w - 28, h - 20), 100, 280, fill=_rgba("#fff8d8", 170), width=max(2, w // 24))
        d.ellipse((w * .39, h * .30, w * .61, h * .70), outline=_rgba("#b9782a"), width=max(2, w // 24))
        if "medium" in stem or "large" in stem:
            d.ellipse((w*.20, h*.20, w*.72, h*.72), outline=_rgba("#fff2bd", 170), width=max(2, w // 25))
            d.ellipse((w*.28, h*.28, w*.80, h*.80), outline=_rgba("#d99034", 220), width=max(2, w // 25))
    elif stem == "gem_icon" or stem.startswith("gem_pack"):
        d.polygon([(cx, 7), (w - 14, h * .34), (w * .78, h - 8), (w * .22, h - 8), (14, h * .34)], fill=_rgba("#54d4db"), outline=light)
        d.polygon([(cx, 7), (w * .58, h * .34), (w * .50, h - 8), (w * .22, h - 8), (14, h * .34)], fill=_rgba("#a6f4e9", 210))
        d.line((cx, 7, w * .50, h - 8, 14, h * .34), fill=_rgba("#f7ffff", 190), width=max(2, w // 28))
    elif stem in {"star_empty", "star_filled", "star_large_empty", "star_large_filled", "star_small_empty", "star_small_filled"}:
        outer = min(w, h) * (.36 if "large" not in stem else .42)
        outline = _rgba("#f8e4a6")
        fill = _rgba("#f5c54f") if "filled" in stem else _rgba("#2b5362", 240)
        d.polygon(star_points(cx, cy, outer, outer * .43), fill=fill, outline=outline)
        d.polygon(star_points(cx, cy, outer * .58, outer * .24), fill=_rgba("#fff5c7", 120 if "filled" in stem else 60))
    elif "chest" in stem:
        premium = "premium" in stem
        big = "big" in stem or "large" in stem
        chest = _rgba("#7b432d" if not premium else "#172f4a")
        metal = _rgba("#efbd54" if not premium else "#bceee4")
        x0, y0, x1, y1 = w * .14, h * .38, w * .86, h * .86
        if "open" in stem:
            for angle in range(210, 331, 20):
                ex = cx + math.cos(math.radians(angle)) * w * .40
                ey = h * .37 + math.sin(math.radians(angle)) * h * .24
                d.line((cx, h*.38, ex, ey), fill=_rgba("#fff0a0", 100), width=max(2, w // 32))
            d.polygon([(x0 + 8, h*.40), (w*.28, h*.18), (w*.72, h*.18), (x1 - 8, h*.40)], fill=_rgba("#bd7441" if not premium else "#2d6480"), outline=metal)
            d.rounded_rectangle((x0, h*.43, x1, y1), radius=max(8, w // 16), fill=chest, outline=metal, width=max(3, w // 24))
            d.ellipse((w*.33, h*.50, w*.67, h*.84), fill=_rgba("#f8d568", 175), outline=_rgba("#fff4b1"), width=max(2, w // 28))
            d.polygon(star_points(cx, h*.67, w*.13, w*.055), fill=_rgba("#fff8cf"))
        else:
            d.ellipse((x0, h * .15, x1, h * .63), fill=_rgba("#bd7441" if not premium else "#2d6480"), outline=metal, width=max(3, w // 24))
            d.rounded_rectangle((x0, y0, x1, y1), radius=max(8, w // 16), fill=chest, outline=metal, width=max(3, w // 24))
            d.line((x0 + 8, h * .51, x1 - 8, h * .51), fill=metal, width=max(3, w // 22))
            d.rectangle((w * .45, h * .48, w * .55, h * .69), fill=metal)
            d.ellipse((w * .46, h * .58, w * .54, h * .66), fill=dark)
            if big:
                d.arc((x0 + 4, h * .10, x1 - 4, h * .67), 180, 360, fill=_rgba("#fff0aa", 180), width=max(2, w // 30))
    else:
        d.ellipse((8, 8, w - 8, h - 8), fill=dark, outline=accent, width=max(3, w // 18))
        d.polygon(star_points(cx, cy, w * .30, w * .13), fill=light)
    return finish_icon(image, theme, sum(ord(char) for char in stem) + 413)


STATEFUL_STEMS = {
    "toggle_on", "toggle_off", "level_node_locked", "level_node_unlocked", "tab_active", "tab_inactive",
    "daily_day_locked", "booster_locked", "booster_selected", "route_marker", "route_marker_current", "route_marker_complete",
}


def stateful_art(theme, stem: str, size) -> Image.Image:
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(image, "RGBA")
    w, h = size
    light, accent, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["dark"])
    if stem in {"toggle_on", "toggle_off"}:
        on = stem == "toggle_on"
        track = _rgba("#287d78" if on else "#536875", 245)
        knob = _rgba("#ffd466" if on else "#a5b0ad")
        d.rounded_rectangle((6, h*.22, w-6, h*.78), radius=int(h*.28), fill=track, outline=light, width=max(2, h//22))
        x = w*.70 if on else w*.30
        d.ellipse((x-h*.18, h*.32, x+h*.18, h*.68), fill=knob, outline=_rgba("#fff7cf" if on else "#71828a"), width=max(2, h//28))
        if on:
            d.arc((w*.12,h*.28,w*.48,h*.72), 210, 330, fill=_rgba("#6ce2c3", 170), width=max(2, h//24))
        return finish_icon(image, theme, 700 + len(stem))
    if stem in {"tab_active", "tab_inactive"}:
        active = stem == "tab_active"
        fill = _rgba(theme["light"], 245) if active else _rgba(theme["dark"], 220)
        outline = _rgba(theme["accent"], 255) if active else _rgba(theme["light"], 95)
        d.rounded_rectangle((6, h*.15, w-6, h*.82), radius=max(8, h//5), fill=fill, outline=outline, width=max(3, h//20))
        d.line((w*.18,h*.70,w*.82,h*.70), fill=_rgba(theme["accent"] if active else theme["light"], 255 if active else 80), width=max(4, h//12))
        if active:
            d.line((w*.25,h*.23,w*.75,h*.23), fill=_rgba("#fff8d7", 190), width=max(2, h//25))
        return finish_icon(image, theme, 710 + len(stem))
    if stem in {"level_node_locked", "level_node_unlocked"}:
        unlocked = stem == "level_node_unlocked"
        cx, cy = w*.50, h*.50
        radius = min(w,h)*.34
        d.ellipse((cx-radius,cy-radius,cx+radius,cy+radius), fill=_rgba(theme["mid"] if unlocked else "#4d5a63", 245), outline=_rgba(theme["accent"] if unlocked else "#82909a"), width=max(5, int(radius*.10)))
        if unlocked:
            d.polygon(star_points(cx,cy,radius*.56,radius*.24), fill=accent, outline=light)
            d.ellipse((cx-radius*.20,cy-radius*.20,cx+radius*.20,cy+radius*.20), fill=_rgba("#fff6c9", 130))
        else:
            d.rounded_rectangle((cx-radius*.36,cy-radius*.02,cx+radius*.36,cy+radius*.46), radius=8, fill=_rgba("#303d49"), outline=_rgba("#aab5b0"), width=max(3, int(radius*.08)))
            d.arc((cx-radius*.25,cy-radius*.40,cx+radius*.25,cy+radius*.14), 180, 360, fill=_rgba("#aab5b0"), width=max(4, int(radius*.09)))
        return finish_icon(image, theme, 720 + len(stem))
    if stem in {"daily_day_locked", "booster_locked"}:
        d.rounded_rectangle((6, 6, w-6, h-6), radius=max(10, min(w,h)//7), fill=_rgba("#4f6572", 230), outline=_rgba("#9aa9a8"), width=max(3, min(w,h)//22))
        cx, cy = w/2, h/2
        d.rounded_rectangle((cx-w*.16,cy-h*.02,cx+w*.16,cy+h*.24), radius=6, fill=_rgba("#273945"), outline=light, width=max(2, min(w,h)//30))
        d.arc((cx-w*.11,cy-h*.20,cx+w*.11,cy+h*.10),180,360,fill=light,width=max(3,min(w,h)//25))
        return finish_icon(image, theme, 730 + len(stem))
    if stem in {"route_marker", "route_marker_current", "route_marker_complete"}:
        cx, cy = w / 2, h / 2
        radius = min(w, h) * .34
        if stem == "route_marker":
            d.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), fill=_rgba("#f5e7bd"), outline=_rgba("#5d493e"), width=max(5, int(radius*.10)))
            d.ellipse((cx-radius*.30, cy-radius*.30, cx+radius*.30, cy+radius*.30), fill=_rgba(theme["accent"]), outline=dark, width=max(3, int(radius*.07)))
        elif stem == "route_marker_current":
            d.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), fill=_rgba("#fff2c0"), outline=_rgba(theme["accent"]), width=max(5, int(radius*.10)))
            d.ellipse((cx-radius*.76, cy-radius*.76, cx+radius*.76, cy+radius*.76), outline=_rgba("#fff6bf", 220), width=max(4, int(radius*.08)))
            d.polygon(star_points(cx, cy, radius*.48, radius*.20), fill=accent, outline=dark)
        else:
            d.ellipse((cx-radius, cy-radius, cx+radius, cy+radius), fill=_rgba("#8bd2a7"), outline=_rgba("#e7f7d7"), width=max(5, int(radius*.10)))
            d.line((cx-radius*.48, cy, cx-radius*.10, cy+radius*.34, cx+radius*.55, cy-radius*.38), fill=_rgba("#174858"), width=max(7, int(radius*.12)), joint="curve")
        return finish_icon(image, theme, 750 + len(stem))
    if stem == "booster_selected":
        d.rounded_rectangle((5,5,w-5,h-5), radius=18, fill=_rgba(theme["accent"], 95), outline=light, width=7)
        d.polygon([(w*.50,h*.17),(w*.82,h*.50),(w*.50,h*.83),(w*.18,h*.50)], outline=accent, width=4)
        d.arc((w*.16,h*.16,w*.84,h*.84), 205, 330, fill=_rgba("#fff8cf", 190), width=max(2,w//25))
        return finish_icon(image, theme, 740)
    raise ValueError(f"No stateful renderer for {stem}")


SCREEN_COMPONENT_STEMS = {
    "prelevel_panel", "pause_panel", "level_complete_panel", "level_failed_panel", "milestone_reward_panel",
    "island_complete_panel", "rewarded_ad_panel", "settings_panel", "vip_badge", "vip_complete_badge",
    "timer_panel", "timer_panel_small", "level_label_panel", "vip_reward_frame", "vip_reward_slot", "order_slot",
    "reward_slot", "remaining_order_slot", "score_summary_panel", "milestone_banner", "next_island_unlock_frame",
}


def screen_component(theme, stem: str, size) -> Image.Image:
    """Dedicated hierarchy art for result, reward, timer, and modal families."""
    w, h = size
    image = rounded_panel(size, fill="#f8edc8", rim="#fff8dc", stroke=theme["dark"], shadow="#081827", radius=max(14, min(w, h)//7), accent=theme["accent"])
    d = ImageDraw.Draw(image, "RGBA")
    light, accent, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["dark"])
    if stem in {"vip_badge", "vip_complete_badge"}:
        image = Image.new("RGBA", size, (0, 0, 0, 0)); d = ImageDraw.Draw(image, "RGBA")
        cx, cy = w/2, h/2
        d.polygon([(cx,h*.12),(w*.80,h*.32),(w*.69,h*.78),(cx,h*.91),(w*.31,h*.78),(w*.20,h*.32)], fill=accent, outline=light)
        d.polygon(star_points(cx, cy, min(w,h)*.24, min(w,h)*.11, 5), fill=light, outline=dark)
        if stem == "vip_complete_badge":
            d.arc((w*.18,h*.17,w*.82,h*.83), 205, 335, fill=_rgba("#fff4b6"), width=max(3,w//22))
        return finish_icon(image, theme, 611 + sum(ord(char) for char in stem))
    if stem in {"timer_panel", "timer_panel_small"}:
        d.ellipse((w*.09,h*.18,w*.28,h*.82), fill=_rgba("#e96d57"), outline=light, width=max(2,w//35))
        d.line((w*.185,h*.50,w*.185,h*.31), fill=light, width=max(2,w//32)); d.line((w*.185,h*.50,w*.24,h*.62), fill=light, width=max(2,w//32))
        d.line((w*.34,h*.50,w*.90,h*.50), fill=_rgba(theme["dark"], 100), width=max(4,h//12))
        return finish_icon(image, theme, 612 + len(stem))
    if stem in {"level_label_panel", "score_summary_panel"}:
        d.ellipse((w*.10,h*.22,w*.29,h*.78), fill=accent, outline=light, width=max(2,w//35))
        d.polygon(star_points(w*.195,h*.50,min(w,h)*.10,min(w,h)*.045), fill=light)
        d.line((w*.36,h*.36,w*.88,h*.36), fill=_rgba(theme["dark"], 125), width=max(3,h//10))
        d.line((w*.36,h*.60,w*.72,h*.60), fill=_rgba(theme["dark"], 75), width=max(2,h//14))
        return finish_icon(image, theme, 613 + len(stem))
    if stem in {"order_slot", "reward_slot", "remaining_order_slot", "vip_reward_slot"}:
        d.ellipse((w*.14,h*.22,w*.44,h*.78), fill=_rgba(theme["mid"]), outline=accent, width=max(2,w//35))
        d.ellipse((w*.21,h*.29,w*.37,h*.71), fill=_rgba(theme["light"], 170), outline=light, width=max(2,w//40))
        d.line((w*.52,h*.34,w*.88,h*.34), fill=_rgba(theme["dark"], 120), width=max(3,h//11))
        d.line((w*.52,h*.61,w*.76,h*.61), fill=_rgba(theme["dark"], 70), width=max(2,h//15))
        return finish_icon(image, theme, 614 + len(stem))
    if stem == "pause_panel":
        d.rounded_rectangle((w*.27,h*.22,w*.42,h*.78), radius=max(4,w//30), fill=accent)
        d.rounded_rectangle((w*.58,h*.22,w*.73,h*.78), radius=max(4,w//30), fill=light)
    elif stem == "level_complete_panel":
        d.polygon([(w*.13,h*.64),(w*.22,h*.37),(w*.32,h*.50),(w*.42,h*.32),(w*.52,h*.50),(w*.64,h*.33),(w*.78,h*.64)], fill=_rgba("#6bb58d", 210), outline=accent)
        d.polygon(star_points(w*.50,h*.42,min(w,h)*.13,min(w,h)*.06), fill=accent, outline=light)
    elif stem == "level_failed_panel":
        d.ellipse((w*.34,h*.23,w*.66,h*.55), fill=_rgba("#e86f62"), outline=light, width=max(3,w//30))
        d.line((w*.41,h*.30,w*.59,h*.48), fill=light, width=max(4,w//18)); d.line((w*.59,h*.30,w*.41,h*.48), fill=dark, width=max(4,w//18))
    elif stem == "milestone_reward_panel":
        d.polygon(star_points(w*.50,h*.42,min(w,h)*.15,min(w,h)*.07,6), fill=accent, outline=light)
        d.ellipse((w*.26,h*.55,w*.74,h*.86), fill=_rgba("#7b432d"), outline=accent, width=max(3,w//26))
        d.arc((w*.26,h*.40,w*.74,h*.76), 180, 360, fill=light, width=max(3,w//26))
    elif stem == "island_complete_panel":
        d.polygon([(w*.18,h*.54),(w*.28,h*.30),(w*.50,h*.42),(w*.72,h*.30),(w*.82,h*.54),(w*.68,h*.80),(w*.32,h*.80)], fill=_rgba("#2f907d"), outline=accent)
        d.polygon(star_points(w*.50,h*.50,min(w,h)*.13,min(w,h)*.06), fill=light)
    elif stem == "rewarded_ad_panel":
        d.rounded_rectangle((w*.22,h*.20,w*.78,h*.56), radius=max(8,w//18), fill=_rgba("#193a54"), outline=accent, width=max(3,w//26))
        d.polygon([(w*.43,h*.28),(w*.65,h*.38),(w*.43,h*.48)], fill=light)
        d.line((w*.28,h*.70,w*.72,h*.70), fill=_rgba(theme["dark"], 100), width=max(3,h//11))
    elif stem == "settings_panel":
        for row, color in enumerate((accent, _rgba("#54d4db"), _rgba("#f08b70"))):
            yy = h * (.30 + row*.22)
            d.line((w*.20,yy,w*.78,yy), fill=_rgba(theme["dark"], 110), width=max(3,h//18))
            d.ellipse((w*(.34 + row*.13), yy-h*.07, w*(.46 + row*.13), yy+h*.07), fill=color, outline=light, width=2)
    elif stem == "next_island_unlock_frame":
        d.polygon([(w*.18,h*.60),(w*.36,h*.26),(w*.50,h*.50),(w*.65,h*.21),(w*.82,h*.60),(w*.68,h*.84),(w*.31,h*.84)], fill=_rgba(theme["mid"]), outline=accent)
        d.polygon(star_points(w*.50,h*.47,min(w,h)*.11,min(w,h)*.05), fill=light)
    elif stem == "milestone_banner":
        d.polygon([(w*.06,h*.24),(w*.18,h*.24),(w*.25,h*.50),(w*.18,h*.76),(w*.06,h*.76),(w*.12,h*.50)], fill=accent, outline=light)
        d.polygon([(w*.94,h*.24),(w*.82,h*.24),(w*.75,h*.50),(w*.82,h*.76),(w*.94,h*.76),(w*.88,h*.50)], fill=accent, outline=light)
        d.polygon(star_points(w*.50,h*.50,min(w,h)*.18,min(w,h)*.08), fill=light)
    return finish_icon(image, theme, 615 + sum(ord(char) for char in stem))


def remediated_island_icon(theme, island_id: str) -> Image.Image:
    image = Image.new("RGBA", (220, 220), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    d.ellipse((6, 6, 214, 214), fill=_rgba(theme["dark"], 245), outline=_rgba(theme["light"]), width=8)
    d.ellipse((20, 20, 200, 200), fill=_rgba(theme["mid"]), outline=_rgba(theme["accent"], 230), width=4)
    light, accent, wood, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["wood"]), _rgba(theme["dark"])
    if island_id == "sunny_cove":
        d.pieslice((111, 34, 176, 99), 0, 360, fill=accent); d.polygon([(28,156),(66,97),(103,137),(146,92),(194,160)], fill=wood)
        for x in (62,82,170): d.line((x,154,x-8,92), fill=dark, width=7); d.ellipse((x-20,83,x+7,101), fill=light)
        d.arc((35,133,180,194), 180, 360, fill=light, width=7)
    elif island_id == "tiki_island":
        d.polygon([(35,151),(72,101),(148,101),(188,151)], fill=wood, outline=light); d.rectangle((59,92,164,112), fill=_rgba("#d8ad68"))
        for x in (67,94,121,148): d.line((x,106,x,170), fill=_rgba("#d8ad68"), width=6)
        d.ellipse((86,125,137,178), fill=_rgba("#a9633b"), outline=accent, width=4); d.ellipse((98,141,108,151), fill=light); d.ellipse((117,141,127,151), fill=light); d.line((102,160,124,160), fill=dark, width=5)
    elif island_id == "azure_bay":
        d.polygon([(34,151),(104,124),(169,145),(183,165),(56,170)], fill=light, outline=accent)
        d.line((61,138,145,139), fill=dark, width=5); d.line((92,139,104,88), fill=dark, width=5); d.polygon([(105,88),(142,122),(105,122)], fill=light)
        for y in (178,187): d.arc((28,y-13,190,y+13), 180, 360, fill=light, width=4)
    elif island_id == "coconut_beach":
        d.ellipse((53,140,174,182), fill=_rgba("#f6d38a"), outline=light)
        for x, lean in ((76,-1),(105,1),(138,-1)): d.line((x,154,x+lean*18,75), fill=wood, width=8)
        for x,y in ((55,78),(83,64),(130,72),(158,91)): d.ellipse((x-25,y-12,x+14,y+10), fill=_rgba("#75b46a"), outline=light)
        d.ellipse((99,129,122,153), fill=_rgba("#6b3e28"), outline=accent)
    elif island_id == "sunset_island":
        d.ellipse((73,42,151,120), fill=_rgba("#ff966d"), outline=_rgba("#ffd19d"), width=4); d.polygon([(25,160),(73,109),(109,143),(144,102),(196,160)], fill=wood)
        for y in (164,176,188): d.arc((28,y-14,194,y+16), 180, 360, fill=_rgba("#ffb77d"), width=4)
    elif island_id == "party_beach":
        d.ellipse((70,47,151,128), fill=_rgba("#c7f8f0"), outline=_rgba("#ff4bb6"), width=5)
        for ang in range(0,360,45): d.line((110,87,110+int(math.cos(math.radians(ang))*54),87+int(math.sin(math.radians(ang))*54)), fill=_rgba("#48e5d1"), width=4)
        d.line((50,166,171,166), fill=_rgba("#ff4bb6"), width=8); d.line((74,150,74,181), fill=_rgba("#8aff5a"), width=7); d.line((148,150,148,181), fill=_rgba("#48e5d1"), width=7)
    elif island_id == "frozen_paradise":
        d.polygon([(31,164),(75,89),(110,127),(148,67),(193,164)], fill=_rgba("#c9f5ff"), outline=light)
        d.polygon([(75,89),(110,127),(91,127)], fill=_rgba("#86d5ea")); d.polygon([(148,67),(166,128),(133,111)], fill=_rgba("#86d5ea"))
        d.line((58,175,176,175), fill=light, width=7); d.polygon([(51,83),(69,60),(84,85)], fill=_rgba("#7dcd93"), outline=light)
    elif island_id == "volcano_bay":
        d.polygon([(28,169),(68,145),(104,58),(141,145),(194,169)], fill=dark, outline=accent)
        d.line((104,70,104,129), fill=_rgba("#ff6948"), width=7); d.line((93,119,74,160), fill=_rgba("#ff9c4e"), width=5); d.line((116,122,142,159), fill=_rgba("#ff6948"), width=5)
        d.ellipse((93,45,115,67), fill=_rgba("#f5dfb0")); d.ellipse((124,35,144,55), fill=_rgba("#f5dfb0"))
    elif island_id == "billionaire_island":
        d.rectangle((53,111,169,165), fill=light, outline=accent, width=5); d.polygon([(42,113),(110,61),(181,113)], fill=wood, outline=accent)
        for x in (70,96,123,149): d.rectangle((x,127,x+12,145), fill=dark)
        d.polygon([(57,178),(169,178),(143,159),(84,159)], fill=light, outline=accent); d.line((77,184,165,184), fill=accent, width=5)
    elif island_id == "final_island":
        d.polygon([(33,169),(69,139),(79,84),(111,121),(144,72),(153,138),(191,169)], fill=dark, outline=accent)
        d.polygon([(80,137),(110,102),(143,137),(134,168),(92,168)], fill=_rgba("#147f93"), outline=light)
        d.polygon(star_points(111,51,24,10,6), fill=accent, outline=light)
    return finish_icon(image, theme, sum(ord(char) for char in island_id) + 712)


def remediated_table_image(theme, island_id: str) -> Image.Image:
    mask = table_mask()
    image = Image.new("RGBA", (W, H), _rgba(theme["wood"]))
    d = ImageDraw.Draw(image, "RGBA")
    # A shared perspective grid is intentionally constant; material treatment varies inside the frozen mask.
    d.rectangle((0, 398, W, H), fill=_rgba(theme["wood"]))
    if island_id == "sunny_cove":
        d.rectangle((0,398,W,H), fill=_rgba("#b96b3c"));
        for y in range(445, 1230, 105): d.line((0,y,W,y+30), fill=_rgba("#8a4b31", 110), width=8)
        for x in (190,365,540): d.line((x,420,x+18,1220), fill=_rgba("#20a8ad",150), width=14)
        d.line((130,398,590,398), fill=_rgba("#f7f0d3"), width=17)
    elif island_id == "tiki_island":
        d.rectangle((0,398,W,H), fill=_rgba("#4b281f"))
        for x in range(50,700,90): d.line((x,410,x+40,1260), fill=_rgba("#8d5733",150), width=18)
        for y in range(510,1200,150): d.line((55,y,665,y+35), fill=_rgba("#241519",190), width=8)
        for x in (185,530): d.ellipse((x-30,470,x+30,530), fill=_rgba("#d8ad68",100), outline=_rgba("#efaa42"), width=5)
        d.line((130,398,590,398), fill=_rgba("#d8ad68"), width=18)
    elif island_id == "azure_bay":
        d.rectangle((0,398,W,H), fill=_rgba("#e5e7d3"))
        for y in range(455,1240,95): d.line((0,y,W,y), fill=_rgba("#ffffff",190), width=12)
        for x in range(70,680,130): d.line((x,420,x+28,1220), fill=_rgba("#80deda",130), width=11)
        for x in (180,540): d.ellipse((x-18,570,x+18,606), outline=_rgba("#3b9de4"), width=6)
        d.line((130,398,590,398), fill=_rgba("#f6fbf4"), width=18)
    elif island_id == "coconut_beach":
        d.rectangle((0,398,W,H), fill=_rgba("#cba06b"))
        for x in range(-20,760,70): d.line((x,410,x+130,1260), fill=_rgba("#f0d39a",135), width=13)
        for y in range(480,1220,90): d.line((0,y,W,y+65), fill=_rgba("#8d6347",100), width=5)
        for x in range(65,700,125): d.line((x,435,x-38,1220), fill=_rgba("#fff0c8",95), width=4)
        d.line((130,398,590,398), fill=_rgba("#fff0c8"), width=17)
    elif island_id == "sunset_island":
        d.rectangle((0,398,W,H), fill=_rgba("#6e302a"))
        for y in range(445,1240,140): d.line((0,y,W,y+22), fill=_rgba("#321f2a",170), width=14)
        for x in (218,360,502): d.line((x,430,x+28,1210), fill=_rgba("#ff9d65",150), width=20)
        d.ellipse((270,640,450,820), fill=_rgba("#ff9d65",48), outline=_rgba("#ffd09e",155), width=6)
        d.line((130,398,590,398), fill=_rgba("#ffb383"), width=18)
    elif island_id == "party_beach":
        d.rectangle((0,398,W,H), fill=_rgba("#202047"))
        for x, col in ((150,"#47e1d0"),(280,"#ff4bb6"),(410,"#8aff5a"),(540,"#47e1d0")):
            d.line((x,420,x+20,1210), fill=_rgba(col,220), width=8)
        for y in range(500,1200,170): d.line((0,y,W,y+18), fill=_rgba("#5a2d87",160), width=9)
        d.line((130,398,590,398), fill=_rgba("#47e1d0"), width=20)
    elif island_id == "frozen_paradise":
        d.rectangle((0,398,W,H), fill=_rgba("#c6eaf1"))
        for pts in [[(95,430),(180,630),(120,880),(220,1200)],[(330,400),(250,690),(370,950),(305,1260)],[(550,430),(480,720),(620,1040),(550,1260)]]:
            d.line(pts, fill=_rgba("#ffffff",190), width=24, joint="curve")
        for x in (170,360,550): d.polygon([(x,500),(x+45,590),(x,690),(x-45,590)], fill=_rgba("#8fd7e7",110), outline=_rgba("#f4ffff",180))
        d.line((130,398,590,398), fill=_rgba("#f4ffff"), width=20)
    elif island_id == "volcano_bay":
        d.rectangle((0,398,W,H), fill=_rgba("#29252b"))
        for x,y in ((145,480),(260,650),(365,505),(485,720),(600,560)):
            d.line((x,y,x+55,1180), fill=_rgba("#ff6948",190), width=7)
            d.line((x+8,y+8,x+46,y+190), fill=_rgba("#ffb14e",150), width=3)
        for x in range(40,700,100): d.line((x,430,x+60,1220), fill=_rgba("#54404a",100), width=16)
        d.line((130,398,590,398), fill=_rgba("#ff6948"), width=18)
    elif island_id == "billionaire_island":
        d.rectangle((0,398,W,H), fill=_rgba("#3a2b2a"))
        for y in range(440,1240,150): d.line((0,y,W,y), fill=_rgba("#765b4c",135), width=10)
        for x in (170,360,550): d.line((x,420,x+15,1220), fill=_rgba("#fbf5e5",205), width=23)
        for x in (170,360,550): d.line((x-12,430,x+35,1210), fill=_rgba("#e9c66d",220), width=5)
        d.line((130,398,590,398), fill=_rgba("#e9c66d"), width=20)
    elif island_id == "final_island":
        d.rectangle((0,398,W,H), fill=_rgba("#191b26"))
        for y in range(440,1240,170): d.line((0,y,W,y+28), fill=_rgba("#0c1020",210), width=18)
        for x in (145,300,455,610):
            d.line((x,420,x+20,1220), fill=_rgba("#147f93",155), width=17)
            d.line((x+4,430,x+20,1220), fill=_rgba("#e6bd55",165), width=4)
        for x,y in ((230,620),(470,800),(350,1070)):
            d.ellipse((x-34,y-22,x+34,y+22), fill=_rgba("#9ee8e0",90), outline=_rgba("#e6bd55",190), width=4)
        d.line((130,398,590,398), fill=_rgba("#e6bd55"), width=20)
    # Material finish: fine grain, hand-placed highlights, and a restrained varnish sheen.
    rng = random.Random(9100 + sum(ord(char) for char in island_id))
    for _ in range(720):
        x = rng.randrange(20, W - 20)
        y = rng.randrange(430, H - 12)
        length = rng.randrange(8, 52)
        alpha = rng.randrange(12, 38)
        color = _rgba(theme["light"] if rng.random() > .46 else theme["dark"], alpha)
        d.line((x, y, min(W, x + length), y + rng.choice((-2, -1, 0, 1, 2))), fill=color, width=rng.choice((1, 1, 2, 3)))
    for y, alpha in ((414, 70), (420, 30)):
        d.line((130, y, 590, y), fill=_rgba(theme["light"], alpha), width=3)
    d.line((42, 690, 678, 734), fill=_rgba(theme["light"], 22), width=26)
    d.line((42, 694, 678, 738), fill=_rgba(theme["light"], 12), width=12)
    add_soft_texture(image, 19000 + sum(ord(char) for char in island_id), opacity=14, count=420)
    image.putalpha(mask)
    return image


def remediated_screen_background(theme, stem: str, size=(W,H), island_id=None) -> Image.Image:
    image = gradient(size, theme["deep"], theme["mid"])
    d = ImageDraw.Draw(image, "RGBA")
    w, h = size
    if stem == "splash_background":
        d.rectangle((0,0,w,h), fill=_rgba("#0b2940")); d.ellipse((w*.12,h*.08,w*.88,h*.56), fill=_rgba("#f39d6b",100))
        d.polygon([(0,h*.66),(w*.2,h*.48),(w*.43,h*.63),(w*.67,h*.44),(w,h*.60),(w,h),(0,h)], fill=_rgba("#12637c"))
        for x in (w*.18,w*.52,w*.81): d.line((x,h*.68,x-20,h*.34), fill=_rgba("#1c5564"), width=max(5,w//55))
        for x in (w*.16, w*.28, w*.78):
            d.ellipse((x - 34, h*.62, x + 34, h*.68), fill=_rgba("#b8eff1", 115))
            d.line((x, h*.64, x - 8, h*.83), fill=_rgba("#e8ffff", 95), width=5)
        for x, y in ((w*.08,h*.22),(w*.90,h*.30)):
            d.line((x, y + 160, x + (48 if x < w/2 else -48), y), fill=_rgba("#164c5a"), width=13)
            for leaf in range(5):
                d.ellipse((x + (48 if x < w/2 else -48) * .35 + leaf * (14 if x < w/2 else -14), y + leaf * 13, x + 90 + leaf * (12 if x < w/2 else -12), y + 24 + leaf * 13), fill=_rgba("#54a977", 190))
        add_soft_texture(image, 4201, opacity=20, count=620)
        return image
    if stem == "main_menu_background":
        d.ellipse((w*.26,h*.12,w*.74,h*.48), fill=_rgba("#ffd169",180))
        d.polygon([(0,h*.57),(w*.18,h*.42),(w*.42,h*.56),(w*.66,h*.39),(w,h*.55),(w,h),(0,h)], fill=_rgba("#0e6b7a"))
        d.polygon([(w*.08,h*.65),(w*.32,h*.51),(w*.52,h*.62),(w*.78,h*.48),(w*.96,h*.60),(w,h),(0,h)], fill=_rgba("#d18c58"))
        for x in (w*.10,w*.84):
            d.line((x,h*.70,x-20,h*.30), fill=_rgba("#174858"), width=max(8,w//32)); d.ellipse((x-55,h*.26,x+38,h*.33), fill=_rgba("#80c76b"), outline=_rgba("#f7e9bd"))
        d.polygon([(w*.23,h*.51),(w*.50,h*.35),(w*.77,h*.51),(w*.72,h*.58),(w*.28,h*.58)], fill=_rgba("#efe0ad", 210), outline=_rgba("#fff3c7", 180))
        d.line((w*.33,h*.56,w*.33,h*.76), fill=_rgba("#7c4b31"), width=10); d.line((w*.67,h*.56,w*.67,h*.76), fill=_rgba("#7c4b31"), width=10)
        for x in (w*.42,w*.50,w*.58):
            d.line((x,h*.38,x,h*.47), fill=_rgba("#5c3c2d"), width=4)
            d.ellipse((x-11,h*.46,x+11,h*.50), fill=_rgba("#ffd46d"), outline=_rgba("#fff6c8"))
        add_soft_texture(image, 4202, opacity=22, count=760)
        return image
    if stem == "world_map_background":
        d.rectangle((0,0,w,h), fill=_rgba("#168aa0"));
        d.ellipse((w*.04,h*.14,w*.40,h*.55), fill=_rgba("#23aeb0"), outline=_rgba("#f7e9bd",160), width=4)
        d.ellipse((w*.54,h*.04,w*.92,h*.32), fill=_rgba("#27aeb4"), outline=_rgba("#f7e9bd",160), width=4)
        d.ellipse((w*.36,h*.54,w*.76,h*.94), fill=_rgba("#36b7a5"), outline=_rgba("#f7e9bd",160), width=4)
        route=[(w*.18,h*.29),(w*.36,h*.48),(w*.59,h*.22),(w*.66,h*.66),(w*.45,h*.79)]
        d.line(route, fill=_rgba("#ffd266"), width=max(8,w//35), joint="curve")
        for i,(x,y) in enumerate(route):
            d.ellipse((x-18,y-18,x+18,y+18), fill=_rgba("#fff2c0"), outline=_rgba("#744934"), width=4)
            d.polygon([(x-22,y+15),(x+24,y+15),(x+12,y+30),(x-12,y+30)], fill=_rgba("#d98c59", 210))
            if i % 2 == 0: d.ellipse((x-7,y-7,x+7,y+7), fill=_rgba("#41b9a9"), outline=_rgba("#fff6c4"))
        for y in range(int(h*.10), int(h*.94), 64):
            d.arc((-80,y,w+80,y+30), 0, 180, fill=_rgba("#baf2e9", 55), width=3)
        add_soft_texture(image, 4203, opacity=18, count=700)
        return image
    if stem == "shop_background":
        d.rectangle((0,0,w,h), fill=_rgba("#5c3529")); d.rectangle((w*.08,h*.12,w*.92,h*.86), fill=_rgba("#b46e45"), outline=_rgba("#f6d18a"), width=8)
        for y in (h*.31,h*.53,h*.75): d.line((w*.13,y,w*.87,y), fill=_rgba("#5c3529"), width=12)
        for x,y,col in ((w*.24,h*.22,"#f7e9bd"),(w*.46,h*.22,"#47e1d0"),(w*.68,h*.22,"#ff9d65"),(w*.28,h*.42,"#e9c66d"),(w*.52,h*.42,"#6dd5db"),(w*.74,h*.42,"#ff6f80"),(w*.36,h*.64,"#f7e9bd"),(w*.66,h*.64,"#47e1d0")):
            d.ellipse((x-30,y-30,x+30,y+30), fill=_rgba(col), outline=_rgba("#fff1c6"), width=3)
            d.ellipse((x-18,y-18,x+12,y+4), fill=_rgba("#ffffff", 85))
        d.polygon([(w*.08,h*.12),(w*.92,h*.12),(w*.84,h*.04),(w*.16,h*.04)], fill=_rgba("#f0c372"), outline=_rgba("#fff0b2"), width=4)
        for x in (w*.22,w*.50,w*.78):
            d.rounded_rectangle((x-14,h*.82,x+14,h*.87), radius=5, fill=_rgba("#f7e9bd"), outline=_rgba("#6a3f2e"))
        add_soft_texture(image, 4204, opacity=24, count=680)
        return image
    if stem == "daily_reward_background":
        d.rectangle((0,0,w,h), fill=_rgba("#4a3154")); d.ellipse((w*.18,h*.07,w*.82,h*.51), fill=_rgba("#e7a46f",150), outline=_rgba("#ffd59c",170), width=6)
        d.rounded_rectangle((w*.10,h*.48,w*.90,h*.90), radius=34, fill=_rgba("#ead6ac"), outline=_rgba("#f7e9bd"), width=8)
        for row in range(2):
            for col in range(4):
                x=w*.19+col*w*.20; y=h*.60+row*h*.13
                d.rounded_rectangle((x-32,y-28,x+32,y+28), radius=10, fill=_rgba("#fff2ce"), outline=_rgba("#bf8854"), width=3)
                d.rectangle((x-16,y-4,x+16,y+18), fill=_rgba("#23a8ad")); d.line((x-14,y-4,x,y-20,x+14,y-4), fill=_rgba("#ffcf64"), width=4)
        d.polygon([(w*.15,h*.49),(w*.85,h*.49),(w*.77,h*.40),(w*.23,h*.40)], fill=_rgba("#c9864f"), outline=_rgba("#ffe0a0"), width=5)
        for angle in range(200, 341, 20):
            x0, y0 = w*.50, h*.32
            x1 = x0 + math.cos(math.radians(angle)) * w*.30
            y1 = y0 + math.sin(math.radians(angle)) * h*.24
            d.line((x0,y0,x1,y1), fill=_rgba("#ffd36b", 80), width=5)
        add_soft_texture(image, 4205, opacity=20, count=620)
        return image
    if stem in {"island_map_background", "map_background"}:
        d.rectangle((0,0,w,h), fill=_rgba("#197487")); d.polygon([(w*.08,h*.86),(w*.28,h*.12),(w*.70,h*.10),(w*.92,h*.84)], fill=_rgba("#d5ad76"), outline=_rgba("#f9e2af"), width=9)
        route=[(w*.20,h*.70),(w*.36,h*.50),(w*.54,h*.61),(w*.70,h*.35),(w*.82,h*.49)]
        d.line(route, fill=_rgba("#d96f50"), width=max(8,w//40), joint="curve")
        for x,y in route: d.ellipse((x-24,y-24,x+24,y+24), fill=_rgba("#f7e9bd"), outline=_rgba("#684532"), width=5)
        for x in range(int(w*.18), int(w*.84), 48):
            d.line((x, h*.18, x + 26, h*.78), fill=_rgba("#9e744f", 32), width=3)
        add_soft_texture(image, 4206, opacity=18, count=520)
        return image
    if stem == "gameplay_background":
        d.rectangle((0,0,w,h), fill=_rgba(theme["deep"])); d.rectangle((0,h*.38,w,h*.55), fill=_rgba(theme["mid"],180))
        d.ellipse((w*.64,h*.10,w*.91,h*.34), fill=_rgba(theme["accent"],150))
        for x in (w*.08,w*.90):
            d.line((x,h*.76,x+(-18 if x>w/2 else 18),h*.30), fill=_rgba(theme["dark"],220), width=max(8,w//35)); d.ellipse((x-45,h*.27,x+55,h*.34), fill=_rgba(theme["light"],160))
        for y in range(int(h*.47), int(h*.75), 34): d.arc((-80,y-22,w+80,y+22),0,180,fill=_rgba(theme["light"],100),width=4)
        d.polygon([(0,h*.80),(w*.14,h*.70),(w*.27,h*.79),(w*.42,h*.68),(w*.58,h*.78),(w*.74,h*.66),(w,h*.78),(w,h),(0,h)], fill=_rgba(theme["dark"], 150))
        for x in (w*.12,w*.86):
            d.ellipse((x-46,h*.29,x+52,h*.36), fill=_rgba(theme["light"], 80))
            d.line((x,h*.34,x + (24 if x < w/2 else -24),h*.62), fill=_rgba(theme["dark"], 180), width=9)
        add_soft_texture(image, 4207 + sum(ord(char) for char in (island_id or "sunny_cove")), opacity=18, count=620)
        return image
    raise ValueError(f"No dedicated screen background renderer for {stem}")


def effect_art(theme, stem: str, size) -> Image.Image:
    image = Image.new("RGBA", size, (0,0,0,0)); d=ImageDraw.Draw(image,"RGBA"); w,h=size; cx,cy=w/2,h/2
    light, accent, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["dark"])
    if stem == "merge_flash":
        d.ellipse((w*.25,h*.25,w*.58,h*.58), fill=_rgba(theme["mid"],190), outline=light, width=max(3,w//24)); d.ellipse((w*.42,h*.38,w*.75,h*.71), fill=_rgba(theme["accent"],190), outline=light, width=max(3,w//24)); d.polygon(star_points(cx,cy,w*.23,w*.10), fill=light)
    elif stem == "merge_ring":
        d.ellipse((w*.18,h*.18,w*.82,h*.82), outline=accent, width=max(6,w//18)); d.ellipse((w*.32,h*.32,w*.68,h*.68), outline=light, width=max(4,w//28));
        for ang in range(0,360,45): d.ellipse((cx+math.cos(math.radians(ang))*w*.42-5,cy+math.sin(math.radians(ang))*h*.42-5,cx+math.cos(math.radians(ang))*w*.42+5,cy+math.sin(math.radians(ang))*h*.42+5), fill=accent)
    elif stem in {"sparkle_small","sparkle_large"}:
        r=w*.28 if stem.endswith("large") else w*.18; d.polygon(star_points(cx,cy,r,r*.22,4), fill=light, outline=accent)
        d.ellipse((w*.72,h*.18,w*.82,h*.28), fill=accent); d.ellipse((w*.18,h*.68,w*.25,h*.75), fill=light)
    elif stem == "score_pop_bg":
        d.polygon([(cx,h*.16),(w*.78,h*.38),(w*.68,h*.83),(w*.32,h*.83),(w*.22,h*.38)], fill=_rgba(theme["dark"],220), outline=accent)
        d.line((cx,h*.65,cx,h*.30), fill=light, width=max(5,w//15)); d.polygon([(cx,h*.23),(w*.88,h*.43),(w*.73,h*.43)], fill=accent)
    elif stem == "order_complete_flash":
        d.ellipse((w*.12,h*.12,w*.88,h*.88), fill=_rgba(theme["mid"],95), outline=light, width=max(4,w//22)); d.line((w*.27,h*.52,w*.44,h*.68,w*.75,h*.30), fill=accent, width=max(7,w//14), joint="curve")
        for ang in range(0,360,60): d.line((cx,cy,cx+math.cos(math.radians(ang))*w*.48,cy+math.sin(math.radians(ang))*h*.48), fill=light, width=max(2,w//35))
    elif stem == "vip_complete_flash":
        d.polygon([(cx,h*.16),(w*.80,h*.34),(w*.70,h*.76),(cx,h*.88),(w*.30,h*.76),(w*.20,h*.34)], fill=_rgba(theme["accent"],215), outline=light)
        d.polygon(star_points(cx,cy,w*.23,w*.11,5), fill=light)
    elif stem == "timer_warning_glow":
        d.ellipse((w*.15,h*.15,w*.85,h*.85), outline=_rgba("#ff5f5f",230), width=max(8,w//16)); d.ellipse((w*.25,h*.25,w*.75,h*.75), fill=_rgba("#ff5f5f",55), outline=light, width=max(3,w//28)); d.line((cx,cy,cx,h*.34), fill=light, width=max(4,w//20)); d.line((cx,cy,w*.68,h*.60), fill=light, width=max(4,w//20))
    elif stem == "to_go_trail_variant":
        for i in range(7):
            x=w*.18+i*w*.10; y=h*.67-i*h*.065; r=max(4,int(w*.045*(1-i*.08))); d.ellipse((x-r,y-r,x+r,y+r), fill=accent if i%2 else light)
        d.polygon([(w*.78,h*.30),(w*.91,h*.41),(w*.78,h*.52)], fill=accent)
    elif stem == "combo_glow":
        for i,col in enumerate((accent,light,_rgba("#ff9d65"))): d.arc((w*(.12+i*.06),h*(.12+i*.06),w*(.88-i*.06),h*(.88-i*.06)), 210, 510, fill=col, width=max(4,w//22))
        d.polygon([(cx,h*.20),(w*.72,h*.45),(w*.58,h*.45),(w*.58,h*.75),(w*.42,h*.75),(w*.42,h*.45),(w*.28,h*.45)], fill=accent)
    elif stem == "win_rays":
        for ang in range(0,360,30): d.polygon([(cx+math.cos(math.radians(ang-4))*w*.17,cy+math.sin(math.radians(ang-4))*h*.17),(cx+math.cos(math.radians(ang))*w*.50,cy+math.sin(math.radians(ang))*h*.50),(cx+math.cos(math.radians(ang+4))*w*.17,cy+math.sin(math.radians(ang+4))*h*.17)], fill=accent)
        d.polygon(star_points(cx,cy,w*.23,w*.11,5), fill=light)
    elif stem == "confetti_strip":
        colors=(accent,light,_rgba("#ff4bb6"),_rgba("#47e1d0"))
        for i in range(12):
            x=w*.06+i*w*.08; y=h*.24+(i%3)*h*.20; d.rounded_rectangle((x,y,x+10,y+h*.20),radius=4,fill=colors[i%4])
    elif stem in {"milestone_glow", "tutorial_highlight_ring"}:
        d.ellipse((w*.17,h*.17,w*.83,h*.83), outline=accent, width=max(7,w//16)); d.ellipse((w*.29,h*.29,w*.71,h*.71), outline=light, width=max(3,w//30)); d.polygon(star_points(cx,cy,w*.20,w*.09,5), fill=accent)
    elif stem == "combo_badge":
        d.polygon([(cx,h*.12),(w*.82,h*.30),(w*.74,h*.78),(cx,h*.90),(w*.26,h*.78),(w*.18,h*.30)], fill=_rgba(theme["dark"],235), outline=accent, width=5); d.polygon(star_points(cx,cy,w*.25,w*.11,5), fill=light)
    else:
        raise ValueError(f"No effect renderer for {stem}")
    return image


def remediated_decor(theme, stem: str, size) -> Image.Image:
    image=Image.new("RGBA",size,(0,0,0,0)); d=ImageDraw.Draw(image,"RGBA"); w,h=size
    if "cloud" in stem:
        d.ellipse((20,80,170,210),fill=_rgba(theme["light"],150)); d.ellipse((90,45,260,220),fill=_rgba(theme["light"],170)); d.ellipse((170,90,300,220),fill=_rgba(theme["light"],140)); return image
    if "boat" in stem:
        d.polygon([(w*.18,h*.70),(w*.82,h*.70),(w*.68,h*.86),(w*.30,h*.86)],fill=_rgba(theme["wood"]),outline=_rgba(theme["light"])); d.line((w*.50,h*.68,w*.50,h*.22),fill=_rgba(theme["dark"]),width=5); d.polygon([(w*.52,h*.25),(w*.76,h*.60),(w*.52,h*.60)],fill=_rgba(theme["light"])); return image
    if "compass" in stem:
        d.ellipse((25,25,w-25,h-25),fill=_rgba(theme["dark"],220),outline=_rgba(theme["light"]),width=5); d.polygon([(w*.50,h*.18),(w*.61,h*.50),(w*.50,h*.82),(w*.39,h*.50)],fill=_rgba(theme["accent"]),outline=_rgba(theme["light"])); return image
    # Menu flourishes are authored tropical leaves/lanterns, not filename badges.
    x=w*.5; d.line((x,h*.92,x+18,h*.20),fill=_rgba(theme["wood"]),width=15)
    for i in range(5): d.ellipse((x-80+i*10,h*.20+i*42,x+18+i*10,h*.30+i*42),fill=_rgba(theme["mid"],210),outline=_rgba(theme["light"],120))
    d.ellipse((x-22,h*.08,x+42,h*.22),fill=_rgba(theme["accent"],200)); return image


def remediated_misc(theme, stem: str, size) -> Image.Image:
    image = Image.new("RGBA", size, (0, 0, 0, 0)); d = ImageDraw.Draw(image, "RGBA")
    w, h = size; light, accent, dark = _rgba(theme["light"]), _rgba(theme["accent"]), _rgba(theme["dark"])
    if stem == "loading_bar_fill":
        d.rounded_rectangle((4, 5, w-4, h-5), radius=max(4,h//3), fill=accent, outline=light, width=2)
        for x in range(12,w,26): d.line((x,8,x+12,h-8), fill=_rgba(theme["light"],90), width=3)
    elif stem == "loading_spinner":
        d.arc((12,12,w-12,h-12), 25, 325, fill=accent, width=max(4,w//12)); d.polygon([(w*.74,h*.17),(w*.88,h*.20),(w*.80,h*.33)], fill=light)
    elif stem == "booster_selected":
        d.rounded_rectangle((5,5,w-5,h-5), radius=18, fill=_rgba(theme["accent"],70), outline=light, width=7); d.polygon([(w*.50,h*.17),(w*.82,h*.50),(w*.50,h*.83),(w*.18,h*.50)], outline=accent, width=4)
    elif stem == "route_line":
        d.line((0,h*.72,w*.24,h*.32,w*.52,h*.66,w,h*.24), fill=accent, width=max(6,h//3), joint="curve")
    elif stem.startswith("route_marker"):
        d.ellipse((6,6,w-6,h-6), fill=light, outline=dark, width=4)
        if stem.endswith("current"): d.polygon(star_points(w/2,h/2,min(w,h)*.30,min(w,h)*.12,5), fill=accent)
        elif stem.endswith("complete"): d.line((w*.26,h*.52,w*.45,h*.70,w*.76,h*.30), fill=accent, width=max(4,w//10))
        else: d.ellipse((w*.37,h*.37,w*.63,h*.63), fill=accent)
    elif stem.startswith("level_node"):
        d.ellipse((6,6,w-6,h-6), fill=_rgba(theme["dark"],230), outline=accent, width=5)
        if stem.endswith("locked"): d.rounded_rectangle((w*.30,h*.45,w*.70,h*.76), radius=5, fill=accent); d.arc((w*.36,h*.24,w*.64,h*.58),180,360,fill=light,width=4)
        elif stem.endswith("current"): d.polygon(star_points(w/2,h/2,min(w,h)*.29,min(w,h)*.12,5), fill=light)
        elif stem.endswith("completed"): d.line((w*.25,h*.52,w*.44,h*.70,w*.76,h*.29), fill=accent, width=max(4,w//10))
        elif stem.endswith("milestone"): d.polygon(star_points(w/2,h/2,min(w,h)*.30,min(w,h)*.13,6), fill=accent)
        elif stem.endswith("finale"): d.polygon([(w*.25,h*.65),(w*.36,h*.32),(w*.50,h*.52),(w*.64,h*.32),(w*.75,h*.65)], fill=accent)
        else: d.ellipse((w*.36,h*.36,w*.64,h*.64), fill=light)
    elif stem.startswith("level_connector"):
        d.line((0,h*.50,w,h*.50), fill=accent if stem.endswith("complete") else light, width=max(5,h//3))
        for x in range(10,w,24): d.ellipse((x-3,h*.50-3,x+3,h*.50+3), fill=dark)
    elif stem == "island_complete_ribbon":
        d.polygon([(0,h*.22),(w*.16,h*.22),(w*.27,h*.50),(w*.16,h*.78),(0,h*.78),(w*.10,h*.50)], fill=accent, outline=light)
        d.polygon([(w*.84,h*.22),(w,h*.22),(w*.90,h*.50),(w,h*.78),(w*.84,h*.78),(w*.73,h*.50)], fill=accent, outline=light)
        d.polygon([(w*.18,h*.22),(w*.82,h*.22),(w*.74,h*.82),(w*.26,h*.82)], fill=dark, outline=accent)
    elif stem in {"daily_day_current", "daily_day_claimed"}:
        d.rounded_rectangle((6,6,w-6,h-6), radius=16, fill=_rgba(theme["mid"],220), outline=accent, width=5)
        if stem.endswith("claimed"): d.line((w*.24,h*.52,w*.44,h*.70,w*.76,h*.30), fill=light, width=max(5,w//11))
        else: d.polygon(star_points(w/2,h/2,min(w,h)*.27,min(w,h)*.12,5), fill=accent, outline=light)
    elif stem == "tutorial_hand":
        d.ellipse((w*.35,h*.42,w*.70,h*.88), fill=light, outline=accent, width=4)
        d.rounded_rectangle((w*.38,h*.16,w*.52,h*.60), radius=9, fill=light, outline=accent, width=4)
        for x in (w*.53,w*.64): d.line((x,h*.48,x,h*.28), fill=light, width=10)
    else:
        raise ValueError(f"No misc renderer for {stem}")
    return image


def render(rel: str, group: str, stem: str, island_id: str | None):
    theme = THEMES.get(island_id or "sunny_cove", THEMES["sunny_cove"])
    size = dimensions_for(stem, group)
    if stem in {"app_icon", "splash_logo", "logo_beach_cocktails_merge", "brand_wordmark_small", "legal_logo_mark"}:
        return owner_logo_variant(stem)
    if island_id and stem == "gameplay_table": return remediated_table_image(theme, island_id)
    if island_id and stem == "world_icon": return remediated_island_icon(theme, island_id)
    if not island_id and stem in THEMES: return remediated_island_icon(theme, stem)
    if island_id and stem in {"map_background", "gameplay_background"}: return remediated_screen_background(theme, stem, size, island_id)
    if stem in {"splash_background", "main_menu_background", "world_map_background", "shop_background", "daily_reward_background", "island_map_background", "gameplay_background"}:
        return remediated_screen_background(theme, stem, size, island_id)
    if island_id and stem in {"gameplay_table_shadow", "table_edge_overlay", "launch_zone"}:
        if stem == "gameplay_table_shadow": return table_shadow(theme)
        if stem == "table_edge_overlay": return edge_overlay(theme)
        return launch_zone(theme)
    if island_id and stem.startswith("decor_"): return decor(theme, stem.split("_")[-1], island_id)
    if stem in STATEFUL_STEMS: return stateful_art(theme, stem, size)
    if stem in SCREEN_COMPONENT_STEMS: return screen_component(theme, stem, size)
    if stem in SEMANTIC_STEMS: return semantic_icon(theme, stem, size)
    if stem in REWARD_STEMS: return reward_art(theme, stem, size)
    if stem in EFFECT_STEMS: return effect_art(theme, stem, size)
    if stem in {"world_clouds_front", "world_clouds_back", "world_map_boat", "world_map_compass", "main_menu_decor_left", "main_menu_decor_right"}:
        return remediated_decor(theme, stem, size)
    if stem in {"loading_bar_fill", "loading_spinner", "booster_selected", "route_line", "route_marker", "route_marker_current", "route_marker_complete", "level_node_locked", "level_node_unlocked", "level_node_current", "level_node_completed", "level_node_milestone", "level_node_finale", "level_connector", "level_connector_complete", "island_complete_ribbon", "daily_day_current", "daily_day_claimed", "tutorial_hand"}:
        return remediated_misc(theme, stem, size)
    if stem in REUSABLE_BASE_STEMS:
        return reusable_base(theme, stem, size, group)
    raise ValueError(f"No explicit renderer for final asset: {group}/{stem}")


if __name__ == "__main__":
    generate()
