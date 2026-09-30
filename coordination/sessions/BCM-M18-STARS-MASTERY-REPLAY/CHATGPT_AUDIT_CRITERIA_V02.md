# BCM-M18 V02 Continuation — Locked Audit Criteria

Status: **LOCKED BEFORE CONTINUATION**

Authority:
- `OWNER_RULING_V02.md`
- `CHATGPT_AUDIT_V01.md`
- original M18 V01 master/child prompts and criteria
- independently audited PASS results for Child 01 and Child 02.

## A — governance and preservation

- Work only on clean synchronized `main`.
- Preserve independently audited Child 01/02 implementation and evidence.
- Do not rerun or replace Child 01/02 unless a later required regression explicitly exercises their behavior.
- CODEX must not edit root `TASKS.md`.
- M19+ remains blocked until independent M18 closure audit.

## B — Child 03 cumulative-star track

Implement BCM-M18-003 using the exact payload in `OWNER_RULING_V02.md`.

Required thresholds/rewards:
- 30, 60, 90, 120 => `time ×1`
- 150 => `upgrade ×1`
- 180, 210, 240, 270 => `time ×1`
- 300 => `upgrade ×1`

Required semantics:
- cumulative stars are the sum of authoritative stored best-star records for completed Sunny Cove levels;
- 0..300 bounded total;
- threshold crossing grants every newly eligible unclaimed reward exactly once;
- claims persist and remain duplicate-safe after replay/reload;
- partial progress is deterministic;
- reward claims never gate completion, next level, island completion, or Tiki Island unlock;
- existing level-number milestones 10..100 remain separate and unchanged;
- VIP reward behavior remains unchanged;
- no coin payload is added.

Use the existing `reward_track`, `CampaignManager`, `GameEconomy`, and save schema boundaries. The canonical Sunny Cove data must contain the approved threshold/reward payload in a data-driven form.

Focused tests must cover at minimum:
- 29→30 threshold;
- multiple-threshold catch-up;
- 149→150 upgrade reward;
- 299→300 final upgrade reward;
- duplicate claim;
- replay with no new best stars;
- replay that improves stored stars and crosses a threshold;
- save/reload persistence;
- non-blocking progression.

## C — ordered continuation

After Child 03 passes its own checks and clean remote equality:
1. execute original V01 Child 04 under its locked criteria;
2. then original V01 Child 05;
3. then original V01 Child 06.

No later child may start after an earlier material failure or unverified gate.

## D — Child 04 preservation

Completion, not perfect-star status, remains the progression authority. One-star completion must advance; lose/incomplete must not. Sunny Cove Level 100 completion unlocks Tiki Island without a star gate.

## E — Child 05 preservation

Completed levels remain replayable; authoritative prior stars/best score are visible; worse replay cannot regress stored state; better replay updates state; map/session context must restore without duplicate instances.

## F — Child 06 closure

The final integration probe and regressions must cover:
- star award and monotonic best-star/best-score behavior;
- cumulative reward track and idempotency;
- completion-based progression;
- Island Map replay/return state;
- save/reload;
- 100-level Sunny Cove completion and Tiki Island unlock;
- relevant M10-M17 regression boundaries and protected gameplay/physics/HUD behavior.

## G — scope freeze

No timer/objective/VIP-content retuning, gameplay physics changes, HUD redesign, unrelated asset changes, purchases, ads, backend monetization, or M19+ implementation.

## H — handoff

Populate new continuation logs without rewriting historical V01 stopped evidence.

Required master log:
`coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CODEX_LOG_V02.md`

Child 03 may use:
`CODEX_LOG_V02_CHILD_03.md`

Original Child 04-06 logs may be completed only if their execution actually occurs under this continuation.

The final successful master handoff must end exactly:

`AWAITING_M18_AUDIT_V02`

Any failed, speculative, unverified, or out-of-order material criterion is `CHANGES_REQUIRED`.
