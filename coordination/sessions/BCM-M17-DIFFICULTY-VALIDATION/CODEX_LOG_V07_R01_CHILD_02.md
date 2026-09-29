# BCM-M17 V07-R01 Child 02 — Fresh 42x5 Confirmation Blocked

Status: `BLOCKED` / `DIRECT_RUN_FAIL_STOP_NO_REGRESSION`

This is builder evidence only; no independent acceptance is claimed.

## Authority and scope

- Work item: `BCM-M17-008` V07-R01.
- Prompt: `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_02.md`.
- Locked criteria: `CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_02.md`.
- Child 01 handoff: `CODEX_LOG_V07_R01_CHILD_01.md`, PASS, committed before this run.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Direct-run start HEAD: `2a04247aaffa26d40d74a9bf8b77b1fe34fc3cf4`.

## Preflight and frozen paths

The canonical checkout was synchronized before the direct run. At the time of
the run, local `HEAD` and `origin/main` both resolved to
`2a04247aaffa26d40d74a9bf8b77b1fe34fc3cf4`; the working tree was clean before
the three V07-R01 untracked run outputs were generated. `TASKS.md` remained
byte-for-byte unchanged with SHA-256
`32B5D015481510B3129B90C63C11D1934A6741B8FBBA5870550174D0CE3C7C90`.

Child 01 freeze hashes were preserved:

- V06-R02 JSON: `4A555D786A02EB1041A500316E007DD7F87E1C40DF8A28DE01739FC81B1AAA89`.
- V05 JSON: `5FC6EF353D012C8D37D6FB68E6D2759F010636A2313AC0ED9272CC582F98D218`.
- Sunny Cove canonical JSON: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.

No canonical data, timer/objective/VIP content, historical evidence, or
`TASKS.md` file was edited.

## Implementation and direct-run evidence

The only new implementation path was:

`tools/campaign/m17_canonical_confirmation_v07_r01.gd`

The runner parse check completed with exit code `0`:

```text
Godot --headless --path . --check-only --script res://tools/campaign/m17_canonical_confirmation_v07_r01.gd
exit=0
```

The authorized direct command was run once:

```text
Godot --headless --path . --script res://tools/campaign/m17_canonical_confirmation_v07_r01.gd
exit=1
```

The process completed the fresh confirmation batch and wrote the R01 JSON and
Markdown reports, but it did not emit the required
`M17_CANONICAL_CONFIRMATION_V07_R01_RESULT=PASS` line. The report recorded:

```text
status=FAIL
level_count=100
challenge_class_count=45
confirmation_candidate_count=42
new_trial_count=168
aggregate_confirmation_trial_count=210
aggregate_unique_seed_count=213
validation_error_count=168
```

The first validation errors were:

```text
duplicate aggregate seed 17800101
duplicate aggregate seed 17800102
duplicate aggregate seed 17800103
duplicate aggregate seed 17800104
duplicate aggregate seed 17800401
duplicate aggregate seed 17800402
duplicate aggregate seed 17800403
duplicate aggregate seed 17800404
```

The complete error set contains 168 duplicate aggregate-seed entries, covering
the four fresh seeds for each of the 42 candidate classes. This is a direct
runner-integrity failure, so the required stop rule applies.

## Stop-rule compliance

- Child 03 was not run.
- No V06, V05, M17, M16, M15, M14, or M02 regression was run after the direct failure.
- No repair-after-failure run was started.
- No canonical gameplay, difficulty model, timer, objective, VIP, or tracker change was made.
- The failed report and runner are retained as evidence for independent audit.

## Generated evidence hashes

- R01 runner: `F07BEF1D6E2384AFEB2A8D895F8B4AAB9677A4311B7FA50145F8C0C50C3CCA8E`.
- R01 JSON report: `F91F01607E1B67C667ED9D9E4DD5BE85E78D875BCDE8AD4D19C800AD212615AE`.
- R01 Markdown report: `87803982624C548C7085A63274B7748E3355BA9C6A1AC6EAADC475A80831CD74`.

## Limitations and handoff

This Child 02 result is builder evidence of a failed fresh confirmation run,
not an acceptance verdict. The direct seed-registry/integrity defect must be
resolved under a new authorized remediation instruction before any fresh
confirmation or regression batch can be attempted. The canonical checkout is
left at the blocked evidence boundary; `TASKS.md` was not modified.

`BLOCKED_M17_V07_R01_CHILD_02_DIRECT_RUN_FAIL`
