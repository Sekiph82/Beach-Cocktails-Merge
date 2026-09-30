# BCM-M18-003..006 — V02-R01 Bounded Remediation

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `CHATGPT_AUDIT_V02.md`
5. `CHATGPT_AUDIT_CRITERIA_V02_R01.md`
6. `OWNER_RULING_V02.md`
7. preserved V02 child/master logs.

The locked V02-R01 criteria are authoritative.

## Scope

Do not redo M18-001/002 and do not reopen already-correct V02 functionality.

This remediation has exactly three jobs:

### 1. Fix cumulative reward loss when economy is unavailable

In the existing cumulative-star reward path, an eligible threshold must not be written to `claimed_star_rewards` unless the reward grant is successfully reconciled.

Required:
- economy unavailable => completion/progression still succeeds, reward remains unclaimed;
- later economy attachment => still-eligible reward may grant exactly once;
- failed grant => remains unclaimed;
- ledger duplicate success => no duplicate inventory and claim state reconciles idempotently;
- successful grant => claim once;
- owner-approved threshold payload unchanged.

Add a focused remediation probe for these cases and keep all existing M18 probes green.

### 2. Produce the four missing Child 05 runtime captures

Produce actual runtime/probe captures for:
- completed level with stored stars + best score visible;
- worse replay preserving visible record;
- improved replay showing upgraded record;
- return to same Island Map context with selected/focus/scroll restored.

Store the captures under the M18 session evidence area with clear stable filenames. Add an evidence Markdown note mapping each image to its runtime scenario and command/run.

Do not alter visuals merely to make screenshots easier.

If valid runtime captures cannot be generated, stop and report failure. Do not claim completion.

### 3. Correct the SHA typo in new evidence only

Do not edit historical V02 logs.

Record in the new V02-R01 log that:
- historical typo: `f9ae43e6d2df9dedb9cc3fe25aa0e55954d7c5b3`
- actual merge commit: `f9ae43ef7b928b2815bc54c9b9845ce2ccacab22`

Prove the actual merge is in V02 ancestry and preserves the ChatGPT tracker commit `bd20dc04821717d31e63b5fc593ee8d7fe003a60`.

## Validation

Run exactly the required focused/regression set in `CHATGPT_AUDIT_CRITERIA_V02_R01.md`.

Do not edit root `TASKS.md`.

Do not touch timers/objectives/VIP content, gameplay physics, HUD layout, monetization, unrelated assets, or M19+.

## Handoff

Create and populate:
`coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CODEX_LOG_V02_R01.md`

Include exact commits, commands, exits, PASS markers, four capture paths, evidence note path, diff scope, SHA correction, protected-file proof, and final local/origin/remote equality.

On success finish exactly:

`AWAITING_M18_AUDIT_V02_R01`

Then stop. Do not start M19.
