# BCM-M07-R04 — Owner Screenshot Focused HUD Remediation Prompt V01

Status: **ISSUED**

## Goal
Remediate ONLY the dynamic-content placement defects marked by the owner on the running Godot DEBUG screenshot dated 2026-09-17.

Do not replace or redesign the refreshed background/HUD/progression artwork. The owner explicitly confirmed the intended visuals are already being used.

Read first:
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M07-R04/CHATGPT_AUDIT_CRITERIA_V01.md`

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

## 1. BEST SCORE and SCORE numeric fitting

The current live values are positioned in the correct general panels, but the owner requires numbers to fit fully inside the dark recessed numeric rectangles.

Implement deterministic fit-to-window logic:
- independently measure/define the actual numeric value window for BEST SCORE and SCORE from the active panel artwork;
- render only the number;
- calculate font size from actual rendered font/string bounds;
- enforce safe inset padding on all four sides;
- vertically center the rendered glyph bounds inside the dark window;
- shrink only as much as needed when digit count grows;
- do not let glyphs touch/cross the gold rim, dark border, flowers, title or icon.

Test at minimum:
- `0`
- a 3-digit value such as `321`
- a 5-digit value such as `24380`
- a long/high value representative of an upper-score case.

Best and Score may use separate measured rectangles if the two PNG windows differ by pixels.

---

## 2. To-Go Orders content fit

The baked To-Go title remains untouched.

Runtime content only:
- target cocktail;
- `Lx + cocktail name`;
- `+reward`.

Create measured safe regions from the current active To-Go artwork.

Requirements:
- target cocktail full alpha-visible bounds must stay inside the cream board;
- cocktail must not cover the baked title;
- live level/name text must stay inside a dedicated text band;
- reward must stay inside a dedicated lower band;
- target, level/name and reward must not materially overlap one another;
- reward must never hang below/outside the board;
- use actual rendered text bounds and alpha-used rect bounds, not only centers.

Validate all eligible To-Go target levels L06-L12, because different garnish silhouettes can have very different alpha bounds.

---

## 3. NEXT content fit for all L01-L12

The owner explicitly requires that every cocktail fit in the cream NEXT window and that none spill into the wooden frame/header.

Measure the actual safe cream content rectangle from the active NEXT artwork.

For each L01-L12:
- calculate the cocktail's actual alpha-used rect;
- fit the sprite into the measured safe rectangle;
- preserve aspect ratio;
- preserve the intended relative visual-size progression between levels as much as possible;
- but safe containment is absolute priority;
- no garnish, straw, fruit, leaf, flower, glass or body pixel may materially cross the safe cream rectangle.

Do not use one blind fixed sprite scale for all levels if that causes overflow.

Retain a single production NEXT panel and true-next synchronization after rapid launch.

Create a retained 12-cocktail NEXT fit sheet showing L01-L12 in the real NEXT content window.

---

## 4. Held cocktail body-bottom anchoring

The owner annotated that cocktail bases must sit on the same launch baseline/halo location.

The current approach must not align held drinks purely by texture center, because each asset has different garnish height and transparent composition.

Implement a visual-only per-level body-foot anchor:
- derive/record the visible glass/container body bottom for L01-L12, excluding straw/fruit/leaf/flower garnish where appropriate;
- when a drink is HELD, offset only its Sprite2D visual so the visible body bottom aligns to one common launch baseline/halo reference;
- document the common baseline and per-level foot values/offsets;
- do NOT move/change the physics body/collider center;
- do NOT change launch position, launch speed, deceleration, momentum or collision behavior.

Validate L01-L12 in a retained held-anchor contact sheet/overlay. Each body bottom must land on the same baseline within a small documented tolerance.

The halo stays behind the drink and centered on the gameplay launch position.

---

## 5. Progression strip

Preserve it.

The owner screenshot shows the current baked 2x6 progression presentation as acceptable for this remediation. Do not redesign it.

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
- BEST/SCORE numeric fit close-up with test values;
- To-Go L06-L12 fit sheet;
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

The log must include exact measured content rectangles, fit algorithms, per-level NEXT results, per-level To-Go target results, score/best font-fit cases, per-level held body-foot offsets, evidence hashes, exact commands/exit codes and changed files.

Commit/push the bounded M07-R04 work, verify local/origin/remote equality, return the log URL + commit SHA + `AWAITING_AUDIT`, then STOP.
