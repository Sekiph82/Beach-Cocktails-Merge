# Beach Cocktails Merge — Full Visual Asset Manifest V1

Branch scope: `ui-assets` only.

All new full-set visual production belongs under `assets/ui_assets/`. Existing canonical assets under `assets/cocktails/`, `assets/environment/`, `assets/effects/`, and `assets/ui/` are reference material and must not be overwritten during this production pass.

## Art direction

Bright polished tropical casual-mobile style, premium but readable, playful without becoming toy-like. Consistent perspective, lighting language, bevel/rim treatment, icon stroke weight, panel materials, and legibility across the entire product.

Target base viewport: **720 × 1280 portrait**.

Deliver raster production assets as PNG. Preserve transparency where the element is not a full-screen background. SVG/source files may be retained under `assets/ui_assets/source/` when useful, but every runtime-target asset must also have a PNG export.

Do not use watermarked, scraped, or third-party copyrighted game art.

---

## A. Brand and splash

### Owner-supplied canonical game logo — DO NOT REDESIGN

The owner has supplied the final Beach Cocktails Merge logo locally at:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge\assets\beach cocktails merge logo.png`

This exact artwork is the canonical game logo. Codex must copy/export it into the new asset library as:

`assets/ui_assets/brand/logo_beach_cocktails_merge.png`

Rules:
- do not redraw, reinterpret, restyle, regenerate, recolor, or replace the logo;
- preserve the exact BEACH COCKTAILS MERGE lettering, cocktail illustration, tropical leaves/flowers, palm, waves, colors, and composition;
- only non-destructive technical cleanup is permitted when required for runtime use: correct alpha/transparency, trim accidental empty padding, and create size variants from the same artwork;
- if the local source contains a baked checkerboard instead of true alpha, remove only the checkerboard/background and preserve the logo artwork exactly;
- all new screen mockups/contact sheets that display the game logo must use this canonical owner-supplied logo;
- the current runtime on-screen logo must later be replaced by this canonical logo during the separately authorized UIA-M14 integration step.

`assets/ui_assets/brand/`
- app_icon.png
- splash_logo.png
- logo_beach_cocktails_merge.png
- brand_badge_small.png
- brand_wordmark_small.png
- legal_logo_mark.png

`assets/ui_assets/screens/splash/`
- splash_background.png
- loading_bar_frame.png
- loading_bar_fill.png
- loading_spinner.png
- loading_cocktail_icon.png
- loading_tip_panel.png

## B. Global UI system

`assets/ui_assets/ui/global/`
- panel_generic_large.png
- panel_generic_medium.png
- panel_generic_small.png
- popup_frame.png
- tooltip_frame.png
- divider_gold.png
- tab_active.png
- tab_inactive.png
- button_primary.png
- button_secondary.png
- button_danger.png
- button_disabled.png
- button_locked.png
- button_small.png
- button_icon_round.png
- close_x.png
- back_arrow.png
- next_arrow.png
- previous_arrow.png
- home_icon.png
- settings_icon.png
- play_icon.png
- pause_icon.png
- restart_icon.png
- map_icon.png
- info_icon.png
- help_icon.png
- check_icon.png
- lock_icon.png
- new_badge.png
- complete_badge.png
- current_badge.png
- milestone_badge.png
- finale_badge.png
- notification_dot.png
- new_content_badge.png
- reward_ready_badge.png
- sale_badge_small.png
- daily_ready_badge.png

## C. Currency, stars, rewards, chests

`assets/ui_assets/ui/rewards/`
- coin_icon.png
- gem_icon.png
- star_empty.png
- star_filled.png
- star_large_empty.png
- star_large_filled.png
- reward_frame_small.png
- reward_frame_large.png
- small_chest_closed.png
- small_chest_open.png
- big_chest_closed.png
- big_chest_open.png
- premium_chest_closed.png
- premium_chest_open.png
- reward_glow.png

## D. Boosters

`assets/ui_assets/ui/boosters/`
- booster_time.png
- booster_hammer.png
- booster_upgrade.png
- booster_shuffle.png
- booster_count_badge.png
- booster_slot.png
- booster_locked.png
- booster_selected.png

## E. Main menu

`assets/ui_assets/screens/main_menu/`
- main_menu_background.png
- main_menu_logo_frame.png
- main_menu_play_button.png
- main_menu_world_map_button.png
- main_menu_shop_button.png
- main_menu_settings_button.png
- main_menu_daily_button.png
- profile_frame.png
- coin_counter_panel.png
- gem_counter_panel.png
- main_menu_decor_left.png
- main_menu_decor_right.png

## F. World map

`assets/ui_assets/campaign/world_map/`
- world_map_background.png
- world_map_title_panel.png
- route_line.png
- route_marker.png
- route_marker_current.png
- route_marker_complete.png
- island_name_panel.png
- island_locked_overlay.png
- world_clouds_front.png
- world_clouds_back.png
- world_map_compass.png
- world_map_boat.png

World-map island icons:
- sunny_cove.png
- tiki_island.png
- azure_bay.png
- coconut_beach.png
- sunset_island.png
- party_beach.png
- frozen_paradise.png
- volcano_bay.png
- billionaire_island.png
- final_island.png

Locked/completed/current visual states should be generated by reusable overlays/tint where possible rather than tripling all island art.

## G. Per-island environment packs

Each island gets the same asset structure under:
`assets/ui_assets/campaign/islands/<island_id>/`

Required files for **every one of the 10 islands**:
- map_background.png
- map_title.png
- world_icon.png
- gameplay_background.png
- gameplay_table.png
- gameplay_table_shadow.png
- launch_zone.png
- table_edge_overlay.png
- decor_left.png
- decor_right.png
- decor_back.png
- theme_badge.png
- complete_badge.png

Islands:
1. sunny_cove
2. tiki_island
3. azure_bay
4. coconut_beach
5. sunset_island
6. party_beach
7. frozen_paradise
8. volcano_bay
9. billionaire_island
10. final_island

### Island visual identities

**Sunny Cove** — bright teak, turquoise resin accents, white beach-club trim, clear tropical daylight.

**Tiki Island** — dark teak, bamboo structure, carved tiki motifs, warm torch/golden accents.

**Azure Bay** — white yacht-deck cues, aqua/blue resin, clean marina luxury, bright water reflections.

**Coconut Beach** — natural pale palm/coconut wood, woven fibers, coconut-shell details, relaxed organic palette.

**Sunset Island** — mahogany, amber resin, coral/pink sunset reflections, elegant warm twilight.

**Party Beach** — dark lacquer/wood, neon cyan-magenta-lime details, club lighting, energetic but board-readable.

**Frozen Paradise** — frosted glass/ice-inspired surface language, pale blue/white crystalline details, tropical-frozen contrast.

**Volcano Bay** — obsidian/basalt surface, restrained lava seams, hot ember accents, no visual noise in gameplay zone.

**Billionaire Island** — dark walnut, white marble, gold trim, ultra-luxury resort language.

**Final Island** — exotic blackwood, mother-of-pearl/turquoise inlay, premium gold detailing; visual climax while retaining the exact canonical table silhouette.

### Mandatory table rule

All ten `gameplay_table.png` files must use **exactly the same outer silhouette, perspective geometry, table footprint, rear-edge position, and front-corner positions**. Only material, color, trim, inlay, surface pattern, and island-theme decoration may change.

See `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V1.md`.

## H. Island-map reusable UI

`assets/ui_assets/campaign/island_map/`
- level_node_locked.png
- level_node_unlocked.png
- level_node_current.png
- level_node_completed.png
- level_node_milestone.png
- level_node_finale.png
- level_connector.png
- level_connector_complete.png
- star_small_empty.png
- star_small_filled.png
- milestone_chest_marker.png
- finale_crown.png
- map_scroll_top_decor.png
- map_scroll_bottom_decor.png
- island_summary_panel.png
- stars_counter_panel.png
- next_milestone_panel.png

## I. Level pre-start

`assets/ui_assets/screens/prelevel/`
- prelevel_panel.png
- level_number_badge.png
- timer_icon.png
- timer_panel_small.png
- order_slot.png
- vip_badge.png
- vip_reward_slot.png
- booster_selector_panel.png
- button_play_level.png
- button_close_prelevel.png

## J. Campaign gameplay HUD additions

`assets/ui_assets/ui/gameplay/`
- timer_panel.png
- timer_icon.png
- level_label_panel.png
- pause_button.png
- vip_badge.png
- vip_reward_frame.png
- timer_warning_glow.png

Existing gameplay panels/cocktails remain reference assets in the original folders until integration.

## K. Feedback/effects

`assets/ui_assets/effects/`
- merge_flash.png
- merge_ring.png
- sparkle_small.png
- sparkle_large.png
- score_pop_bg.png
- order_complete_flash.png
- vip_complete_flash.png
- timer_warning_glow.png
- to_go_trail_variant.png
- combo_badge.png
- combo_glow.png
- win_rays.png
- confetti_strip.png
- milestone_glow.png

Effects must be restrained and board-readable, not screen-filling spectacle.

## L. Pause

`assets/ui_assets/screens/pause/`
- pause_panel.png
- button_resume.png
- button_restart.png
- button_settings.png
- button_world_map.png
- button_quit.png

## M. Level complete

`assets/ui_assets/screens/results/`
- level_complete_panel.png
- level_complete_title.png
- reward_slot.png
- vip_complete_badge.png
- score_summary_panel.png
- button_next_level.png
- button_replay.png
- button_island_map.png
- level_failed_panel.png
- time_up_title.png
- remaining_order_slot.png
- button_retry.png
- button_world_map_fail.png
- button_add_time.png
- video_ad_icon.png
- fail_timer_icon.png

## N. Milestone and island complete

`assets/ui_assets/screens/milestones/`
- milestone_reward_panel.png
- milestone_banner.png
- milestone_chest_closed.png
- milestone_chest_open.png
- reward_slot.png
- button_claim.png
- milestone_glow.png
- island_complete_panel.png
- island_complete_ribbon.png
- next_island_unlock_frame.png
- button_continue.png

Per-island complete badges are already part of each island pack.

## O. Star reward track

`assets/ui_assets/ui/star_track/`
- star_track_panel.png
- star_track_fill.png
- star_track_marker.png
- star_track_checkpoint.png
- star_track_chest_small.png
- star_track_chest_large.png
- star_track_claimed.png

## P. Shop

`assets/ui_assets/screens/shop/`
- shop_background.png
- shop_header.png
- shop_tab_boosters.png
- shop_tab_currency.png
- shop_tab_special.png
- shop_item_card.png
- shop_item_card_featured.png
- coin_pack_icon_small.png
- coin_pack_icon_medium.png
- coin_pack_icon_large.png
- gem_pack_icon_small.png
- gem_pack_icon_medium.png
- gem_pack_icon_large.png
- starter_pack_badge.png
- sale_badge.png
- best_value_badge.png
- button_buy.png

## Q. Rewarded ads

`assets/ui_assets/screens/rewarded_ad/`
- rewarded_ad_panel.png
- video_ad_icon.png
- button_watch_ad.png
- button_no_thanks.png
- reward_ad_time_icon.png
- reward_ad_double_icon.png

## R. Daily reward

`assets/ui_assets/screens/daily_reward/`
- daily_reward_background.png
- daily_reward_panel.png
- daily_day_slot.png
- daily_day_current.png
- daily_day_claimed.png
- daily_day_locked.png
- daily_chest.png
- button_claim.png
- streak_badge.png

## S. Settings

`assets/ui_assets/screens/settings/`
- settings_panel.png
- toggle_on.png
- toggle_off.png
- slider_track.png
- slider_handle.png
- sound_icon.png
- music_icon.png
- haptic_icon.png
- language_icon.png
- accessibility_icon.png
- privacy_icon.png
- restore_purchase_icon.png
- button_close_settings.png

## T. Tutorial/onboarding

`assets/ui_assets/screens/tutorial/`
- tutorial_panel.png
- tutorial_arrow.png
- tutorial_hand.png
- tutorial_highlight_ring.png
- tutorial_timer_icon.png
- tutorial_vip_badge.png
- tutorial_merge_icon.png
- tutorial_order_icon.png
- tutorial_skip_button.png

## U. Optional social/leaderboard full-set assets

`assets/ui_assets/screens/social/`
- leaderboard_panel.png
- rank_badge_1.png
- rank_badge_2.png
- rank_badge_3.png
- player_avatar_frame.png
- friend_icon.png
- share_icon.png

## V. Production evidence and metadata

Codex must also produce:
- `assets/ui_assets/ASSET_MANIFEST.json`
- `assets/ui_assets/ASSET_DIMENSIONS.csv`
- `assets/ui_assets/CONTACT_SHEET_GLOBAL.png`
- `assets/ui_assets/CONTACT_SHEET_ISLANDS.png`
- `assets/ui_assets/CONTACT_SHEET_TABLES.png`
- `assets/ui_assets/CONTACT_SHEET_SCREENS.png`
- `assets/ui_assets/README.md`

Manifest records at minimum:
- path
- category
- intended screen/use
- dimensions
- alpha/transparency expectation
- island id where relevant
- table geometry version where relevant
- generation/source method
- checksum

## W. Existing assets policy

Do not delete or overwrite existing files during this production pass.

Existing folders:
- `assets/cocktails/`
- `assets/environment/`
- `assets/effects/`
- `assets/ui/`

New work:
- `assets/ui_assets/**`

Integration/replacement of legacy runtime assets happens only through a separately audited integration task.
