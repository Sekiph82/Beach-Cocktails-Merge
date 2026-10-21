#!/usr/bin/env python3
"""Assemble and validate BCM V09 store-media review candidates.

All screenshot pixels come from existing genuine Godot runtime captures or
existing captioned compositions. Outputs are explicitly non-device candidates.
"""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

from PIL import Image, ImageOps, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
MEDIA = ROOT / "docs/release/store_media"
OUT = MEDIA / "submission_candidates_v09"
GOOGLE = OUT / "google_play"
SITE = MEDIA / "site_staging_v09"
APPLE = OUT / "apple_iphone"

ASSETS = [
    ("google_play/icon_512.png", "icons_v04/google_play_icon_candidate_512_v04.png", "play_icon", (512, 512), "RGBA"),
    ("google_play/feature_graphic_1024x500.png", "google_play_feature_graphic_v02.png", "feature_graphic", (1024, 500), "RGB"),
    ("google_play/01_home.png", "compositions_v03/01_home_google_play_candidate.png", "home", (1080, 1920), "RGB"),
    ("google_play/02_world_map.png", "compositions_v03/02_world_map_google_play_candidate.png", "world_map", (1080, 1920), "RGB"),
    ("google_play/03_island_map.png", "compositions_v03/03_island_map_google_play_candidate.png", "island_map", (1080, 1920), "RGB"),
    ("google_play/04_gameplay_current.png", "compositions_v07/04_gameplay_google_play_candidate_v07.png", "gameplay", (1080, 1920), "RGB"),
    ("google_play/05_live_merge.png", "compositions_v03/05_live_merge_google_play_candidate.png", "live_merge", (1080, 1920), "RGB"),
    ("google_play/06_gameplay_to_go.png", "compositions_v03/04_gameplay_google_play_candidate.png", "gameplay_to_go", (1080, 1920), "RGB"),
]
CAPTURE_METADATA = {
    "google_play/01_home.png": "captures_v03/desktop_candidate_01_main_menu.json",
    "google_play/02_world_map.png": "captures_v03/desktop_candidate_02_campaign.json",
    "google_play/03_island_map.png": "captures_v03/desktop_candidate_03_campaign.json",
    "google_play/04_gameplay_current.png": "compositions_v07/04_gameplay_google_play_candidate_v07.json",
    "google_play/05_live_merge.png": "captures_v03/desktop_candidate_08_campaign.json",
    "google_play/06_gameplay_to_go.png": "captures_v03/desktop_candidate_04_campaign.json",
}

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def copy_assets() -> list[dict]:
    rows = []
    for rel_out, rel_src, kind, expected_size, expected_mode in ASSETS:
        source, target = MEDIA / rel_src, OUT / rel_out
        if not source.is_file():
            raise ValueError(f"missing source asset: {source.relative_to(ROOT)}")
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            if sha256(target) != sha256(source):
                raise ValueError(f"candidate already exists with different bytes; review before replacement: {target.relative_to(ROOT)}")
        else:
            shutil.copyfile(source, target)
        with Image.open(target) as im:
            im.load()
            if im.size != expected_size or im.mode != expected_mode:
                raise ValueError(f"{rel_out}: expected {expected_size}/{expected_mode}, got {im.size}/{im.mode}")
        rows.append({
            "path": rel_out.replace("\\", "/"),
            "source_path": rel_src.replace("\\", "/"),
            "kind": kind,
            "width": expected_size[0],
            "height": expected_size[1],
            "color_mode": expected_mode,
            "bytes": target.stat().st_size,
            "sha256": sha256(target),
            "source_sha256": sha256(source),
            "source_capture_identity": _capture_identity(rel_out),
            "capture_classification": "DESKTOP_GAMEPLAY_CANDIDATE" if kind in {"gameplay", "gameplay_to_go", "live_merge"} else "MARKETING_OR_MENU_CANDIDATE",
            "device_review_status": "DEVICE_REVIEW_PENDING",
            "submission_status": "CANDIDATE_ONLY_NOT_STORE_READY",
        })
    return rows

def _capture_identity(output_path: str) -> dict:
    metadata_rel = CAPTURE_METADATA.get(output_path)
    if not metadata_rel:
        return {"status": "MARKETING_ASSET_NOT_GAME_CAPTURE"}
    metadata_path = MEDIA / metadata_rel
    capture = json.loads(metadata_path.read_text(encoding="utf-8"))
    source_capture = ROOT / capture.get("source_capture", "") if capture.get("source_capture") else MEDIA / str(capture.get("path", "")).removeprefix("res://docs/release/store_media/")
    return {
        "metadata_path": str(metadata_path.relative_to(ROOT)).replace("\\", "/"),
        "metadata_sha256": sha256(metadata_path),
        "source_capture_path": str(source_capture.relative_to(ROOT)).replace("\\", "/"),
        "source_capture_sha256": sha256(source_capture),
        "source_head": capture.get("source_head", "unknown"),
        "runtime_version": capture.get("runtime_version", "unknown"),
        "runtime_view": capture.get("runtime_view", "unknown"),
        "classification": capture.get("classification", capture.get("capture_classification", "unknown")),
        "device_review_status": capture.get("device_review_status", "unknown"),
        "tutorial_status": capture.get("tutorial_status", "not_recorded"),
        "store_device_capture": capture.get("store_device_capture", False),
        "content_modified": capture.get("content_modified", False),
    }

