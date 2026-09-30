# CODEX Execution Log - BCM-M17 V07-R03

Status: `COMPLETE - BUILDER EVIDENCE - AWAITING INDEPENDENT AUDIT`

This is the immutable master execution record for the complete authorized batch. CODEX did not edit root `TASKS.md` or the locked ChatGPT prompt/criteria.

## Contract

- Work item: `BCM-M17-008` V07-R03 bounded remediation.
- Master prompt: `CHATGPT_REMEDIATION_PROMPT_V07_R03.md`.
- Master criteria: `CHATGPT_AUDIT_CRITERIA_V07_R03.md`.
- Ordered child: `CHATGPT_REMEDIATION_PROMPT_V07_R03_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_CHILD_01.md` / `CODEX_LOG_V07_R03_CHILD_01.md`.
- Required final marker: `AWAITING_M17_AUDIT_V07_R03`.

## Required evidence to populate

- Exact preflight, branch, remote, fetch, divergence, start/end HEAD, and final local/origin/remote SHA equality.
- Frozen hashes proving TASKS, Sunny Cove, V07-R02, V07-R01, V06-R02, V05, and other protected evidence were untouched.
- R03 runner parse result, commit/blob/SHA-256, clean-tree proof, and exact committed-byte proof before direct execution.
- Direct command, stdout/stderr, exit code, R03 report hash, zero mapping errors, 42 candidates, 168 new trials, 42 x 5 aggregates, 213 seeds, class lists, and VIP results.
- Required regressions, only after direct PASS, with exact commands/results/exits.
- Scope limits, unavailable owner/manual acceptance, explicit TASKS immutability, and no M17 tuning/M18 statement.

## Execution record

Date: `2026-09-30`.

The batch contained exactly one ordered child: Child 01. The canonical checkout started clean and synchronized on `main` at `0b7587d1a9356a551e7aab2298c8220fe7c0bc03`; fetch succeeded and divergence was `0 0`. The R03 runner was already committed and pushed in that exact commit before execution. No synchronization overwrite, stash, reset, rebase, force-push, or owner-work discard was used.

The runner parse check passed with Godot 4.7.2. The exact committed direct command passed with exit `0` and produced:

`M17_CANONICAL_CONFIRMATION_V07_R03_RESULT=PASS levels=100 classes=45 candidates=42 new_trials=168 aggregate_candidate_trials=210 unique_seeds=213 feasible=11 high_risk=34 forced=0/25 surplus=25/25`

The committed report hashes are JSON `4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A` and Markdown `82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276`. Report integrity passed with 42 five-trial candidates, zero validation errors, zero screening-failure flags, and no VIP cost added to normal timers.

The locked targeted regressions then ran in order: V06 analytical PASS; V05 optionality PASS; M17 validation probe executed twice with both processes completing but the PTY wrapper not surfacing the final filtered markers; M16 PASS; M15 PASS; M14 PASS; M02 PASS. The M17 stream limitation is retained as an explicit unverified builder-evidence item for GPT audit; it is not converted into an acceptance claim.

Protected hashes remained unchanged: `TASKS.md` `7005DCF774B634D74688F2F2057D443840B491B9F511B97A324600D0C3199F1C`; Sunny Cove `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`; V07-R01 runner `F07BEF1D6E2384AFEB2A8D895F8B4AAB9677A4311B7FA50145F8C0C50C3CCA8E`; V07-R02 runner `BA5C9713043128965DA80A7A038E359D4CEC2F6EB6E2C8A82EC49737BF6894DE`; V06-R02 JSON/Markdown `4A555D786A02EB1041A500316E007DD7F87E1C40DF8A28DE01739FC81B1AAA89` / `6736C641B84D8ED27BEBCB56750045C7C45AEEDB4B42951134984ABB851D9A3D`; V05 JSON/Markdown `5FC6EF353D012C8D37D6FB68E6D2759F010636A2313AC0ED9272CC582F98D218` / `1FC7AE02FB637A5A99F35E38BCCD4FCB2E175A332E5C0B90302DB0ECA93FF130`.

`git diff --check` passed. `TASKS.md` had no diff. No canonical gameplay/data/physics/HUD/economy/progression/M18 or owner assets were changed. No owner/native/manual acceptance was performed. Builder evidence remains subject to the independent GPT audit.

Publication evidence URLs: [R03 runner commit](https://github.com/Sekiph82/Beach-Cocktails-Merge/commit/0b7587d1a9356a551e7aab2298c8220fe7c0bc03), [child log](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_CHILD_01.md), [R03 JSON](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.json), [R03 Markdown](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.md).

The final publication SHA is recorded by the post-commit/post-push verification immediately after this immutable log commit; the repository handoff must be evaluated from the verified local/origin/remote equality, not from this builder claim.

## Ordered-child rule

Child 01 is the only child. A failed or unverified direct run prevents any regression claim or acceptance claim.

## Final marker

`AWAITING_M17_AUDIT_V07_R03`

AWAITING_M17_AUDIT_V07_R03
