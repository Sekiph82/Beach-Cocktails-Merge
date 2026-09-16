# BCM-M07-R01 — ChatGPT Remediation Prompt V01

Status: **ISSUED**

## Goal

Repair M07 after strict re-audit. This remediation must be executed only after the same session has completed M04-R01, M05-R01 and M06-R02, because M07 currently sits on a visually rejected M06 base.

Canonical owner visual truth:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Explicit later owner override: no dotted/persistent guide line.

## Read first

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_AUDIT_CRITERIA_V01.md`
- completed M04-R01, M05-R01 and M06-R02 remediation logs/state
- original M07 prompt/log and M07 probe

## Required work

1. Reconcile the existing M07 HUD with the corrected M06 environment/table composition. Do not preserve old M06 positions just because prior tests expect them.
2. Keep the established production HUD architecture where it remains valid:
   - top-left logo;
   - Best Score below logo;
   - Score below Best Score;
   - upper-center To-Go panel;
   - exactly one upper-right Next panel;
   - 12-slot L01-L12 progression strip;
   - launch zone under held drink;
   - canonical danger line at the actual gameplay threshold.
3. Preserve all changing values as live production data. Never bake score, best score, target, reward or next state into screenshots/assets.
4. Continue using the single shared `Drink.texture_for_level()` mapping. Do not add another L01-L12 path table.
5. Correct layout values/anchors/scales only where the repaired M06 visual base or owner master requires it.
6. Strengthen `tests/m07_hud_composition_probe.gd` so it checks independently defined layout/reference envelopes rather than only comparing production nodes to production constants. At minimum verify for all three viewports:
   - every required HUD rectangle is fully on-screen;
   - logo/Best/Score hierarchy has expected master-relative ordering and spacing envelope;
   - To-Go and Next are separated and upper HUD remains above the active accumulation region;
   - progression strip is fully visible near bottom;
   - each of 12 progression icon visible bounds stays within its authored slot envelope with bounded garnish allowance;
   - launch zone/held drink remain on corrected table launch region;
   - danger line spans the corrected visible table and agrees with the gameplay threshold;
   - no duplicate legacy presentation.
7. Produce fresh actual production captures for 720x1280, 720x1440 and 800x1280 after all M04-M06 fixes are present.
8. Produce a retained audit-evidence package that makes visual comparison explicit. At minimum include:
   - clean runtime captures;
   - master/reference composition sheet;
   - master-vs-runtime side-by-side/comparison sheets for each viewport;
   - optional annotated overlays marking table, logo, score stack, To-Go, Next, progression, danger and launch regions.
   Source owner assets must remain untouched.
9. Preserve gameplay/economy contracts: 700 px/s, 180 px/s², immediate next, concurrent moving drinks, forward-only response, merge momentum, L12 cap, M03 scores/combo/To-Go/persistence/restart/Game Over.
10. Rerun M01-M06 regressions plus strengthened M07 validation, Godot import/parse/startup and `git diff --check`.

## Out of scope

Do not implement M08 effects, audio, menus, export/device QA, guide line, or unrelated gameplay redesign.

Do not edit `TASKS.md` or any ChatGPT-owned audit/prompt/criteria file.

## Required log

Write only:

`coordination/sessions/BCM-M07-R01/CODEX_LOG_V01.md`

The log must contain exact sync state, files changed, before/after layout data, evidence file inventory/hashes, test commands/results/exit codes, source asset hash/status confirmation, final commit/push/equality evidence, and explicit limitations.

Codex does not self-audit. Commit/push the bounded M07 remediation and return `AWAITING_AUDIT`.
