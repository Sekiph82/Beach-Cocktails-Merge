# BCM-M15-R01 — Owner-Rejected VIP Overlay Visual Remediation Prompt V01

Status: **ISSUED — OWNER VISUAL CHANGES REQUIRED**

This bounded remediation follows:

- `OWNER_DECISION_V04.md`
- `CHATGPT_AUDIT_V04.md`
- `CHATGPT_AUDIT_CRITERIA_V04.md`
- `CHATGPT_AUDIT_V03.md`
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`

## Goal

Remediate only the VIP overlay visual states rejected by the owner in the
committed M15 V03 evidence. Preserve the V03 technical implementation and the
passing non-VIP baseline.

## Owner requirements to implement

### VIP pending

- Keep the VIP target cocktail image visibly present.
- Prevent overlay text from covering the cocktail image.
- Keep the `2X` premium indication visible.

### VIP partial

- Make progress materially visible through the VIP visual information
  architecture.
- A changing `1/2` text label by itself is not sufficient.
- Keep the target image and `2X` indication visible.

### VIP completed

- Replace the long `COMPLETED` text treatment with a bounded visual completion
  state.
- Keep completion meaning legible without damaging the panel.

### Non-VIP

- Preserve the current non-VIP baseline.
- When the VIP overlay is absent, the normal To-Go panel must remain as it is.

## Hard boundaries

Do not:

- replace or redesign the normal To-Go panel asset;
- move accepted normal To-Go, table, or HUD geometry;
- change VIP target-policy parity, 2x payout, score, bridge, economy, or
  same-level precedence logic;
- change normal To-Go reward values;
- start M16 or author level records;
- retune R11 physics, table geometry, or colliders;
- add purchases, ads, backend, or new unrelated gameplay;
- edit root `TASKS.md`;
- edit ChatGPT-owned prompts, criteria, audits, or owner decisions;
- create a branch, Desktop copy, or worktree;
- weaken or remove existing tests.

Use existing project visual/content authorities where possible. Any new visual
state must stay within the compact VIP overlay footprint and must not obscure
the cocktail target or normal To-Go content.

## Evidence and verification

Capture and commit Windows/OpenGL evidence under:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v04/`

Required captures:

- `vip_pending.png`
- `vip_partial.png`
- `vip_completed.png`
- `non_vip.png`

Run M15 twice, then M14, M13, M12, M11, M10, M08, M03, and M02, plus
`git diff --check` and the applicable Godot import/parse bootstrap. Record
exact commands and results.

Write the immutable handoff log:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V04.md`

Include changed files, evidence paths, exact test results, limitations, final
SHA/ref equality, and the marker `AWAITING_M15_AUDIT_V04`. Commit and push the
bounded remediation, then stop for independent audit and owner visual review.
