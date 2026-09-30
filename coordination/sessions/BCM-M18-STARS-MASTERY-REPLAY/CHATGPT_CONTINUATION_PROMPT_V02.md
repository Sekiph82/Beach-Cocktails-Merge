# BCM-M18-003..006 — V02 Owner-Approved Continuation

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_V01.md`
5. `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/OWNER_RULING_V02.md`
6. `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_CRITERIA_V02.md`
7. original V01 Child 03-06 prompts and locked criteria.

Child 01 and Child 02 are already independently audited PASS. Preserve them. Do not redo them.

## Ordered work

### Child 03 — BCM-M18-003

Resume the blocked cumulative-star reward track using the owner-approved payload:

- 30 stars → `time ×1`
- 60 → `time ×1`
- 90 → `time ×1`
- 120 → `time ×1`
- 150 → `upgrade ×1`
- 180 → `time ×1`
- 210 → `time ×1`
- 240 → `time ×1`
- 270 → `time ×1`
- 300 → `upgrade ×1`

Encode this as canonical Sunny Cove `reward_track` data, not hard-coded scattered policy.

Use authoritative stored best-star records to compute cumulative stars. Grant each newly crossed unclaimed threshold exactly once via the existing economy/reward-ledger boundary. Persist claim state. Catch-up across multiple thresholds must work. Existing level-number milestones and VIP rewards remain separate.

Add focused tests required by `CHATGPT_AUDIT_CRITERIA_V02.md`.

If Child 03 fails, stop. Do not start Child 04.

### Child 04 — BCM-M18-004

After Child 03 PASS and clean synchronized publication, execute the existing:
`CHATGPT_EXECUTION_PROMPT_V01_CHILD_04.md`
against its existing locked Child 04 criteria.

One-star normal completion advances progression. Perfect stars are never a progression gate. Preserve Sunny Cove L100 → Tiki Island completion rule.

If Child 04 fails, stop.

### Child 05 — BCM-M18-005

After Child 04 PASS and clean synchronized publication, execute the existing:
`CHATGPT_EXECUTION_PROMPT_V01_CHILD_05.md`
and locked Child 05 criteria.

Preserve replayability, authoritative prior earned state, monotonic replay persistence, and Island Map navigation/session context.

If Child 05 fails, stop.

### Child 06 — BCM-M18-006

After Child 05 PASS and clean synchronized publication, execute the existing:
`CHATGPT_EXECUTION_PROMPT_V01_CHILD_06.md`
and locked Child 06 criteria.

Run the full M18 integration and required regression closure.

## Governance

- Do not edit root `TASKS.md`.
- Do not rewrite historical stopped V01 logs or Child 01/02 evidence.
- Do not silently repair an earlier child from a later child.
- Publish each child result before proceeding.
- Do not tune Sunny Cove timers/objectives or VIP content.
- Do not change gameplay physics/HUD except if explicitly required by an existing locked M18 criterion; otherwise stop.
- Do not start M19.

## Logs

Create:
- `CODEX_LOG_V02_CHILD_03.md`
- `CODEX_LOG_V02.md`

For actually executed Child 04-06, populate their existing V01 child logs or create clearly named V02 continuation child logs if historical templates have already become immutable; never overwrite completed historical evidence.

The V02 master log must record exact commits, commands, exits, focused tests, regression results, protected-file checks, limitations, and final local/origin/remote equality.

On complete success, finish exactly:

`AWAITING_M18_AUDIT_V02`

Then stop.
