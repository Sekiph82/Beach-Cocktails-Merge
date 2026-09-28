# BCM-M15 Tall To-Go + VIP HUD — Independent Audit V06

Verdict: **AUDITED_PASS / OWNER_ACCEPTED**

Auditor: ChatGPT
Builder: CODEX
Branch: `main`
V06 implementation SHA: `63f08c7bc55a51acd704785891633de7797a2644`
V06 publication SHA: `8569df26325b1cbcee66b49befc36aabe9a52e78`
Owner-directed V06-R01 implementation: `7712e64`
Final audited HEAD: `96488258453e4aee23da57f3b73db8fd3a69464a`

## 1. Final verdict

M15 V06 passes the locked technical contract, and the owner has explicitly accepted the final V06-R01 runtime visuals.

M15 is closed.

The later V06-R01 adjustment is bounded to owner-requested presentation only:
- normal and VIP reward digits moved to the center of the visible brown reward recesses;
- reward digits changed to white;
- M07 expected reward bounds and V06 screenshots were updated accordingly;
- gameplay, economy, physics, campaign progression, canonical V06 asset, and root `TASKS.md` were not changed.

## 2. Canonical asset verification

Independent verification against final GitHub `main`:

- path: `assets/ui/panel_to_go_vip_orders.png`
- dimensions: **1132×1698**
- SHA-256: **acd600d05b316a01b5d39006cf845afa9674cfaaf0385c4f3aecda539d53539b**

This exactly matches the locked V06 owner ruling and criteria.

## 3. Diff / scope verification

The V06 implementation changes the combined HUD asset geometry and the bounded runtime/layout mappings needed for that asset.

The V06-R01 delta from `8569df...` to final `964882...` is exactly two commits ahead and contains only:
- `scripts/game_manager.gd`: two reward-label presentation changes;
- `tests/m07_r06_owner_layout_probe.gd`: one expected reward-bound update;
- `docs/evidence/m07/independent_inner_content_layout_v02.json`: matching documentation update;
- regenerated V06 screenshots;
- `CODEX_LOG_V06_R01.md`.

No root `TASKS.md` mutation by Codex was observed.

## 4. Acceptance matrix

| Gate | Result | Finding |
| --- | --- | --- |
| A. Exact canonical asset | PASS | Final GitHub asset independently verified at 1132×1698 and exact required SHA-256. |
| B. Width unchanged / height expanded | PASS | Runtime width remains `210 * ui_scale`; height derives from 1132×1698, producing 210×315 at the 720×1280 reference viewport instead of V05 ~210×140. |
| C. HUD composition | PASS + OWNER ACCEPTED | Final evidence shows the tall sign centered with long ropes and surrounding BEST/SCORE/NEXT/logo remaining readable. |
| D. Dynamic upper To-Go | PASS | Canonical cocktail source, authoritative normal progress, normal reward remain runtime-driven. Final R01 reward digits are white and centered in the brown recess. |
| E. Dynamic lower VIP | PASS | VIP cocktail, `0/N`, partial, `✓`, and 2× reward display remain runtime-driven. Final R01 reward digits are white and centered. |
| F. Non-VIP persistent state | PASS | Final evidence shows VIP panel retained, no VIP cocktail, exact `0/0`, blank reward digits. |
| G. Equal cocktail scale policy | PASS | Normal and VIP target sprites continue through the same shared scale helper and V06 max footprint. |
| H. Frozen technical behavior | PASS | Source/probe delta is presentation/layout-only; accepted M15 scoring/economy/progression and R11 physics contracts were not changed. |
| I. Runtime evidence | PASS + OWNER ACCEPTED | Final pending/partial/completed/non-VIP screenshots were independently opened from final GitHub HEAD; owner explicitly stated the visuals are OK. |
| J. Regression | PASS | Builder logs report M15 twice, M14, M08, M03, M07 composition/owner-layout and `git diff --check` PASS. The focused probes/source were independently inspected and remain aligned with the locked contract. |

## 5. Final runtime evidence reviewed

Final HEAD screenshots:

- `evidence/v06/normal_vip_pending.png`
- `evidence/v06/normal_vip_partial.png`
- `evidence/v06/normal_vip_completed.png`
- `evidence/v06/non_vip_0_of_0.png`

Independent visual inspection confirms:
- long rope treatment is visible;
- V06 combined HUD has the intended taller footprint;
- normal and VIP cocktail presentation is balanced;
- reward values are white and centered after R01;
- VIP progress reads `0/2 → 1/2 → ✓`;
- non-VIP reads `0/0` and has no misleading VIP reward value;
- no blocking overlap is visible.

Owner decision: **VISUAL ACCEPTED**.

## 6. Test-evidence note

ChatGPT did not execute the Windows/Godot binaries locally in this audit environment. Runtime test execution evidence comes from the immutable Codex logs. ChatGPT independently verified:
- live GitHub HEAD;
- bounded commit/diff scope;
- exact canonical asset bytes/dimensions;
- final runtime screenshots;
- relevant production source;
- focused probe assertions;
- owner visual acceptance.

No repository evidence contradicts the builder test results.

## 7. Closure

**BCM-M15-001: complete.**
**BCM-M15-R01: complete.**
**M15: AUDITED_PASS / OWNER_ACCEPTED / CLOSED.**

M16 may begin after ChatGPT updates the root H!veAI `TASKS.md`.