def prepare_sites() -> dict:
    sources = {
        "en": {"privacy.html": MEDIA / "privacy_policy_staging_en.html", "support.html": MEDIA / "support_staging_en.html"},
        "tr": {"privacy.html": MEDIA / "privacy_policy_staging_tr.html", "support.html": MEDIA / "support_staging_tr.html"},
    }
    result = {}
    for lang, pages in sources.items():
        folder = SITE / lang
        folder.mkdir(parents=True, exist_ok=True)
        (folder / "privacy.html").write_bytes(pages["privacy.html"].read_bytes())
        (folder / "support.html").write_bytes(pages["support.html"].read_bytes())
        title = "Beach Cocktails Merge — Local staging only" if lang == "en" else "Beach Cocktails Merge — Yalnızca yerel taslak"
        notice = "Unpublished review draft. Do not use these local files as public store URLs." if lang == "en" else "Yayımlanmamış inceleme taslağı. Bu yerel dosyaları herkese açık mağaza URL'si olarak kullanmayın."
        (folder / "index.html").write_text(
            f'<!doctype html><html lang="{lang}"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
            f'<title>{title}</title><main><h1>{title}</h1><p>{notice}</p>'
            '<ul><li><a href="privacy.html">Privacy / Gizlilik</a></li><li><a href="support.html">Support / Destek</a></li></ul></main></html>',
            encoding="utf-8",
        )
        result[lang] = {name: {"bytes": (folder / name).stat().st_size, "sha256": sha256(folder / name)} for name in ("index.html", "privacy.html", "support.html")}
    return result

