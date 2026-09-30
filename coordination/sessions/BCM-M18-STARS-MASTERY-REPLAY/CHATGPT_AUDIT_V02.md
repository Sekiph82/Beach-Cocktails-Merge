# BCM-M18 V02 — Independent Audit

Verdict: **CHANGES_REQUIRED / BOUNDED V02-R01 REMEDIATION**

Auditor: ChatGPT  
Builder: CODEX  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audited handoff HEAD: `597eabdd42ce42e688ea0774cfec8b0fbc97c17e`

## 1. Contract recovery

The governing contract is `CHATGPT_AUDIT_CRITERIA_V02.md`, backed by `OWNER_RULING_V02.md` and the original V01 Child 04-06 criteria. M18-001/002 were already independently audited PASS and were correctly preserved.

## 2. What passes

### Governance and order

- V02 executes in the required order: BCM-M18-003, 004, 005, 006.
- V01 Child 01/02 implementation/evidence remains preserved.
- Historical V01 OWNER_REQUIRED evidence remains preserved.
- M19 was not started.
- Root `TASKS.md` was not edited by Codex. The only tracker change in the V02 ancestry is ChatGPT commit `bd20dc04821717d31e63b5fc593ee8d7fe003a60`; the final tracker blob remains `a92d9c472c8d0c378b6c99b0779087c32a663fcc`.

### BCM-M18-003 core behavior

Repository truth contains the exact owner-approved cumulative-star payload:
- 30/60/90/120 => `time ×1`
- 150 => `upgrade ×1`
- 180/210/240/270 => `time ×1`
- 300 => `upgrade ×1`

The payload is data-driven in `data/campaign/islands.json`.

`CampaignManager` computes cumulative stars from authoritative completed-level stored star records, bounded by island level_count × 3.

The focused cumulative reward probe covers:
- 29→30;
- catch-up across multiple thresholds;
- 149→150;
- 299→300;
- duplicate prevention;
- worse replay idempotency;
- save/reload;
- non-blocking one-star progression.

### BCM-M18-004

The focused completion progression probe verifies:
- lose/timeout does not advance;
- one-star completion advances;
- deterministic next-level resolution;
- all 100 Sunny Cove levels can complete at one star;
- Sunny Cove completion unlocks Tiki Island without a perfect-star gate.

### BCM-M18-005 functional source

Completed levels remain selectable. Stored stars and best score are surfaced through Island Map/LevelButton. Replay return state preserves selected/focus/scroll context and avoids duplicate gameplay/map instances in the focused probe.

### BCM-M18-006

The final integration probe covers:
- base star award;
- worse replay preservation;
- better replay upgrade;
- cumulative reward claim/idempotency;
- 100-level Sunny Cove completion and Tiki unlock;
- save/reload;
- Island Map replay return.

Builder regression evidence records PASS/exit 0 for the M18 focused suite, M10-M16 campaign probes, and M01/M02/M03/M07/M08/M09 protected boundaries.

## 3. Material defect A — reward may be consumed logically without being granted

In `CampaignManager._claim_cumulative_star_rewards()`, the default value when `economy == null` is:

`{"ok": true, "granted": false, "duplicate": false, "reason": "ECONOMY_UNAVAILABLE"}`

Because `ok` is true, the threshold is appended to `claimed_star_rewards` even though no reward was granted.

This violates the locked semantic that every eligible threshold reward is granted exactly once. If a CampaignManager instance crosses a threshold before an economy authority is attached, that reward can become permanently claimed and unavailable for later grant.

Production navigation normally attaches an economy authority, which lowers runtime exposure, but the shared CampaignManager contract remains incorrect.

Required correction:
- economy unavailable must never mark an ungranted threshold as claimed;
- progression/completion must remain non-blocking;
- the threshold must remain eligible for a later attempt after economy becomes available;
- failed `grant_reward` must likewise remain unclaimed;
- successful/duplicate economy ledger outcomes must remain idempotent.

## 4. Material defect B — required Child 05 captures are missing

The original locked Child 05 criteria require focused runtime/probe evidence **and captures** for:
- completed level state;
- worse replay;
- improved replay;
- return to the same Island Map context.

No M18 capture image is present in the M18 session directory or V02 diff. The Child 06 log explicitly states that no new M18 capture could be produced in the headless environment.

Functional probe evidence is good, but the explicit capture criterion is not satisfied. Native/owner visual acceptance can remain separately unverified; builder capture evidence itself must still exist.

## 5. Evidence defect C — incorrect safe-merge SHA in logs

Child 05/master evidence records the safe reconciliation merge as:

`f9ae43e6d2df9dedb9cc3fe25aa0e55954d7c5b3`

That SHA does not exist.

The actual merge commit in repository ancestry is:

`f9ae43ef7b928b2815bc54c9b9845ce2ccacab22`

The locked handoff requires exact commit identities. The historical V02 logs must not be silently rewritten; the remediation log must explicitly correct this evidence typo and link the actual commit.

## 6. Scope and regression interpretation

No timer/objective/VIP-content retuning, physics change, HUD redesign, purchases/ads/backend behavior, or M19 work is evidenced.

The builder’s regression suite is broad and internally consistent. No new regression rerun is required solely to correct the SHA typo. Regression reruns required by the product fix and capture generation are defined in V02-R01 criteria.

## 7. Final verdict

**CHANGES_REQUIRED / V02-R01 BOUNDED REMEDIATION REQUIRED**

M18-003..006 are not closed yet.

The next remediation must be limited to:
1. correct the economy-unavailable cumulative-reward claim behavior;
2. add focused tests for deferred/unavailable-economy reward eligibility;
3. produce the missing M18 replay-state runtime captures;
4. publish an explicit correction for the Child 05 safe-merge SHA;
5. run only the focused/regression set required by the V02-R01 criteria;
6. preserve root `TASKS.md` and all historical V01/V02 evidence;
7. stop at `AWAITING_M18_AUDIT_V02_R01`.

M19 remains blocked.
