# BCM-M21-001-R04 — Build Home EXACTLY From Owner TARGET

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Branch:
`main`

## Your only job

Rebuild the production Home screen so it is **visually identical to the owner's TARGET image** using only the PNGs the owner has already placed in:

`assets/ui_assets/screens/home/`

Do not redesign anything.

Do not improve anything.

Do not move anything because you think it looks better.

Do not generate replacement art.

Do not edit any supplied PNG.

Do not work on Island Map, World Map, gameplay, To-Go, M07, M08, or any other feature in this run.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/OWNER_HOME_EXACT_TARGET_RULING_R04.md`
4. `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_CRITERIA_R04.md`

Root `TASKS.md` is read-only.

## Step 1 — Preserve and sync

The Home folder is owner-local work and may be untracked.

Inventory it BEFORE synchronization.

Preserve it.

Use AGENTS safe-sync rules and fast-forward to current `origin/main` without losing any local Home PNG.

Do not use `git clean`, reset --hard, rebase, or force push.

## Step 2 — Verify exact owner files

Expected in:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge\assets\ui_assets\screens\home\`

```
home background.png
TARGET beach cocktails merge home.png
level bari.png
enerji bari.png
coin bari.png
elmas bari.png
ekle gorseli.png
settings.png
play butonu.png
world map.png
shop.png
Events.png
daily rewards.png
achievements.png
```

Expected dimensions:

```
home background.png                 941 x 1672
TARGET beach cocktails merge home.png 941 x 1672
level bari.png                     2048 x 764
enerji bari.png                    2048 x 764
coin bari.png                      2048 x 763
elmas bari.png                     2048 x 764
ekle gorseli.png                   1266 x 1242
settings.png                       1254 x 1254
play butonu.png                    1916 x 821
world map.png                      2048 x 682
shop.png                           1313 x 1198
Events.png                         1313 x 1198
daily rewards.png                  1263 x 1246
achievements.png                   1313 x 1198
```

Hash every file before doing anything.

If any required file is missing, STOP and report the exact missing file.

Do not rename files.

## Step 3 — TARGET is absolute visual authority

`TARGET beach cocktails merge home.png` is not inspiration.

It is not approximate guidance.

It is the exact placement blueprint.

Build a deterministic reference-space composition at 941×1672.

For each separate source PNG, determine its exact bounding rect in TARGET.

Use image/template/alpha matching and overlay comparison, not visual guessing.

Record every rect in:

`coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json`

For every element record:
- file;
- source width/height;
- target x/y;
- target width/height;
- normalized x/y/w/h;
- z-order;
- input behavior.

Allowed placement tolerance at 941×1672:
**maximum 2 px center/size error.**

If your render differs visibly from TARGET, keep aligning it. Do not hand off a "close enough" result.

## Step 4 — Exact production layer stack

Base:
`home background.png`

It already contains the character, Beach Cocktails Merge logo, sunset/bar environment and hero scene.

DO NOT add any second logo.
DO NOT add any old main-menu background.
DO NOT add gradients.
DO NOT add old tropical side decor.
DO NOT add profile/currency panels from the old `screens/main_menu` implementation.

Overlay only the owner Home set exactly as TARGET:

### Top
- `level bari.png`
- `enerji bari.png`
- `coin bari.png`
- `elmas bari.png`
- `settings.png`

Place THREE separate instances of:
`ekle gorseli.png`

inside/right-edge of:
- energy bar;
- coin bar;
- diamond bar;

exactly as TARGET.

### Center
- `play butonu.png`
- `world map.png`

### Bottom
left to right exactly:
- `shop.png`
- `Events.png`
- `daily rewards.png`
- `achievements.png`

No fifth bottom button.
No bottom Settings.

## Step 5 — Dynamic numbers/text only

Do not bake or alter numbers into PNGs.

Overlay runtime values exactly in the TARGET number zones.

### Level
Top Level bar number:
use the actual current/selected campaign level N.

### Continue
Inside the blank lower plaque on `play butonu.png`:

`CONTINUE LEVEL N`

N must come from real campaign state.

Do not hardcode 12.

The TARGET fixture uses:
`CONTINUE LEVEL 12`

### Coins
Use the canonical current GameEconomy/campaign coin balance.

For TARGET fixture:
4250 must display as:
`4.250`

### Energy
First inspect for a real canonical energy authority.

If it exists, bind to it.

If it does not exist, DO NOT build an energy economy in this task.

Use Home-display default:
`100`

and document that it is presentation-only.

### Gems
Same rule.

If no canonical gem authority exists, do not invent a gem economy.

Use Home-display default:
`85`

and document presentation-only status.

### Text appearance

Match TARGET:
- centered in its intended area;
- white/cream;
- strong dark outline/shadow;
- no text overflow;
- no extra labels.

For the deterministic TARGET evidence fixture use:
- Level 12
- Energy 100
- Coins 4.250
- Gems 85
- CONTINUE LEVEL 12

## Step 6 — Interaction only where real

The visible PNG itself must be the hit target.

PLAY:
continue the real current campaign level through existing campaign/session authority.

WORLD MAP:
open the production World Map.

SETTINGS:
open the real Settings.

Shop / Events / Daily Rewards / Achievements:
keep them exactly visible like TARGET.
If a real canonical destination exists, wire it.
If not, do not invent a fake feature or fake data screen. Keep the visual target intact and behavior inert/non-destructive.

The three green plus images:
do not invent purchases.
If no canonical purchase action exists, keep them presentation-only and do not let them steal input.

## Step 7 — Remove the old Home composition from production visibility

The old R02 Home construction must not coexist underneath/above the TARGET Home.

No visible duplicates of:
- old MainMenuBackground;
- old BeachCocktailsLogo TextureRect;
- old tropical decor;
- old R02 PlayContinue button;
- old R02 WorldMap button;
- old Shop/Daily/Settings row;
- gradient underlay.

Do not delete unrelated source assets from the repository. Just make the new Home folder the sole production visual authority for Home.

## Step 8 — Reference-to-production scaling

TARGET coordinate system:
941×1672.

Production:
720×1280.

Debug:
800×1422.

Use normalized TARGET rects to scale the entire composition.

Do NOT rearrange for responsive design.

The same TARGET composition must simply scale to the current viewport.

## Step 9 — Visual parity proof

Render the actual production Home at 941×1672 with fixture values:
12 / 100 / 4250 / 85.

Save:
`coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/02_home_reference_941x1672.png`

Overlay/diff against:
`TARGET beach cocktails merge home.png`

Mask only the explicit dynamic text regions if font rasterization prevents byte equality.

All supplied ART placements must match within 2 px.

Also capture:
- 720×1280;
- 800×1422;
- PLAY navigation;
- WORLD MAP navigation;
- SETTINGS navigation.

## Step 10 — Do NOT flatten TARGET into production

Never use:
`TARGET beach cocktails merge home.png`

as the production Home texture.

It is reference-only.

Production must remain layered so PLAY/WORLD MAP/SETTINGS and dynamic values work.

## Step 11 — Tests

Add a focused exact-target Home probe.

Prove:
- each supplied asset path is used;
- each appears exactly once, except `ekle gorseli.png` exactly three times;
- rects match HOME_TARGET_LAYOUT_R04.json;
- TARGET itself is not a runtime texture;
- Level and Continue use the same live level N;
- Continue is not hardcoded 12;
- Coins bind to canonical economy;
- PLAY / WORLD MAP / SETTINGS are distinct real actions;
- no old R02 Home visual duplicates are visible.

Run the locked R04 criteria matrix.

Do not run/fix M07/M08 in this task. Those independent-audit findings are deliberately deferred to the next technical closure after this Home visual is owner-approved.

## Step 12 — Commit / publish / STOP

Commit:
- owner Home asset folder;
- exact Home implementation;
- layout JSON;
- focused tests;
- evidence;
- log.

Create:
`docs/codex-logs/CODEX_LOG_M21_HOME_EXACT_TARGET_R04.md`

Do not edit root `TASKS.md`.

Push to main.

Then STOP.

Do NOT self-approve the Home.

Return the GitHub link/path to:
`02_home_reference_941x1672.png`

Final marker exactly:

`AWAITING_OWNER_HOME_EXACT_TARGET_APPROVAL_R04`
