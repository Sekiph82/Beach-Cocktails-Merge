# Codex Execution Log — BCM-M17-008 V07-R02

Status: **FAIL — AWAITING_M17_AUDIT_V07_R02**

## Scope

- Work item: `BCM-M17-008`
- Prompt: `CHATGPT_REMEDIATION_PROMPT_V07_R02.md`
- Criteria: `CHATGPT_AUDIT_CRITERIA_V07_R02.md`
- Requested confirmation: exact committed runner plus fresh `42 x 5` candidate confirmation.

## Repository and synchronization

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Branch: `main`
- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot: `Godot_v4.7.2-stable_win64_console.exe`
- Pre-run HEAD / origin / remote main: `36eebb47329ea9ea7e885df9d789dd2892606960`
- Pre-run divergence: `0 0`
- Post-run observed HEAD / origin / remote main: `39b722456cd72020c6777a44facb474b4303dd40`
- Post-run divergence: `0 0`
- The repository advanced during the run with commit `39b722456cd72020c6777a44facb474b4303dd40`, which corrected the R02 output path/result labels. No rerun was performed after that change because the exact committed runner execution had already failed.

## Pre-run proof

- R02 runner parse check: PASS, exit `0`.
- Exact runner committed before direct execution: `36eebb47329ea9ea7e885df9d789dd2892606960`.
- Exact runner SHA-256 at direct-run start: `A781C077552BF66A21E63B51503CD13B6833771D0F006BA60D632A03CBF44FF0`.
- Exact runner Git blob at direct-run start: `aeaad572f32419a9efef8173454f78292921fea9`.
- The working tree was clean before direct execution.

## Direct exact-committed runner

Command:

```text
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/campaign/m17_canonical_confirmation_v07_r02.gd
```

- Direct execution: **FAIL**, exit `1`.
- The run completed the full observed class sequence through C45 and emitted fresh seeds in the `17900000 + representative*100 + trial_index` namespace.
- The terminal result unexpectedly used the legacy label `M17_CANONICAL_CONFIRMATION_V07_R01_RESULT=FAIL` and reported `integrity=false`.
- No `M17_CANONICAL_CONFIRMATION_V07_R02_RESULT=PASS` line was emitted.
- Per the remediation stop rule, no runner repair, rerun, or regression suite was performed after this failure.

## Generated R02 failure evidence

The retained R02 report records:

- `report_version`: `V07-R02`
- `status`: `FAIL`
- levels: `100`
- classes: `45`
- confirmation candidates: `42`
- new trials: `168`
- unique aggregate seeds: `213`
- VIP forced captures: `0/25`
- VIP surplus paths: `25/25`
- VIP cost added to normal timers: `false`
- validation errors: every class `C01` through `C45` reported `member mapping changed` and `signature mapping changed`.

R02 artefact hashes:

- `M17_CANONICAL_CONFIRMATION_V07_R02.json` SHA-256: `C4D9459F34F1910DC60CD5E9640D44D18E7EF3DEA808FAA95650C3B34A44C4DD`
- `M17_CANONICAL_CONFIRMATION_V07_R02.md` SHA-256: `D4F45D0D9709716AA7B3338D8B014B218AEBD1171A38659D25E74AAC6D403CBC`
- Current committed R02 runner SHA-256 after the pre-existing `39b7224` correction: `BA5C9713043128965DA80A7A038E359D4CEC2F6EB6E2C8A82EC49737BF6894DE`.

## Historical preservation and checks

- V07-R01 JSON and Markdown were accidentally touched by the failed run’s legacy output path and were restored byte-for-byte to their committed content before publication.
- Restored V07-R01 JSON Git blob: `f816f2ed3e89a048246778613daef565d0f0814d`.
- Restored V07-R01 Markdown Git blob: `7b93fcd07829ec61ae567491a42eb314c4c03eac`.
- V07-R01 runner, report, Markdown, logs, V06-R02 evidence, V05 evidence, canonical data, and `TASKS.md` were not intentionally edited.
- `TASKS.md` was not modified.
- `git diff --check`: clean before publication.
- Regression suite: **NOT RUN** because the direct exact-committed runner failed.
- Manual owner acceptance / independent audit: **NOT PERFORMED**.

## Final handoff

- Builder evidence is failure evidence only; no acceptance claim is made.
- Final implementation HEAD before this failure log publication: `39b722456cd72020c6777a44facb474b4303dd40`.
- Required final marker: `AWAITING_M17_AUDIT_V07_R02`

AWAITING_M17_AUDIT_V07_R02
