# BCM-M21-001-R04 — Owner Exact Home Target Ruling

Date: 2026-10-06

Status: **OWNER_HOME_EXACT_TARGET_REQUIRED**

This ruling supersedes the R02 Home composition and temporarily supersedes/deferes the R03 technical-closure execution until the exact Home target has been implemented and owner-reviewed.

The owner has placed the complete Home art set locally under:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge\assets\ui_assets\screens\home\`

The owner has also supplied the exact visual authority:

`TARGET beach cocktails merge home.png`

## Absolute visual authority

The TARGET PNG is the exact required Home composition.

Codex is NOT asked to redesign, improve, reinterpret, rebalance, simplify, modernize, or make a "similar" Home.

The task is mechanical composition:

**place the supplied Home PNG assets exactly where they appear in TARGET, at the same relative sizes and positions.**

No creative deviation is authorized.

## Required local Home asset set

Expected files in `assets/ui_assets/screens/home/`:

- `home background.png` — 941×1672
- `TARGET beach cocktails merge home.png` — 941×1672, reference/evidence only
- `level bari.png` — 2048×764
- `enerji bari.png` — 2048×764
- `coin bari.png` — 2048×763
- `elmas bari.png` — 2048×764
- `ekle gorseli.png` — 1266×1242
- `settings.png` — 1254×1254
- `play butonu.png` — 1916×821
- `world map.png` — 2048×682
- `shop.png` — 1313×1198
- `Events.png` — 1313×1198
- `daily rewards.png` — 1263×1246
- `achievements.png` — 1313×1198

Do not edit, repaint, crop, regenerate, rename, recolor, sharpen, blur, or replace these files.

## Exact visible structure

The finished production Home must visually match TARGET:

Top row:
1. Level bar at top-left.
2. Energy bar.
3. Coin bar.
4. Diamond bar.
5. Settings button at top-right.
6. The supplied `ekle gorseli.png` appears inside/at the right end of Energy, Coin, and Diamond bars exactly as in TARGET.

Hero:
- `home background.png` is the full-screen base and already contains the approved Beach Cocktails Merge hero/background artwork.
- Do not add a second logo, second character, alternate background, decor, gradient, or color overlay.

Primary actions:
- `play butonu.png` in the exact TARGET position/size.
- dynamic `CONTINUE LEVEL N` text centered in the button's lower blank plaque exactly as TARGET shows `CONTINUE LEVEL 12`.
- `world map.png` below PLAY, exact TARGET position/size.

Bottom row:
- `shop.png`
- `Events.png`
- `daily rewards.png`
- `achievements.png`

No fifth bottom Settings button. Settings exists only at the top-right as shown in TARGET.

## Dynamic values

Production overlays must place numbers in the exact TARGET number zones:

- Level: real current/selected campaign level `N`.
- Continue label: `CONTINUE LEVEL N`, using the same real current/selected campaign level.
- Coins: use current canonical GameEconomy/campaign coin balance.
- Energy: bind to a canonical energy authority if one currently exists.
- Gems: bind to a canonical gem authority if one currently exists.

The current repository has canonical coins but no proven canonical energy/gem economy authority in the previously audited source. Do not invent spending, purchasing, regeneration, or persistence systems in this visual task.

If no canonical energy/gem authority exists:
- use presentation-only default display values matching TARGET for this Home visual: Energy `100`, Gems `85`;
- clearly isolate these as Home display defaults, not a new economy;
- do not persist/mutate them as gameplay state;
- document this limitation in the builder log.

For deterministic TARGET-comparison evidence, seed:
- Level 12
- Energy 100
- Coins 4,250
- Gems 85
- Continue text `CONTINUE LEVEL 12`

Coin formatting in TARGET evidence must render as `4.250` to match the supplied visual.

## Functional behavior

Preserve existing truthful behavior:

- PLAY launches/continues the current selected campaign level through existing campaign/session authority.
- WORLD MAP opens production World Map.
- SETTINGS opens existing Settings.
- Shop / Events / Daily Rewards / Achievements must not invent fake product systems. If no canonical destination exists, keep the visual button fully visible and TARGET-identical but non-destructive/non-navigating until a later task.

## Deferred technical closure

The earlier R03 audit findings remain open:
- M07 regression reconciliation;
- M08 post-PASS crash;
- local `project.godot` clean-state reconciliation.

Do NOT work on those in this R04 task. They carry forward to a later post-Home technical closure package so this task remains exactly the owner's requested Home composition work.

Required stop marker:
`AWAITING_OWNER_HOME_EXACT_TARGET_APPROVAL_R04`