def make_contact_sheet() -> dict:
    paths = [OUT / item[0] for item in ASSETS]
    cell_w, cell_h, label_h = 320, 430, 34
    sheet = Image.new("RGB", (cell_w * 3, (cell_h + label_h) * 3 + 46), "#15384b")
    draw = ImageDraw.Draw(sheet)
    draw.text((12, 12), "OWNER REVIEW ONLY | DESKTOP SOURCES | DEVICE REVIEW PENDING", fill="#fff0c8")
    for i, p in enumerate(paths):
        with Image.open(p) as original:
            thumb = ImageOps.contain(original.convert("RGB"), (cell_w - 16, cell_h - 16))
        x, y = (i % 3) * cell_w, 46 + (i // 3) * (cell_h + label_h)
        sheet.paste(thumb, (x + (cell_w - thumb.width)//2, y + (cell_h - thumb.height)//2))
        draw.text((x + 8, y + cell_h), p.name, fill="#fff0c8")
    target = MEDIA / "submission_review_contact_sheet_v09.png"
    sheet.save(target, format="PNG", optimize=True)
    return {"path": str(target.relative_to(ROOT)), "width": sheet.width, "height": sheet.height, "bytes": target.stat().st_size, "sha256": sha256(target)}

def prepare_apple_capture_gate() -> dict:
    APPLE.mkdir(parents=True, exist_ok=True)
    readme = APPLE / "CAPTURE_PENDING.md"
    readme.write_text(
        "# Apple iPhone screenshot capture gate\n\n"
        "Status: `CAPTURE_PENDING`. No physical iPhone capture or signed iOS release UI is available. "
        "The existing 720x1280 desktop game captures and 1080x1920 desktop-origin marketing compositions "
        "are not represented as iPhone screenshots and are not copied into an Apple upload set.\n\n"
        "Apple's current App Store Connect help lists 1179x2556 portrait as an accepted iPhone Dynamic Island medium display size. "
        "Capture the exact release UI on a supported physical iPhone and confirm the app's device support before submission.\n",
        encoding="utf-8",
    )
    return {"status": "CAPTURE_PENDING", "target_size_px": [1179, 2556], "readme": str(readme.relative_to(ROOT)), "sha256": sha256(readme)}

def validate(rows: list[dict], sites: dict) -> dict:
    problems = []
    google = [r for r in rows if r["path"].startswith("google_play/")]
    icon = next(r for r in google if r["kind"] == "play_icon")
    feature = next(r for r in google if r["kind"] == "feature_graphic")
    screens = [r for r in google if r["kind"] not in {"play_icon", "feature_graphic"}]
    game_screens = [r for r in screens if r["kind"] in {"gameplay", "gameplay_to_go", "live_merge"}]
    if icon["width"] != 512 or icon["height"] != 512 or icon["color_mode"] != "RGBA" or icon["bytes"] > 1024 * 1024:
        problems.append("Google Play icon must be 512x512 32-bit PNG with alpha and <=1024KB")
    if feature["width"] != 1024 or feature["height"] != 500 or feature["color_mode"] != "RGB":
        problems.append("Google Play feature graphic must be 1024x500 24-bit PNG/JPEG without alpha")
    if len(screens) < 2 or len(game_screens) < 2:
        problems.append("Google Play needs at least two distinct actual gameplay screenshots in this candidate set")
    for r in screens:
        if r["width"] != 1080 or r["height"] != 1920 or r["color_mode"] != "RGB":
            problems.append(f"invalid Google Play phone screenshot candidate: {r['path']}")
        if r["bytes"] > 8 * 1024 * 1024:
            problems.append(f"Google Play screenshot exceeds 8MB: {r['path']}")
    if any("daily" in r["path"].lower() for r in rows):
        problems.append("Daily Rewards must not be included in this V09 candidate set")
    for r in rows:
        actual = OUT / r["path"]
        source = MEDIA / r["source_path"]
        with Image.open(actual) as im:
            im.verify()
        if sha256(actual) != r["sha256"] or sha256(source) != r["source_sha256"]:
            problems.append(f"SHA-256 mismatch: {r['path']}")
        if actual.stat().st_size != r["bytes"]:
            problems.append(f"file size changed after inventory: {r['path']}")
    if set(sites) != {"en", "tr"} or any(set(pages) != {"index.html", "privacy.html", "support.html"} for pages in sites.values()):
        problems.append("EN/TR local staging site pages are incomplete")
    for lang in ("en", "tr"):
        index = (SITE / lang / "index.html").read_text(encoding="utf-8")
        for relative in ("privacy.html", "support.html"):
            if f'href="{relative}"' not in index or not (SITE / lang / relative).is_file():
                problems.append(f"broken local staging link: {lang}/{relative}")
    links = json.loads((ROOT / "data/ui/settings_links.json").read_text(encoding="utf-8"))
    if set(links) != {"schema_version", "privacy_policy_url", "support_url"} or links.get("schema_version") != 1:
        problems.append("in-game settings-link config schema changed unexpectedly")
    public_urls = {k: str(links.get(k, "")) for k in ("privacy_policy_url", "support_url")}
    for field, url in public_urls.items():
        if url and not re.fullmatch(r"https://[^\s/]+(?:/[^\s]*)?", url):
            problems.append(f"{field} must be a public HTTPS URL if supplied")
    ads = json.loads((ROOT / "data/campaign/ads_provider_policy.json").read_text(encoding="utf-8"))
    placements = ads.get("placements", {})
    ads_off = bool(placements) and all(not bool(value.get("enabled", False)) for value in placements.values())
    if len(placements) != 7 or not ads_off or ads.get("default_enabled") is not False:
        problems.append("future AdMob protection failed: expected seven disabled placements and default_enabled=false")
    catalog = json.loads((ROOT / "data/campaign/store_catalog.json").read_text(encoding="utf-8"))
    purchases_off = all(not bool(product.get("buyable", False)) for product in catalog.get("products", []))
    if not catalog.get("products") or not purchases_off:
        problems.append("release protection failed: store products must remain nonbuyable")
    preset_text = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    ios_preset = preset_text.split("[preset.2]", 1)[1].split("[preset.2.options]", 1)[0]
    ios_options = preset_text.split("[preset.2.options]", 1)[1].split("[preset.3]", 1)[0]
    if 'name="iOS Store Candidate (NOT SHIPPING)"' not in ios_preset or 'export_path=""' not in ios_preset:
        problems.append("iOS export preset is no longer marked NOT SHIPPING with no export destination")
    if ('application/bundle_identifier="com.sekiph82.beachcocktails"' not in ios_options
            or 'application/app_store_team_id=""' not in ios_options
            or 'application/export_project_only=true' not in ios_options
            or 'application/provisioning_profile_uuid_release=""' not in ios_options):
        problems.append("iOS dry-run identity/team fields do not match the approved bundle and unsigned state")
    store_record = {
        "apple": {"name": "Beach Cocktails Merge", "bundle_id": "com.sekiph82.beachcocktails", "sku": "BCM-IOS-2026-001", "primary_language": "English (U.S.)", "platform": "iOS", "approval": "OWNER_APPROVED_V10", "portal_record": "NOT_CREATED_SESSION_UNAVAILABLE"},
        "google_play": {"package_id": "com.sekiph82.beachcocktails", "approval": "OWNER_APPROVAL_REQUIRED", "production_signing": "NOT_CONFIGURED"},
    }
    listing = {
        "apple_en_us": {"name": "Beach Cocktails Merge", "subtitle": "Merge drinks, explore islands", "title_limit": 30, "subtitle_limit": 30},
        "google_play_en_us": {"title": "Beach Cocktails Merge", "short_description": "Merge drinks, complete To-Go orders and explore tropical islands.", "title_limit": 30, "short_description_limit": 80},
    }
    if len(listing["apple_en_us"]["name"]) > 30 or len(listing["apple_en_us"]["subtitle"]) > 30:
        problems.append("Apple EN-US title/subtitle exceeds current field limits")
    if len(listing["google_play_en_us"]["title"]) > 30 or len(listing["google_play_en_us"]["short_description"]) > 80:
        problems.append("Google Play EN-US title/short description exceeds field limits")
    unresolved_fields = ["publisher_legal_identity", "privacy_contact", "support_contact", "retention_and_deletion", "public_https_privacy_url", "public_https_support_url", "signed_package_data_inventory", "age_rating_answers", "store_owner_review", "physical_device_visual_review"]
    return {
        "validator_status": "PASS_CANDIDATE_VALIDATION" if not problems else "BLOCKED_CANDIDATE_VALIDATION",
        "store_readiness": "BLOCKED_DEVICE_VISUAL_REVIEW" if not problems else "BLOCKED_CANDIDATE_VALIDATION",
        "problems": problems,
        "google_play": {"screenshots": len(screens), "actual_gameplay_screenshots": len(game_screens), "icon": icon, "feature_graphic": feature},
        "apple_iphone": {"status": "CAPTURE_PENDING", "reason": "No physical iPhone or signed iOS build capture is present; desktop-origin images are not packaged as iPhone screenshots."},
        "owner_fields_unresolved": unresolved_fields + ["Apple team confirmation in visible signed-in portal", "App Store Connect user access level", "Apple account agreement gate state", "Play developer account/device verification", "Google Play production signing identity"],
        "daily_rewards_required": False,
        "privacy_and_support": "LOCAL_STAGING_ONLY; PUBLIC_HTTPS_AND_OWNER_REVIEW_PENDING",
        "ads": "FUTURE_ADMOB_SOURCE_PRESERVED; ALL_PLACEMENTS_DISABLED; NO_LIVE_AD_OR_CONSENT_CLAIM",
        "iap": "NONBUYABLE; NO_LIVE_PURCHASE_CLAIM",
        "settings_links": {"urls": public_urls, "in_game_links_enabled": all(bool(v) for v in public_urls.values())},
        "future_ad_placements_disabled": ads_off,
        "products_nonbuyable": purchases_off,
        "ios_export_preset_dry_run": "CONSISTENT_UNSIGNED_NOT_SHIPPING" if not problems else "CHECK_REQUIRED",
        "ios_export_preset_verification_mode": "STATIC_CONFIGURATION_ONLY; NO_EXPORT_RUN",
        "shipping_identity": store_record,
        "listing_metadata_checks": listing,
        "privacy_https_gate": "BLOCKED_OWNER_PUBLIC_URL" if not public_urls["privacy_policy_url"] else "HTTPS_FORMAT_VALIDATED",
        "support_https_gate": "BLOCKED_OWNER_PUBLIC_URL" if not public_urls["support_url"] else "HTTPS_FORMAT_VALIDATED",
        "apple_record_gate": "BLOCKED_SESSION_UNAVAILABLE",
        "builds_or_pck_aab_tests_rerun": False,
        "portal_action_status": "APPLE_SESSION_NOT_ACCESSIBLE_TO_CODEX; no portal tab or authorized browser session was available",
    }

def main() -> int:
    rows = copy_assets()
    sites = prepare_sites()
    contact = make_contact_sheet()
    apple_gate = prepare_apple_capture_gate()
    report = validate(rows, sites)
    report.update({"schema_version": 1, "task": "BCM-M34-006-007-V09", "assets": rows, "staging_site": sites, "contact_sheet": contact, "apple_capture_gate": apple_gate})
    OUT.mkdir(parents=True, exist_ok=True)
    report_path = OUT / "submission_manifest_v09.json"
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps({"validator_status": report["validator_status"], "store_readiness": report["store_readiness"], "asset_count": len(rows), "screenshots": report["google_play"]["screenshots"], "gameplay_screenshots": report["google_play"]["actual_gameplay_screenshots"], "apple_iphone": report["apple_iphone"]["status"], "manifest": str(report_path.relative_to(ROOT))}, indent=2))
    return 0 if report["validator_status"] == "PASS_CANDIDATE_VALIDATION" else 1

if __name__ == "__main__":
    sys.exit(main())
