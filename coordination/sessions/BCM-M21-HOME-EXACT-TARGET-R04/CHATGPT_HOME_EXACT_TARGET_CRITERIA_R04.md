# BCM-M21-001-R04 — Exact Home Target Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
`OWNER_HOME_EXACT_TARGET_RULING_R04.md`

## 1. Scope

This is a Home-only visual composition task.

Allowed:
- use/commit files already placed by the owner under `assets/ui_assets/screens/home/`;
- modify the production Home/Main Menu composition code;
- add focused Home layout tests/evidence;
- minimally wire the existing PLAY/WORLD MAP/SETTINGS actions to the new visual controls.

Forbidden:
- Island Map changes;
- World Map changes;
- gameplay/HUD/To-Go changes;
- R04 gameplay surface changes;
- campaign economy redesign;
- energy/gem systems;
- M07/M08 remediation;
- root `TASKS.md` edits by Codex.

## 2. Asset integrity

Before implementation:
- inventory the exact local Home folder;
- hash every PNG;
- verify dimensions;
- verify TARGET and background are both 941×1672.

After implementation:
- hashes of all owner-supplied PNGs must be unchanged;
- all supplied PNGs must be committed to GitHub if they are not already tracked;
- TARGET remains reference/evidence only and is not drawn as the production Home.

## 3. Pixel-authoritative placement

Do not eyeball the layout.

Use `TARGET beach cocktails merge home.png` as the exact reference coordinate system at 941×1672.

For every separate source asset:
- determine its target-space bounding rectangle from the TARGET image;
- record `x, y, width, height` in TARGET pixels;
- record normalized rect;
- production uses those normalized transforms.

Create:
`coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json`

The JSON must include:
- source filename;
- source dimensions;
- target-space rect;
- normalized rect;
- z-order;
- input behavior;
- dynamic text rects.

At the 941×1672 reference render:
- asset center error ≤ 2 px;
- asset width/height error ≤ 2 px;
- no asset may be creatively moved to "look better."

## 4. Exact composition

The production Home contains ONLY the intended TARGET composition:

- full-screen `home background.png`;
- level bar;
- energy bar;
- coin bar;
- diamond bar;
- three copies of `ekle gorseli.png`;
- top-right settings;
- play;
- world map;
- shop;
- Events;
- daily rewards;
- achievements;
- dynamic numeric/text overlays.

Do not add:
- old main_menu background;
- old logo TextureRect;
- old left/right decor;
- gradient underlay;
- profile frame;
- old coin/gem panels;
- extra labels;
- extra utility row;
- extra Settings button;
- duplicate buttons.

## 5. Dynamic text/value placement

Text overlays must sit only in the blank zones shown by TARGET.

Required:
- Level number = actual campaign selected/current level.
- Continue = `CONTINUE LEVEL N`, actual level, no hardcoded 12.
- Coin = canonical coin balance.
- Target-evidence fixture: 4.250 formatting for 4250.
- Energy/Gems bind to real authority if it exists; otherwise presentation-only defaults 100/85, explicitly not an economy implementation.

Text must:
- be centered/aligned to the TARGET zones;
- use high-contrast white/cream text with dark outline/shadow consistent with TARGET;
- never alter source PNG pixels.

## 6. Functional input

Interactive visual bodies are the actual hit targets:
- PLAY image → continue campaign;
- WORLD MAP image → World Map;
- SETTINGS image → Settings.

No invisible displaced hitboxes.

Bottom Shop / Events / Daily Rewards / Achievements:
- keep exact TARGET visual;
- only wire where a canonical destination already exists;
- otherwise no fake screen/data is allowed.

Decorative bars/plus images may not intercept gameplay/navigation input unless a real supported action exists.

## 7. Responsive rule

TARGET reference is 941×1672.

Canonical game viewport is 720×1280.

Use normalized target coordinates so the same composition fills:
- 941×1672 evidence viewport;
- 720×1280 production;
- 800×1422 debug.

No alternate responsive rearrangement. The target composition scales as one coherent design.

## 8. Evidence

Create:
`coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/`

Required:
1. `01_target_reference_copy.png` — byte-identical copy/hash reference or documented source path, not production.
2. `02_home_reference_941x1672.png` — actual production Home rendered with fixture 12 / 100 / 4250 / 85.
3. `03_home_720x1280.png`
4. `04_home_800x1422.png`
5. `05_home_play_navigation.png`
6. `06_home_world_map_navigation.png`
7. `07_home_settings_navigation.png`

Also produce:
`HOME_TARGET_PARITY_R04.json`
with per-asset placement deltas and source hashes.

## 9. Target parity gate

At 941×1672, compare production render against TARGET.

Do not compare dynamic text pixels blindly if the runtime font differs. Mask only the explicit dynamic text regions and compute parity for all owner-supplied art regions.

PASS requires:
- all asset transforms within the 2 px tolerance;
- correct z-order;
- no missing supplied art;
- no extra production art;
- no clipping;
- no duplicate element;
- TARGET background/hero composition unchanged.

## 10. Focused tests

Add a focused R04 Home probe that asserts:
- exact Home asset paths;
- all target elements exist once;
- normalized rects match layout JSON;
- dynamic level is not hardcoded;
- Continue level matches campaign state;
- coin value comes from economy;
- PLAY/WORLD MAP/SETTINGS are distinct;
- old R02 Home nodes/assets are not visible as duplicates;
- target file itself is not used as production background.

Run:
- focused R04 Home probe;
- M20 app shell;
- M21 V05 World Map entry;
- clean Godot import/parse/boot;
- asset catalog rebuild/validator;
- `git diff --check`.

R03 M07/M08 closure is explicitly deferred, not part of this Home-only run.

## 11. Publication

Create:
`docs/codex-logs/CODEX_LOG_M21_HOME_EXACT_TARGET_R04.md`

Log:
- starting/final SHA;
- Home asset inventory + hashes/dimensions;
- exact layout JSON path;
- dynamic value sources;
- energy/gem authority result;
- evidence paths;
- focused test results;
- confirmation no owner PNG was modified;
- confirmation `TASKS.md` unchanged.

Push to `main`.

Stop after publishing the Home render. Do not self-approve visual parity.

Final marker exactly:

`AWAITING_OWNER_HOME_EXACT_TARGET_APPROVAL_R04`
