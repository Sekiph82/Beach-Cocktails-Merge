# BCM-M15 VIP Overlay Visual Remediation — Audit Criteria V04

Status: **LOCKED BEFORE REMEDIATION**

Authority:

- `OWNER_DECISION_V04.md`
- `CHATGPT_AUDIT_V04.md`
- M15 V03 technical audit and implementation
- accepted M14 and R11 gameplay contracts

## Objective

Remediate only the owner-rejected VIP overlay visual states while preserving
the V03 technical implementation and the passing non-VIP baseline.

## Gate A — VIP pending state

PASS requires all of the following in the committed pending capture:

- the VIP target cocktail image is visible;
- no VIP overlay text covers or materially obscures the cocktail image;
- the `2X` premium indication is visible;
- the compact VIP overlay remains readable without changing accepted normal
  To-Go panel/table/HUD geometry.

## Gate B — VIP partial state

PASS requires:

- progress is materially visible through the VIP visual information
  architecture;
- changing only a textual `1/2` label is not the sole progress treatment;
- the target image remains visible and the `2X` indication remains visible;
- the partial state does not introduce the pending-state overlap or damage the
  normal To-Go panel.

## Gate C — VIP completed state

PASS requires:

- completion is represented by a bounded visual state rather than the long
  `COMPLETED` text;
- the completed state remains legible inside the compact VIP overlay;
- the target image and premium/completion meaning remain visually clear;
- no accepted normal To-Go panel or table/HUD geometry is moved or redesigned.

## Gate D — Non-VIP preservation

PASS requires the V03 non-VIP baseline to remain visually equivalent in the
new capture:

- the VIP overlay is absent when no VIP objective is active;
- the normal To-Go panel remains readable and retains its current geometry;
- no panel-asset replacement or unrelated HUD redesign is introduced.

## Gate E — Technical preservation

PASS requires preservation of the V03 technical contract:

- normal/VIP target-policy parity remains intact;
- exact 2x per-unit VIP payout remains intact;
- same-level normal-first precedence remains intact;
- score authority and separate economy reward remain intact;
- no M16 content, purchases, ads, backend, R11 physics/table/collider, or
  normal To-Go reward changes are introduced.

## Gate F — Evidence and regression

Required committed Windows/OpenGL evidence under:

`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v04/`

The evidence must include:

- VIP pending;
- VIP partial;
- VIP completed;
- non-VIP hidden baseline.

Required checks:

- M15 focused probe twice;
- M14, M13, M12, M11, M10, M08, M03, and M02 regressions;
- `git diff --check`;
- Godot import/parse bootstrap as applicable.

The builder log must be `CODEX_LOG_V04.md` and end with
`AWAITING_M15_AUDIT_V04`. Owner visual acceptance remains required after the
technical re-audit.

Any material failure or unverified item is `CHANGES_REQUIRED`.
