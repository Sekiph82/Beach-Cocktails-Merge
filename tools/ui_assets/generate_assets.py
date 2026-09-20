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


def generic_element(theme, stem: str, size, group: str) -> Image.Image:
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
        label = stem.replace("_", " ").upper()
        fill = theme["light"] if "danger" not in lower else "#f08b70"
        if "disabled" in lower or "locked" in lower:
            fill = "#8093a0"
        return rounded_panel(size, fill=fill, rim="#ffffff", stroke=theme["dark"], shadow="#071526", radius=max(10, min(w, h)//6), label=label if "button" in lower else None, accent=theme["accent"])
    # Decorative, non-empty fallback: a compact illustrated badge rather than a blank placeholder.
    d.rounded_rectangle((5, 5, w-5, h-5), radius=max(8, min(w, h)//5), fill=dark + (225,), outline=accent + (255,), width=max(2, min(w, h)//20))
    d.ellipse((w*.25, h*.18, w*.75, h*.68), fill=accent + (170,))
    text_center(d, (w*.1, h*.58, w*.9, h*.95), stem.replace("_", " ").upper(), light, max(10, min(w, h)//8))
    return image


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
    return generic_element(theme, stem, size, group)


def write_readme():
    text = """# UI Assets V1 production library

This branch-only library is generated for the `ui-assets` visual-production stream. It does not replace or modify runtime assets.

## Structure

- `brand/`, `ui/`: reusable brand and interface elements.
- `campaign/`: world-map, reusable progression UI, and ten island packs.
- `screens/`: splash, menu, pre-level, results, shop, settings, tutorial, and social screens.
- `effects/`: restrained feedback overlays.
- `tables/`: frozen common geometry JSON, silhouette mask, and edge overlay masters.
- `source/`: generator provenance and style-reference notes only.

## Generation and export

`tools/ui_assets/generate_assets.py` creates original raster art with Pillow using a deterministic seed, shared typography/material helpers, and the ten locked theme palettes. The owner-supplied logo is copied from the local source after checkerboard-background removal only; no logo artwork is regenerated. The table skins are rasterized from one shared 720x1280 alpha polygon defined by `tables/table_geometry_v1.json`.

`tools/ui_assets/validate_assets.py` checks manifest coverage, PNG decoding, dimensions, alpha expectations, table canvas/mask equality, front-corner/rear-width geometry, untouched protected paths, and V01 scope restrictions.

The four contact sheets are audit evidence, not runtime integration. Runtime table/play-area and logo replacement remain deferred to UIA-M14.
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
    (OUT / "source" / "generation_method.txt").write_text("Deterministic Pillow generation; original procedural gradients, material textures, icons, panels, and themed table skins. Canonical logo is owner-supplied with technical checkerboard alpha cleanup only.\n", encoding="utf-8")

    catalog = build_asset_catalog()
    for rel, group, stem, island_id in catalog:
        save(render(rel, group, stem, island_id), OUT / rel)
    write_readme()

    table_items = []
    island_items = []
    for island_id, theme in THEMES.items():
        table_items.append((theme["name"], Image.open(OUT / "campaign" / "islands" / island_id / "gameplay_table.png")))
        island_items.append((theme["name"], Image.open(OUT / "campaign" / "islands" / island_id / "map_background.png")))
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

    manifest = []
    pngs = sorted(OUT.rglob("*.png"))
    for path in pngs:
        rel = path.relative_to(ROOT).as_posix()
        image = Image.open(path)
        island = next((key for key in THEMES if f"/islands/{key}/" in f"/{rel}"), None)
        is_table = path.name in {"gameplay_table.png", "gameplay_table_shadow.png", "table_edge_overlay.png"} or "table_" in path.name
        manifest.append({
            "path": rel,
            "category": "evidence" if path.name.startswith("CONTACT_SHEET") else path.parent.relative_to(OUT).as_posix(),
            "intended_screen_use": "audit contact sheet" if path.name.startswith("CONTACT_SHEET") else path.stem.replace("_", " "),
            "dimensions": {"width": image.width, "height": image.height},
            "alpha_expected": image.mode in {"RGBA", "LA"},
            "island_id": island,
            "table_geometry_version": 1 if is_table else None,
            "generation_source_method": "owner-supplied canonical logo with technical alpha cleanup and proportional size variant only" if path.name in {"app_icon.png", "splash_logo.png", "logo_beach_cocktails_merge.png", "brand_wordmark_small.png", "legal_logo_mark.png"} else "deterministic original Pillow procedural generation",
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


if __name__ == "__main__":
    generate()
