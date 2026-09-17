# BCM-M07-R04 — Owner Screenshot Focused HUD Remediation Prompt V02

Status: **ISSUED — OWNER REFINEMENT V02**

This V02 supersedes `CHATGPT_REMEDIATION_PROMPT_V01.md` for BCM-M07-R04.

## Goal

Remediate ONLY the dynamic-content placement defects marked by the owner on the running Godot DEBUG screenshot dated 2026-09-17, plus the owner's later explicit refinements:

- To-Go Orders hanging ropes must visually attach to the top edge of the gameplay viewport;
- BEST SCORE and SCORE must use fixed font sizes selected to fit a maximum of 7 digits;
- To-Go Orders must not show `Lx/name` or any level/name text;
- To-Go reward must not use a leading plus sign.

Do not replace or redesign the refreshed background/HUD/progression artwork. The owner explicitly confirmed the intended visuals are already being used.

Read first:
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M07-R04/CHATGPT_AUDIT_CRITERIA_V02.md`

Then run governed sync preflight.

## Preserve exactly
- current refreshed game background/table composition;
- current BEST SCORE artwork;
- current SCORE artwork;
- current To-Go Orders artwork;
- current NEXT artwork;
- current baked 2x6 progression artwork;
- current progression mapping top L07-L12 / bottom L01-L06;
- current accepted M06-R04 danger/launch world coordinates;
- M01-M06 gameplay/economy behavior;
- no guide line.

Do NOT replace canonical PNGs in this task.

---

## 1. BEST SCORE and SCORE fixed-font fitting

The owner explicitly requires a **fixed font size**, not per-value dynamic font shrinking.

Requirements:
- independently measure the actual dark recessed numeric window in BEST SCORE and SCORE artwork;
- runtime renders only the number;
- choose a fixed production font size for each panel from actual rendered font metrics;
- the chosen fixed size must safely fit values up to **7 digits maximum** inside the dark recessed rectangle with visible padding on all four sides;
- values must remain horizontally and vertically centered using actual rendered glyph bounds;
- no glyph may touch/cross the gold rim, dark border, flowers, baked title or icon;
- do not change font size according to current digit count;
- if the BEST SCORE and SCORE windows differ materially, one fixed font size per panel is allowed, but each must remain constant across runtime values.

Validate and retain evidence for at least:
- `0`
- `321`
- `24380`
- `999999`
- `9999999`

The maximum display contract is 7 digits. Do not implement an 8+ digit case by silently shrinking the font.

---

## 2. To-Go Orders target + reward only, plus ceiling-attached ropes

The baked `To-Go Orders` title remains untouched.

Runtime content inside To-Go Orders must now be ONLY:
- current target cocktail;
- current reward digits.

### Remove level/name text completely

Remove/suppress all runtime To-Go level/name content:
- no `L6`;
- no `Lx`;
- no cocktail name;
- no combined `Lx/name` label;
- no hidden placeholder that still reserves awkward visual space if it is no longer needed.

The target cocktail and reward should be re-laid-out cleanly inside the cream board using the freed space.

### Reward format

Reward must be digits only:
- `1000`
- `1800`
- `3000`
- `5000`
- `8000`
- `12000`
- `18000`

Do NOT display:
- `+1000`
- `+1800`
- or any leading `+`.

Requirements:
- target cocktail full alpha-visible bounds stay inside the cream board;
- target does not cover the baked title;
- reward stays fully inside its dedicated lower safe region;
- target and reward do not materially overlap;
- use actual alpha-visible and rendered text bounds, not only centers.

Validate all eligible To-Go targets L06-L12.

### Owner ceiling-rope requirement

The two hanging ropes above the To-Go Orders board must visually connect all the way to the **top edge of the gameplay viewport**, so the panel reads as physically suspended from the screen ceiling/top frame.

Implement this without modifying the canonical To-Go PNG bytes:
- preserve the existing baked rope segments in the To-Go artwork;
- add only the minimum runtime rope continuation needed above the panel so each baked rope visually continues upward to viewport `y = 0` or the visible top safe edge if appropriate;
- left continuation aligns with the baked left rope anchor;
- right continuation aligns with the baked right rope anchor;
- continuation width, color, shading and visual thickness should match the baked rope as closely as practical;
- no visible gap between runtime rope continuation and baked rope;
- ropes remain behind To-Go board/decorative artwork;
- ropes must not cover title, target cocktail, reward, logo, NEXT or other HUD content;
- decorative only: no input, collision or physics;
- adapt responsively at 720x1280, 720x1440 and 800x1280.

Retain focused evidence proving both ropes touch the viewport top and join the baked anchors without gaps.

---

## 3. NEXT content fit for all L01-L12

Measure the actual safe cream content rectangle from the active NEXT artwork.

For each L01-L12:
- calculate actual cocktail alpha-used rect;
- fit inside the measured safe rectangle;
- preserve aspect ratio;
- preserve intended relative visual-size progression where possible;
- containment has absolute priority;
- no garnish, straw, fruit, leaf, flower, glass or body pixel may materially cross into the wooden header/frame/border.

Do not use one blind fixed sprite scale if it causes overflow.

Retain exactly one NEXT panel and true-next synchronization after rapid launch.

Create a retained NEXT L01-L12 fit sheet.

---

## 4. Held cocktail body-bottom anchoring

The owner requires cocktail bases to sit consistently on the launch baseline/halo.

Implement a visual-only per-level body-foot anchor:
- derive/record visible glass/container body bottom for L01-L12, excluding straw/fruit/leaf/flower garnish where appropriate;
- when HELD, offset only the Sprite2D visual so visible body bottom aligns to one common launch baseline/halo reference;
- document common baseline and per-level foot values/offsets;
- do NOT move/change physics body or collider center;
- do NOT change launch position, launch speed, deceleration, momentum, collision or economy.

Validate L01-L12 in a retained held-anchor contact sheet/overlay. Each body bottom must align within a documented small tolerance.

Halo remains behind the drink and centered on gameplay launch position.

---

## 5. Progression strip

Preserve current baked 2x6 presentation exactly.

Keep:
- baked artwork only;
- runtime cocktail sprites only;
- no extra cell frames;
- top row L07-L12;
- bottom row L01-L06.

Only touch progression code if required to prevent a regression caused by other layout changes.

---

## 6. Responsive validation

Validate at:
- 720x1280
- 720x1440
- 800x1280

For each retain:
- clean screenshot;
- visible-content-bounds overlay.

Additionally retain:
- BEST/SCORE **fixed-font** 7-digit fit sheet using the required test values;
- To-Go L06-L12 target/reward fit sheet proving no `Lx/name` and no leading `+`;
- To-Go rope-to-viewport-top close-up/overlay proving both ropes reach the top edge without gaps;
- NEXT L01-L12 fit sheet;
- held L01-L12 body-bottom baseline sheet;
- progression close-up proving unchanged 2x6 presentation.

---

## Regression

Run final:
- M01 contract
- M02 physics
- M03 economy/To-Go/Game Over
- M04 asset import
- M05 sprite/collider
- M06 geometry
- M07 R04 focused HUD probe
- Godot import/startup
- `git diff --check`

Do not weaken earlier tests.

## Governance
- Do not edit `TASKS.md`.
- Do not edit ChatGPT-owned audit/prompt/criteria/policy files.
- Do not rewrite historical logs.
- Do not edit canonical PNGs.
- Do not start M08+.
- Do not self-audit.

## Log

Write:
`coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`

The log must include:
- measured BEST/SCORE value rectangles;
- chosen fixed font size(s) and proof that `9999999` fits;
- confirmation font size does not vary with digit count;
- proof all To-Go `Lx/name` UI was removed;
- exact reward formatting without `+`;
- per-level To-Go target/reward results L06-L12;
- per-level NEXT results L01-L12;
- per-level held body-foot offsets;
- exact To-Go rope anchor X positions, top-edge endpoints and rope-continuation implementation;
- evidence hashes;
- exact commands/exit codes;
- changed files.

Commit/push the bounded M07-R04 work, verify local/origin/remote equality, return the log URL + commit SHA + `AWAITING_AUDIT`, then STOP.
