# BCM-M17 V07 Five-Trial Confirmation — CODEX Log

Status: `CHANGES_REQUIRED` / direct V07 runner failed; regression sequence not started.

## Work item and authority

- Work item: `BCM-M17-008` V07 five-trial confirmation.
- Prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V07.md`.
- Locked criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07.md`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD: `1c548367da2d9d28b94563546aa4cb274ee9dc9d`.
- End HEAD before publication: `1c548367da2d9d28b94563546aa4cb274ee9dc9d`.

## Synchronization preflight

- `git status --short --branch`: clean before V07 implementation, `## main...origin/main`.
- `git remote -v`: fetch and push both `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- `git fetch origin main`: completed; fast-forwarded clean checkout from `13c5b58` to `1c548367da2d9d28b94563546aa4cb274ee9dc9d`.
- `git rev-list --left-right --count HEAD...origin/main`: `0 4` before fast-forward; `0 0` after fast-forward.
- No reset, clean, stash, rebase, force-push, destructive checkout, branch creation, or worktree creation was used.

## Scope and files

Intended V07 evidence-only files:

- `tools/campaign/m17_canonical_confirmation_v07.gd`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07.md`

The pre-existing untracked `CODEX_LOG_V07_ATTEMPT_20260929_SYNC_BLOCKED.md` was preserved byte-for-byte and was not staged.

Root `TASKS.md`, canonical Sunny Cove data, V04/V05/V06/V06-R01/V06-R02 evidence, and gameplay implementation were not edited.

## Source and canonical evidence

- V06-R02 source SHA-256: `4A555D786A02EB1041A500316E007DD7F87E1C40DF8A28DE01739FC81B1AAA89`.
- Canonical Sunny Cove SHA-256: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.
- Required candidate set derived from V06-R02: `C01,C03,C04,C06,C07,C08,C09,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,C21,C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,C32,C33,C34,C35,C36,C37,C38,C39,C40,C41,C42,C43,C44,C45`.
- Candidate count: `42`.
- V06-R02 carried-forward classes: `C02/L3`, `C05/L7`, `C10/L14`.

## Commands and results

1. V07 parse check:

   ```text
   Godot_v4.7.2-stable_win64_console.exe --headless --path . --check-only --script res://tools/campaign/m17_canonical_confirmation_v07.gd
   exit=0
   ```

2. Direct V07 confirmation run:

   ```text
   Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/campaign/m17_canonical_confirmation_v07.gd
   exit=1
   ```

   The run executed the requested four new trials for each of 42 candidates: `168` new trials. The generated report contains `42` candidate records with exactly `5` trials each and `3` carried-forward records with one V06-R02 trial each. VIP semantics computed as `0/25` forced and `25/25` surplus.

3. `git diff --check`: passed for the current tracked diff; no product data diff was present.

4. Required post-PASS regressions were not run because the direct V07 runner failed, as required by the V07 stop rule.

## Direct failure

The runner returned:

```text
M17_CANONICAL_CONFIRMATION_V07_RESULT=FAIL
```

Failure reasons recorded by the runner:

- All 45 source class member/signature mapping comparisons were rejected because JSON-loaded Variant arrays/dictionaries were compared directly to typed/generated mappings.
- The runner’s seed registry reported `212` unique aggregate seeds instead of the expected `213`; the generated report’s actual trial seeds were otherwise distinct.
- Because the direct runner failed, its report status is `FAIL` and the batch is not audit-ready.

Generated report hashes:

- `M17_CANONICAL_CONFIRMATION_V07.json`: `99DD063CFADA66C61BBE215973A21B9ABECABC23A8B2878BB8212F0A06254AFB`.
- `M17_CANONICAL_CONFIRMATION_V07.md`: `BBF3FD11A1438B30EDEF492910997F4DB02511AD48E7A08C4B8572B372985615`.

The report’s observed final class counts were `16` solver-feasible and `29` high-risk 0/5, including the three carried-forward classes. These are failed-run evidence only and are not an acceptance verdict.

## Integrity and freeze results

- `TASKS.md` was not modified.
- `data/campaign/levels/sunny_cove.json` was not modified.
- No timer, objective, VIP target, reward, physics, collider, HUD, score, economy, progression, M18, or later-milestone changes were made.
- No repair-after-failure run was performed.
- No independent audit was requested because the direct required runner did not pass.

## Publication proof

- Publication commit: `c7ceb87c491aaa560cc799689aacb7f59f85e2d0`.
- GitHub commit: https://github.com/Sekiph82/Beach-Cocktails-Merge/commit/c7ceb87c491aaa560cc799689aacb7f59f85e2d0
- Final local HEAD: `c7ceb87c491aaa560cc799689aacb7f59f85e2d0`.
- Final `origin/main`: `c7ceb87c491aaa560cc799689aacb7f59f85e2d0`.
- Final remote `refs/heads/main`: `c7ceb87c491aaa560cc799689aacb7f59f85e2d0`.
- Final equality: PASS (`0 0` divergence).
- The only remaining working-tree item is the pre-existing untracked `CODEX_LOG_V07_ATTEMPT_20260929_SYNC_BLOCKED.md`; it was preserved and not staged.

## Required next action

This V07 attempt is stopped at the direct-run failure. A subsequent authorized remediation must correct the runner’s typed mapping and seed-registry validation, then execute a fresh V07 contract; the failed report must not be promoted as a PASS.

CHANGES_REQUIRED
