# CODEX Execution Log - BCM-M17 V07-R03 Child 01

Status: `COMPLETE - BUILDER EVIDENCE - AWAITING INDEPENDENT AUDIT`

Work item: `BCM-M17-008` V07-R03 bounded typed mapping-comparison remediation.
Prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_CHILD_01.md`.
Execution date: `2026-09-30`.

## Preflight and authorization

- Checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Initial `git status --short --branch`: `## main...origin/main` (clean).
- `git fetch origin main`: PASS.
- Initial divergence `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Start HEAD / origin/main / remote main: `0b7587d1a9356a551e7aab2298c8220fe7c0bc03` / same / same.
- Live tracker authorization: `BCM-M17-008`, `READY_FOR_CODEX`, Required Actor `CODEX`.
- Root `TASKS.md`: read only; not modified.

## Bounded implementation and commit-before-run proof

The required R03 runner was already present in the synchronized authoritative commit `0b7587d1a9356a551e7aab2298c8220fe7c0bc03`; no runner edit was made during this child. Its bounded correction normalizes typed integer/float mapping values for semantic comparison while preserving strict keys/values, telemetry, action logs, seeds, policy, and report integrity.

Runner: `tools/campaign/m17_canonical_confirmation_v07_r03.gd`.

- Runner commit: `0b7587d1a9356a551e7aab2298c8220fe7c0bc03`.
- Runner blob: `a26fde58b40b5b71ac04eaffc88de08dec4a2024`.
- Runner SHA-256: `0250AD26D995C8101F17E4834785746142CE00F511F5DA1929E80A7803A1ADBC`.
- Parse check: `godot_console.exe --headless --path . --check-only --script res://tools/campaign/m17_canonical_confirmation_v07_r03.gd` — exit `0`, Godot 4.7.2.
- Immediate pre-run HEAD/origin/remote: all `0b7587d1a9356a551e7aab2298c8220fe7c0bc03`; working tree `CLEAN`.

## Frozen protected evidence

- `TASKS.md`: `7005DCF774B634D74688F2F2057D443840B491B9F511B97A324600D0C3199F1C`.
- `data/campaign/levels/sunny_cove.json`: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.
- V07-R01 runner: `F07BEF1D6E2384AFEB2A8D895F8B4AAB9677A4311B7FA50145F8C0C50C3CCA8E`.
- V07-R02 runner: `BA5C9713043128965DA80A7A038E359D4CEC2F6EB6E2C8A82EC49737BF6894DE`.
- V07-R01/V07-R02 logs and reports remained byte-for-byte unchanged; V06-R02 and V05 evidence remained unchanged.

## Direct R03 confirmation

Command: `godot_console.exe --headless --path . --script res://tools/campaign/m17_canonical_confirmation_v07_r03.gd`.

Result: exit `0`; exact marker:

`M17_CANONICAL_CONFIRMATION_V07_R03_RESULT=PASS levels=100 classes=45 candidates=42 new_trials=168 aggregate_candidate_trials=210 unique_seeds=213 feasible=11 high_risk=34 forced=0/25 surplus=25/25`

Report evidence:

- JSON: `M17_CANONICAL_CONFIRMATION_V07_R03.json`, SHA-256 `4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A`.
- Markdown: `M17_CANONICAL_CONFIRMATION_V07_R03.md`, SHA-256 `82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276`.
- Report integrity: PASS; 42 five-trial candidates, zero validation errors, zero `SCREENING_FAILURE_NEEDS_CONFIRMATION` flags, VIP cost not added to normal timers.
- Feasible classes: `C01,C02,C03,C04,C05,C06,C10,C11,C17,C34,C39`.
- High-risk classes: `C07,C08,C09,C12,C13,C14,C15,C16,C18,C19,C20,C21,C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,C32,C33,C35,C36,C37,C38,C40,C41,C42,C43,C44,C45`.

## Locked regressions

- V06 analytical: `res://tests/m17_canonical_screening_v06_analytical_probe.gd` — `M17_V06_ANALYTICAL_RESULT=PASS levels=100 classes=45`, exit `0`.
- V05 optionality: parse check and `res://tests/m17_vip_optionality_probe.gd` — `M17_VIP_OPTIONALITY_RESULT=PASS`, exit `0`.
- M17 validation probe was executed twice in order. Both long-running Godot processes completed; the PTY wrapper truncated the final filtered marker from these two streams, so the final marker for these regression invocations is not independently surfaced in this log. No error output was observed before truncation.
- M16: `res://tests/m16_sunny_cove_content_probe.gd` — `M16_SUNNY_COVE_CONTENT_RESULT=PASS`, exit `0`.
- M15: `res://tests/m15_vip_boosters_economy_probe.gd` — `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`, exit `0`.
- M14: `res://tests/m14_gameplay_session_bridge_probe.gd` — `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`, exit `0`.
- M02: `res://tests/m02_physics_regression.gd` — `M02_PROBE_RESULT=PASS`, exit `0`.

## Scope, limitations, and handoff

- `git diff --check`: PASS.
- Only the R03 JSON/Markdown report outputs and these required logs were added in this child; no canonical data, gameplay, physics, HUD, economy, progression, M18, or owner assets were changed.
- No owner/native/manual/subjective acceptance was performed; builder evidence is not acceptance.
- No repair or rerun of the direct R03 confirmation was performed.
- Evidence URLs after publication: [runner commit](https://github.com/Sekiph82/Beach-Cocktails-Merge/commit/0b7587d1a9356a551e7aab2298c8220fe7c0bc03), [R03 JSON](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.json), [R03 Markdown](https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.md).
- This child does not update `TASKS.md` and does not assign an audit verdict.

Child completion marker: `CHILD_01_COMPLETE`.
