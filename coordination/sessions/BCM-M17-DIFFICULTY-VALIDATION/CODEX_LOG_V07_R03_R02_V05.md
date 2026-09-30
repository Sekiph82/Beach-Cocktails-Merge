# CODEX Execution Log - BCM-M17 V07-R03-R02-V05

Status: FIRST PUBLICATION - BUILDER EVIDENCE - AWAITING INDEPENDENT AUDIT

Work item: BCM-M17-008 V07-R03-R02-V05 no-rerun evidence-log correction.

Master prompt/criteria: CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_V05.md / CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V05.md.

This package has exactly one ordered child. Preserve V04 and all earlier evidence. No project command may be rerun.

## Governance and preservation

- Canonical checkout / branch / remote: C:\Users\sekip\Desktop\Beach Cocktails - Merge / main / origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Preflight and divergence: clean ## main...origin/main; fetch succeeded; divergence 0 0
- Start HEAD/origin/main/remote main: all 9de12e8cca001770602ea2e5a07a9654fc6a42e4
- Required Actor/status: CODEX / READY_FOR_CODEX
- Protected hashes and V04 evidence preservation: V07-R03 report/runner and canonical Sunny Cove data were inspected read-only; current hashes are recorded in the child log and the V04 evidence block below. V04 logs and terminal record remain immutable.
- TASKS.md remained byte-for-byte unchanged; current SHA-256: 1190441A6B0CA7D05F5E65BFCD9DC19BB2BE300E5E6A408ABAEB36CFAF860001
- No production code, canonical data, runner/report, historical evidence, timer/objective tuning, owner work, or M18 work changed
- No destructive synchronization operation used
- No V07-R03, V04, M17, M16, M15, M14, M02, smoke, regression, or other project command was rerun

## First-publication equality embedded in both V05 logs

- First publication commit: f851cd4d73b5fc87e7e4247329e997303fe71afe
- `git rev-parse HEAD`: f851cd4d73b5fc87e7e4247329e997303fe71afe
- `git rev-parse origin/main`: f851cd4d73b5fc87e7e4247329e997303fe71afe
- `git ls-remote origin refs/heads/main`: f851cd4d73b5fc87e7e4247329e997303fe71afe\trefs/heads/main
- Clean status: `## main...origin/main`
- `git diff --check`: exit 0

## Evidence correction

- V04 transcripts preserved without rerun or alteration in the complete block below.
- V07-R03 report/runner inspected read-only and not rerun.
- Child 01 log path: coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_R02_CHILD_01_V05.md
- Terminal record path: docs/codex-logs/BCM-M17_V07_R03_R02_V05_FINAL_PUBLICATION_CODEX_LOG.md

## Preserved V04 master evidence

The following block is the complete V04 master log copied without changing captured commands, stdout, stderr, markers, exit codes, protected hashes, or prior-attempt claims.

--- BEGIN PRESERVED V04 MASTER LOG ---
# CODEX Execution Log - BCM-M17 V07-R03-R02-V04

Status: COMPLETE - BUILDER EVIDENCE - AWAITING INDEPENDENT AUDIT

Work item: BCM-M17-008 V07-R03-R02-V04 capture-compatible evidence-handoff remediation.

Master prompt/criteria: CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_V04.md / CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V04.md.

Exact ordered package: exactly one child, Child 01. No later child exists.

## Batch result

Child 01 completed the evidence-only retry. The compatible smoke check passed, then the eight-command locked sequence ran exactly once and in order. Every required marker and native exit code passed. The existing V07-R03 direct PASS was inspected read-only and was not rerun or repaired.

## Governance, preservation, and synchronization

- Canonical checkout: C:\Users\sekip\Desktop\Beach Cocktails - Merge
- Branch/remote: main / origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Preflight: clean ## main...origin/main; fetch succeeded; divergence 0 0
- Required Actor/status: CODEX / READY_FOR_CODEX
- TASKS.md was read and remained byte-for-byte unchanged; Codex did not edit it
- No production code, canonical data, runner/report, historical evidence, timer/objective tuning, or M18 work changed
- No direct V07-R03 confirmation runner was invoked

## Equality and protected hashes

- Start/execution HEAD: 09505694d1d7f640230cca6bd245ddbe00c8bc3c
- Start/execution origin/main: 09505694d1d7f640230cca6bd245ddbe00c8bc3c
- Start/execution remote main: 09505694d1d7f640230cca6bd245ddbe00c8bc3c
- Pre-publication HEAD/origin/main/remote main: all 09505694d1d7f640230cca6bd245ddbe00c8bc3c
- Pre-publication status: ## main...origin/main
- git diff --check: exit 0
- git diff --quiet -- TASKS.md: exit 0
- git diff --cached --quiet -- TASKS.md: exit 0

- TASKS.md: A5FD6A7717CDB1A335FDE4DACAC51CC788101EF011DA49A67F3DCB7F5F581E59
- data/campaign/levels/sunny_cove.json: 9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495
- tools/campaign/m17_canonical_confirmation_v07_r03.gd: 0250AD26D995C8101F17E4834785746142CE00F511F5DA1929E80A7803A1ADBC
- M17_CANONICAL_CONFIRMATION_V07_R03.json: 4B07CE2778F9CD001756BE26259B169288D002F385484F94A85A120BF7101C9A
- M17_CANONICAL_CONFIRMATION_V07_R03.md: 82EA191C7333BEED7DAAFA4639EAE47EAF904B2C3ADE0A9A9390C6ECC1165276

## Compatibility gate

```text
CAPTURE_IMPLEMENTATION=ProcessStartInfo.Arguments plus ReadToEndAsync, WaitForExit, and exact ExitCode; ProcessStartInfo.ArgumentList was not used.
COMMAND=C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -Command "Start-Sleep -Milliseconds 150; Write-Output 'COMPAT_SMOKE_STDOUT'; [Console]::Error.WriteLine('COMPAT_SMOKE_STDERR'); exit 0"
STDOUT_BEGIN
COMPAT_SMOKE_STDOUT
STDOUT_END
STDERR_BEGIN
COMPAT_SMOKE_STDERR
STDERR_END
NATIVE_EXIT_CODE=0
WAIT_PROOF=the completion marker was emitted after the bounded delay and captured before native exit was recorded.
REPOSITORY_STATUS_BEFORE=CLEAN
REPOSITORY_STATUS_AFTER=CLEAN
```

## Ordered child record

- Child 01: COMPLETE
- Locked order: V06 analytical -> V05 optionality -> M17 difficulty twice -> M16 -> M15 -> M14 -> M02
- Complete transcripts, exact commands, native exit codes, and required markers are duplicated below and in the child log
- git diff --check, TASKS worktree/index freeze checks, and clean status passed

## Complete locked regression transcript

Complete verbatim stdout/stderr capture, in exact locked order:

```text
### 01-V06-ANALYTICAL
COMMAND=godot_console.exe --headless --path . --script res://tests/m17_canonical_screening_v06_analytical_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_V06_ANALYTICAL PASS: canonical Sunny Cove loads in FULL mode
M17_V06_ANALYTICAL PASS: canonical dataset has exactly 100 levels
M17_V06_ANALYTICAL PASS: canonical dataset has exactly 45 challenge classes
M17_V06_ANALYTICAL PASS: all levels map once and class representatives are lowest IDs
M17_V06_ANALYTICAL PASS: all normal objectives are reachable with positive quantities and timers
M17_V06_ANALYTICAL PASS: timer/cost scan covers all levels
M17_V06_ANALYTICAL PASS: timer scan does not invent strict impossibility
M17_V06_ANALYTICAL PASS: V04 historical report is present and distinct
M17_V06_ANALYTICAL PASS: V05 post-fix forced result is 0/25
M17_V06_ANALYTICAL PASS: V05 post-fix surplus result is 25/25
M17_V06_ANALYTICAL PASS: V05 reports no validation errors
M17_V06_ANALYTICAL PASS: canonical Sunny Cove JSON is byte-for-byte unchanged
M17_V06_ANALYTICAL_RESULT=PASS levels=100 classes=45
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M17_V06_ANALYTICAL_RESULT=PASS levels=100 classes=45
REQUIRED_MARKER_PRESENT=True

### 02-V05-OPTIONALITY
COMMAND=godot_console.exe --headless --path . --script res://tests/m17_vip_optionality_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_V05_PROBE PASS: F1 one L5 candidate is protected
M17_V05_PROBE PASS: F1 two L5 including candidate are protected
M17_V05_PROBE PASS: F1 third L5 becomes surplus
M17_V05_PROBE PASS: F2 higher L8 cannot satisfy lower L5
M17_V05_PROBE PASS: F2 exact L5 remains protected beside unsplittable L8
M17_V05_PROBE PASS: canonical data loads for L60/L100 planner fixtures
M17_V05_PROBE PASS: L60 mandatory reserve protects every normal piece
M17_V05_PROBE PASS: L60 extra VIP L7 is surplus
M17_V05_PROBE PASS: L100 mandatory reserve protects every normal piece
M17_V05_PROBE PASS: L100 extra VIP L7 is surplus
M17_V05_PROBE PASS: V05 fixture loads in FULL validation
M17_V05_PROBE PASS: V05 fixture campaign configures
M17_V05_PROBE PASS: real campaign navigation configures V05 fixture
M17_V05_PROBE PASS: real GameManager session opens
M17_V05_PROBE PASS: G stocked path protects first mandatory L5
TO-GO ORDER L6 +1000  (toplam: 1000)
M17_V05_PROBE PASS: protected normal L6 enters normal capture
M17_V05_PROBE PASS: G normal WIN succeeds with VIP intentionally missed
M17_V05_PROBE PASS: G missed VIP receives no booster reward
M17_V05_PROBE PASS: I first play persists vip_completed=false
M17_V05_PROBE PASS: return to Island Map succeeds after terminal session
M17_V05_PROBE PASS: replay creates a fresh real GameManager session
MERGE L5 +200  COMBO x1 +0  (toplam: 200)
M17_V05_PROBE PASS: H direct merged surplus L5 enters VIP capture
VIP DELIVERY L5 +1/1 BONUS 0 (toplam: 200)
M17_V05_PROBE PASS: H protected reserve remains after direct VIP capture
TO-GO ORDER L6 +1000  (toplam: 1200)
M17_V05_PROBE PASS: protected normal L6 enters normal capture
M17_V05_PROBE PASS: H normal WIN succeeds after surplus VIP delivery
M17_V05_PROBE PASS: H configured VIP reward grants exactly once
M17_V05_PROBE PASS: I replay persists vip_completed=true
M17_V05_PROBE PASS: return to Island Map succeeds after terminal session
M17_V05_PROBE PASS: replay creates a fresh real GameManager session
M17_V05_PROBE PASS: I stocked surplus L5 enters VIP capture
VIP DELIVERY L5 +1/1 BONUS 0 (toplam: 0)
M17_V05_PROBE PASS: I stocked VIP capture leaves mandatory reserve
TO-GO ORDER L6 +1000  (toplam: 1000)
M17_V05_PROBE PASS: protected normal L6 enters normal capture
M17_V05_PROBE PASS: I second replay still wins normally
M17_V05_PROBE PASS: I second replay does not duplicate VIP reward
M17_V05_PROBE PASS: I second replay keeps persisted vip_completed=true
M17_VIP_OPTIONALITY_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M17_VIP_OPTIONALITY_RESULT=PASS
REQUIRED_MARKER_PRESENT=True

### 03-M17-DIFFICULTY-RUN-01
COMMAND=godot_console.exe --headless --path . --script res://tests/m17_difficulty_validation_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_PROBE PASS: canonical Sunny Cove loads in FULL validation mode
M17_PROBE PASS: canonical Sunny Cove has 100 levels
M17_PROBE PASS: L1 objective cost is 16
M17_PROBE PASS: L100 objective cost is 240
M17_PROBE PASS: VIP cost is separate
M17_PROBE PASS: expected L1-equivalent spawn value is 7/3
M17_PROBE PASS: timer exposes named calibration
M17_PROBE PASS: timer calibration override changes raw and target time
M17_PROBE PASS: percentile uses deterministic R7 interpolation
M17_PROBE PASS: telemetry schema is complete
M17_PROBE PASS: same-level left target shifts action left
M17_PROBE PASS: same-level right target shifts action right
M17_PROBE PASS: left-side congestion selects a safer non-left lane
M17_PROBE PASS: identical board state produces identical action
M17_PROBE PASS: policy has no future-RNG input
M17_PROBE PASS: policy returns a legal horizontal bucket
M17_PROBE PASS: fixture GameManager is ready
M17_PROBE PASS: fixture campaign bridge starts
OYUN BITTI - Skor: 0
M17_PROBE PASS: danger fixture uses production danger-line/game-over path
M17_PROBE PASS: TABLE_DANGER fixture terminal reason is preserved
M17_PROBE PASS: TABLE_DANGER fixture outcome is danger
M17_PROBE PASS: TABLE_DANGER fixture is not timeout
M17_PROBE PASS: fixture GameManager is ready
M17_PROBE PASS: fixture campaign bridge starts
M17_PROBE PASS: timeout fixture expires the production campaign timer
M17_PROBE PASS: TIMEOUT fixture outcome is timeout and not danger
M17_PROBE PASS: controlled near-rail footprint creates one proxy event
M17_PROBE PASS: continuous proximity does not inflate the same edge event
M17_PROBE PASS: centered footprint does not create a false rail event
M17_PROBE PASS: release beyond 3px then re-entry creates a second event
M17_PROBE PASS: qualification runner policy time scale is canonical
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
M17_PROBE PASS: same seed produces the same action log
M17_PROBE PASS: same seed preserves logical outcome
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
M17_PROBE PASS: exact action-log replay preserves logical result
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x1 +0  (toplam: 150)
MERGE L3 +50  COMBO x2 +13  (toplam: 213)
MERGE L4 +100  COMBO x3 +50  (toplam: 363)
MERGE L3 +50  COMBO x1 +0  (toplam: 413)
MERGE L4 +100  COMBO x1 +0  (toplam: 513)
MERGE L4 +100  COMBO x2 +25  (toplam: 638)
MERGE L2 +20  COMBO x1 +0  (toplam: 658)
MERGE L4 +100  COMBO x1 +0  (toplam: 758)
MERGE L5 +200  COMBO x2 +50  (toplam: 1008)
TO-GO ORDER L5 +0  (toplam: 1008)
M17_PROBE PASS: different seed changes the seeded action sequence
M17_PROBE PASS: focused trial telemetry validates
M17_PROBE PASS: merge-aware actions carry decision evidence
M17_PROBE PASS: canonical Sunny Cove JSON is byte-for-byte unchanged
M17_DIFFICULTY_VALIDATION_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M17_DIFFICULTY_VALIDATION_RESULT=PASS
REQUIRED_MARKER_PRESENT=True

### 04-M17-DIFFICULTY-RUN-02
COMMAND=godot_console.exe --headless --path . --script res://tests/m17_difficulty_validation_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M17_PROBE PASS: canonical Sunny Cove loads in FULL validation mode
M17_PROBE PASS: canonical Sunny Cove has 100 levels
M17_PROBE PASS: L1 objective cost is 16
M17_PROBE PASS: L100 objective cost is 240
M17_PROBE PASS: VIP cost is separate
M17_PROBE PASS: expected L1-equivalent spawn value is 7/3
M17_PROBE PASS: timer exposes named calibration
M17_PROBE PASS: timer calibration override changes raw and target time
M17_PROBE PASS: percentile uses deterministic R7 interpolation
M17_PROBE PASS: telemetry schema is complete
M17_PROBE PASS: same-level left target shifts action left
M17_PROBE PASS: same-level right target shifts action right
M17_PROBE PASS: left-side congestion selects a safer non-left lane
M17_PROBE PASS: identical board state produces identical action
M17_PROBE PASS: policy has no future-RNG input
M17_PROBE PASS: policy returns a legal horizontal bucket
M17_PROBE PASS: fixture GameManager is ready
M17_PROBE PASS: fixture campaign bridge starts
OYUN BITTI - Skor: 0
M17_PROBE PASS: danger fixture uses production danger-line/game-over path
M17_PROBE PASS: TABLE_DANGER fixture terminal reason is preserved
M17_PROBE PASS: TABLE_DANGER fixture outcome is danger
M17_PROBE PASS: TABLE_DANGER fixture is not timeout
M17_PROBE PASS: fixture GameManager is ready
M17_PROBE PASS: fixture campaign bridge starts
M17_PROBE PASS: timeout fixture expires the production campaign timer
M17_PROBE PASS: TIMEOUT fixture outcome is timeout and not danger
M17_PROBE PASS: controlled near-rail footprint creates one proxy event
M17_PROBE PASS: continuous proximity does not inflate the same edge event
M17_PROBE PASS: centered footprint does not create a false rail event
M17_PROBE PASS: release beyond 3px then re-entry creates a second event
M17_PROBE PASS: qualification runner policy time scale is canonical
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
M17_PROBE PASS: same seed produces the same action log
M17_PROBE PASS: same seed preserves logical outcome
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x2 +25  (toplam: 175)
MERGE L2 +20  COMBO x3 +10  (toplam: 205)
MERGE L3 +50  COMBO x1 +0  (toplam: 255)
MERGE L4 +100  COMBO x2 +25  (toplam: 380)
MERGE L2 +20  COMBO x1 +0  (toplam: 400)
MERGE L4 +100  COMBO x2 +25  (toplam: 525)
MERGE L4 +100  COMBO x1 +0  (toplam: 625)
MERGE L5 +200  COMBO x2 +50  (toplam: 875)
TO-GO ORDER L5 +0  (toplam: 875)
M17_PROBE PASS: exact action-log replay preserves logical result
MERGE L3 +50  COMBO x1 +0  (toplam: 50)
MERGE L4 +100  COMBO x1 +0  (toplam: 150)
MERGE L3 +50  COMBO x2 +13  (toplam: 213)
MERGE L4 +100  COMBO x3 +50  (toplam: 363)
MERGE L3 +50  COMBO x1 +0  (toplam: 413)
MERGE L4 +100  COMBO x1 +0  (toplam: 513)
MERGE L4 +100  COMBO x2 +25  (toplam: 638)
MERGE L2 +20  COMBO x1 +0  (toplam: 658)
MERGE L4 +100  COMBO x1 +0  (toplam: 758)
MERGE L5 +200  COMBO x2 +50  (toplam: 1008)
TO-GO ORDER L5 +0  (toplam: 1008)
M17_PROBE PASS: different seed changes the seeded action sequence
M17_PROBE PASS: focused trial telemetry validates
M17_PROBE PASS: merge-aware actions carry decision evidence
M17_PROBE PASS: canonical Sunny Cove JSON is byte-for-byte unchanged
M17_DIFFICULTY_VALIDATION_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M17_DIFFICULTY_VALIDATION_RESULT=PASS
REQUIRED_MARKER_PRESENT=True

### 05-M16-SUNNY-COVE
COMMAND=godot_console.exe --headless --path . --script res://tests/m16_sunny_cove_content_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M16_PROBE PASS: approved expected table contains 100 timers
M16_PROBE PASS: approved expected table contains 100 costs
M16_PROBE PASS: approved expected table contains 100 order rows
M16_PROBE PASS: canonical Sunny Cove loads in FULL validation mode
M16_PROBE PASS: Sunny Cove declares 100 levels
M16_PROBE PASS: canonical Sunny Cove has exactly 100 loaded levels
M16_PROBE PASS: exactly 25 VIP levels are configured
M16_PROBE PASS: L1 id is sequential
M16_PROBE PASS: L1 island reference is Sunny Cove
M16_PROBE PASS: L1 matches the approved normal objective row
M16_PROBE PASS: L1 matches the approved timer row
M16_PROBE PASS: L1 matches the approved merge-cost row
M16_PROBE PASS: L1 normal targets stay within L5-L8
M16_PROBE PASS: L1 is non-VIP with neutral payload
M16_PROBE PASS: L1 normal objective cost follows the merge model
M16_PROBE PASS: L2 id is sequential
M16_PROBE PASS: L2 island reference is Sunny Cove
M16_PROBE PASS: L2 matches the approved normal objective row
M16_PROBE PASS: L2 matches the approved timer row
M16_PROBE PASS: L2 matches the approved merge-cost row
M16_PROBE PASS: L2 normal targets stay within L5-L8
M16_PROBE PASS: L2 is non-VIP with neutral payload
M16_PROBE PASS: L2 normal objective cost follows the merge model
M16_PROBE PASS: L3 id is sequential
M16_PROBE PASS: L3 island reference is Sunny Cove
M16_PROBE PASS: L3 matches the approved normal objective row
M16_PROBE PASS: L3 matches the approved timer row
M16_PROBE PASS: L3 matches the approved merge-cost row
M16_PROBE PASS: L3 normal targets stay within L5-L8
M16_PROBE PASS: L3 is non-VIP with neutral payload
M16_PROBE PASS: L3 normal objective cost follows the merge model
M16_PROBE PASS: L4 id is sequential
M16_PROBE PASS: L4 island reference is Sunny Cove
M16_PROBE PASS: L4 matches the approved normal objective row
M16_PROBE PASS: L4 matches the approved timer row
M16_PROBE PASS: L4 matches the approved merge-cost row
M16_PROBE PASS: L4 normal targets stay within L5-L8
M16_PROBE PASS: L4 exact VIP target and quantity
M16_PROBE PASS: L4 exact VIP reward
M16_PROBE PASS: L4 VIP workload ratio follows owner policy
M16_PROBE PASS: L4 VIP feature flag is enabled
M16_PROBE PASS: L4 normal objective cost follows the merge model
M16_PROBE PASS: L5 id is sequential
M16_PROBE PASS: L5 island reference is Sunny Cove
M16_PROBE PASS: L5 matches the approved normal objective row
M16_PROBE PASS: L5 matches the approved timer row
M16_PROBE PASS: L5 matches the approved merge-cost row
M16_PROBE PASS: L5 normal targets stay within L5-L8
M16_PROBE PASS: L5 is non-VIP with neutral payload
M16_PROBE PASS: L5 normal objective cost follows the merge model
M16_PROBE PASS: L6 id is sequential
M16_PROBE PASS: L6 island reference is Sunny Cove
M16_PROBE PASS: L6 matches the approved normal objective row
M16_PROBE PASS: L6 matches the approved timer row
M16_PROBE PASS: L6 matches the approved merge-cost row
M16_PROBE PASS: L6 normal targets stay within L5-L8
M16_PROBE PASS: L6 is non-VIP with neutral payload
M16_PROBE PASS: L6 normal objective cost follows the merge model
M16_PROBE PASS: L7 id is sequential
M16_PROBE PASS: L7 island reference is Sunny Cove
M16_PROBE PASS: L7 matches the approved normal objective row
M16_PROBE PASS: L7 matches the approved timer row
M16_PROBE PASS: L7 matches the approved merge-cost row
M16_PROBE PASS: L7 normal targets stay within L5-L8
M16_PROBE PASS: L7 is non-VIP with neutral payload
M16_PROBE PASS: L7 normal objective cost follows the merge model
M16_PROBE PASS: L8 id is sequential
M16_PROBE PASS: L8 island reference is Sunny Cove
M16_PROBE PASS: L8 matches the approved normal objective row
M16_PROBE PASS: L8 matches the approved timer row
M16_PROBE PASS: L8 matches the approved merge-cost row
M16_PROBE PASS: L8 normal targets stay within L5-L8
M16_PROBE PASS: L8 exact VIP target and quantity
M16_PROBE PASS: L8 exact VIP reward
M16_PROBE PASS: L8 VIP workload ratio follows owner policy
M16_PROBE PASS: L8 VIP feature flag is enabled
M16_PROBE PASS: L8 normal objective cost follows the merge model
M16_PROBE PASS: L9 id is sequential
M16_PROBE PASS: L9 island reference is Sunny Cove
M16_PROBE PASS: L9 matches the approved normal objective row
M16_PROBE PASS: L9 matches the approved timer row
M16_PROBE PASS: L9 matches the approved merge-cost row
M16_PROBE PASS: L9 normal targets stay within L5-L8
M16_PROBE PASS: L9 is non-VIP with neutral payload
M16_PROBE PASS: L9 normal objective cost follows the merge model
M16_PROBE PASS: L10 id is sequential
M16_PROBE PASS: L10 island reference is Sunny Cove
M16_PROBE PASS: L10 matches the approved normal objective row
M16_PROBE PASS: L10 matches the approved timer row
M16_PROBE PASS: L10 matches the approved merge-cost row
M16_PROBE PASS: L10 normal targets stay within L5-L8
M16_PROBE PASS: L10 is non-VIP with neutral payload
M16_PROBE PASS: L10 normal objective cost follows the merge model
M16_PROBE PASS: L11 id is sequential
M16_PROBE PASS: L11 island reference is Sunny Cove
M16_PROBE PASS: L11 matches the approved normal objective row
M16_PROBE PASS: L11 matches the approved timer row
M16_PROBE PASS: L11 matches the approved merge-cost row
M16_PROBE PASS: L11 normal targets stay within L5-L8
M16_PROBE PASS: L11 is non-VIP with neutral payload
M16_PROBE PASS: L11 normal objective cost follows the merge model
M16_PROBE PASS: L12 id is sequential
M16_PROBE PASS: L12 island reference is Sunny Cove
M16_PROBE PASS: L12 matches the approved normal objective row
M16_PROBE PASS: L12 matches the approved timer row
M16_PROBE PASS: L12 matches the approved merge-cost row
M16_PROBE PASS: L12 normal targets stay within L5-L8
M16_PROBE PASS: L12 exact VIP target and quantity
M16_PROBE PASS: L12 exact VIP reward
M16_PROBE PASS: L12 VIP workload ratio follows owner policy
M16_PROBE PASS: L12 VIP feature flag is enabled
M16_PROBE PASS: L12 normal objective cost follows the merge model
M16_PROBE PASS: L13 id is sequential
M16_PROBE PASS: L13 island reference is Sunny Cove
M16_PROBE PASS: L13 matches the approved normal objective row
M16_PROBE PASS: L13 matches the approved timer row
M16_PROBE PASS: L13 matches the approved merge-cost row
M16_PROBE PASS: L13 normal targets stay within L5-L8
M16_PROBE PASS: L13 is non-VIP with neutral payload
M16_PROBE PASS: L13 normal objective cost follows the merge model
M16_PROBE PASS: L14 id is sequential
M16_PROBE PASS: L14 island reference is Sunny Cove
M16_PROBE PASS: L14 matches the approved normal objective row
M16_PROBE PASS: L14 matches the approved timer row
M16_PROBE PASS: L14 matches the approved merge-cost row
M16_PROBE PASS: L14 normal targets stay within L5-L8
M16_PROBE PASS: L14 is non-VIP with neutral payload
M16_PROBE PASS: L14 normal objective cost follows the merge model
M16_PROBE PASS: L15 id is sequential
M16_PROBE PASS: L15 island reference is Sunny Cove
M16_PROBE PASS: L15 matches the approved normal objective row
M16_PROBE PASS: L15 matches the approved timer row
M16_PROBE PASS: L15 matches the approved merge-cost row
M16_PROBE PASS: L15 normal targets stay within L5-L8
M16_PROBE PASS: L15 is non-VIP with neutral payload
M16_PROBE PASS: L15 normal objective cost follows the merge model
M16_PROBE PASS: L16 id is sequential
M16_PROBE PASS: L16 island reference is Sunny Cove
M16_PROBE PASS: L16 matches the approved normal objective row
M16_PROBE PASS: L16 matches the approved timer row
M16_PROBE PASS: L16 matches the approved merge-cost row
M16_PROBE PASS: L16 normal targets stay within L5-L8
M16_PROBE PASS: L16 exact VIP target and quantity
M16_PROBE PASS: L16 exact VIP reward
M16_PROBE PASS: L16 VIP workload ratio follows owner policy
M16_PROBE PASS: L16 VIP feature flag is enabled
M16_PROBE PASS: L16 normal objective cost follows the merge model
M16_PROBE PASS: L17 id is sequential
M16_PROBE PASS: L17 island reference is Sunny Cove
M16_PROBE PASS: L17 matches the approved normal objective row
M16_PROBE PASS: L17 matches the approved timer row
M16_PROBE PASS: L17 matches the approved merge-cost row
M16_PROBE PASS: L17 normal targets stay within L5-L8
M16_PROBE PASS: L17 is non-VIP with neutral payload
M16_PROBE PASS: L17 normal objective cost follows the merge model
M16_PROBE PASS: L18 id is sequential
M16_PROBE PASS: L18 island reference is Sunny Cove
M16_PROBE PASS: L18 matches the approved normal objective row
M16_PROBE PASS: L18 matches the approved timer row
M16_PROBE PASS: L18 matches the approved merge-cost row
M16_PROBE PASS: L18 normal targets stay within L5-L8
M16_PROBE PASS: L18 is non-VIP with neutral payload
M16_PROBE PASS: L18 normal objective cost follows the merge model
M16_PROBE PASS: L19 id is sequential
M16_PROBE PASS: L19 island reference is Sunny Cove
M16_PROBE PASS: L19 matches the approved normal objective row
M16_PROBE PASS: L19 matches the approved timer row
M16_PROBE PASS: L19 matches the approved merge-cost row
M16_PROBE PASS: L19 normal targets stay within L5-L8
M16_PROBE PASS: L19 is non-VIP with neutral payload
M16_PROBE PASS: L19 normal objective cost follows the merge model
M16_PROBE PASS: L20 id is sequential
M16_PROBE PASS: L20 island reference is Sunny Cove
M16_PROBE PASS: L20 matches the approved normal objective row
M16_PROBE PASS: L20 matches the approved timer row
M16_PROBE PASS: L20 matches the approved merge-cost row
M16_PROBE PASS: L20 normal targets stay within L5-L8
M16_PROBE PASS: L20 exact VIP target and quantity
M16_PROBE PASS: L20 exact VIP reward
M16_PROBE PASS: L20 VIP workload ratio follows owner policy
M16_PROBE PASS: L20 VIP feature flag is enabled
M16_PROBE PASS: L20 normal objective cost follows the merge model
M16_PROBE PASS: L21 id is sequential
M16_PROBE PASS: L21 island reference is Sunny Cove
M16_PROBE PASS: L21 matches the approved normal objective row
M16_PROBE PASS: L21 matches the approved timer row
M16_PROBE PASS: L21 matches the approved merge-cost row
M16_PROBE PASS: L21 normal targets stay within L5-L8
M16_PROBE PASS: L21 is non-VIP with neutral payload
M16_PROBE PASS: L21 normal objective cost follows the merge model
M16_PROBE PASS: L22 id is sequential
M16_PROBE PASS: L22 island reference is Sunny Cove
M16_PROBE PASS: L22 matches the approved normal objective row
M16_PROBE PASS: L22 matches the approved timer row
M16_PROBE PASS: L22 matches the approved merge-cost row
M16_PROBE PASS: L22 normal targets stay within L5-L8
M16_PROBE PASS: L22 is non-VIP with neutral payload
M16_PROBE PASS: L22 normal objective cost follows the merge model
M16_PROBE PASS: L23 id is sequential
M16_PROBE PASS: L23 island reference is Sunny Cove
M16_PROBE PASS: L23 matches the approved normal objective row
M16_PROBE PASS: L23 matches the approved timer row
M16_PROBE PASS: L23 matches the approved merge-cost row
M16_PROBE PASS: L23 normal targets stay within L5-L8
M16_PROBE PASS: L23 is non-VIP with neutral payload
M16_PROBE PASS: L23 normal objective cost follows the merge model
M16_PROBE PASS: L24 id is sequential
M16_PROBE PASS: L24 island reference is Sunny Cove
M16_PROBE PASS: L24 matches the approved normal objective row
M16_PROBE PASS: L24 matches the approved timer row
M16_PROBE PASS: L24 matches the approved merge-cost row
M16_PROBE PASS: L24 normal targets stay within L5-L8
M16_PROBE PASS: L24 exact VIP target and quantity
M16_PROBE PASS: L24 exact VIP reward
M16_PROBE PASS: L24 VIP workload ratio follows owner policy
M16_PROBE PASS: L24 VIP feature flag is enabled
M16_PROBE PASS: L24 normal objective cost follows the merge model
M16_PROBE PASS: L25 id is sequential
M16_PROBE PASS: L25 island reference is Sunny Cove
M16_PROBE PASS: L25 matches the approved normal objective row
M16_PROBE PASS: L25 matches the approved timer row
M16_PROBE PASS: L25 matches the approved merge-cost row
M16_PROBE PASS: L25 normal targets stay within L5-L8
M16_PROBE PASS: L25 is non-VIP with neutral payload
M16_PROBE PASS: L25 normal objective cost follows the merge model
M16_PROBE PASS: L26 id is sequential
M16_PROBE PASS: L26 island reference is Sunny Cove
M16_PROBE PASS: L26 matches the approved normal objective row
M16_PROBE PASS: L26 matches the approved timer row
M16_PROBE PASS: L26 matches the approved merge-cost row
M16_PROBE PASS: L26 normal targets stay within L5-L8
M16_PROBE PASS: L26 is non-VIP with neutral payload
M16_PROBE PASS: L26 normal objective cost follows the merge model
M16_PROBE PASS: L27 id is sequential
M16_PROBE PASS: L27 island reference is Sunny Cove
M16_PROBE PASS: L27 matches the approved normal objective row
M16_PROBE PASS: L27 matches the approved timer row
M16_PROBE PASS: L27 matches the approved merge-cost row
M16_PROBE PASS: L27 normal targets stay within L5-L8
M16_PROBE PASS: L27 is non-VIP with neutral payload
M16_PROBE PASS: L27 normal objective cost follows the merge model
M16_PROBE PASS: L28 id is sequential
M16_PROBE PASS: L28 island reference is Sunny Cove
M16_PROBE PASS: L28 matches the approved normal objective row
M16_PROBE PASS: L28 matches the approved timer row
M16_PROBE PASS: L28 matches the approved merge-cost row
M16_PROBE PASS: L28 normal targets stay within L5-L8
M16_PROBE PASS: L28 exact VIP target and quantity
M16_PROBE PASS: L28 exact VIP reward
M16_PROBE PASS: L28 VIP workload ratio follows owner policy
M16_PROBE PASS: L28 VIP feature flag is enabled
M16_PROBE PASS: L28 normal objective cost follows the merge model
M16_PROBE PASS: L29 id is sequential
M16_PROBE PASS: L29 island reference is Sunny Cove
M16_PROBE PASS: L29 matches the approved normal objective row
M16_PROBE PASS: L29 matches the approved timer row
M16_PROBE PASS: L29 matches the approved merge-cost row
M16_PROBE PASS: L29 normal targets stay within L5-L8
M16_PROBE PASS: L29 is non-VIP with neutral payload
M16_PROBE PASS: L29 normal objective cost follows the merge model
M16_PROBE PASS: L30 id is sequential
M16_PROBE PASS: L30 island reference is Sunny Cove
M16_PROBE PASS: L30 matches the approved normal objective row
M16_PROBE PASS: L30 matches the approved timer row
M16_PROBE PASS: L30 matches the approved merge-cost row
M16_PROBE PASS: L30 normal targets stay within L5-L8
M16_PROBE PASS: L30 is non-VIP with neutral payload
M16_PROBE PASS: L30 normal objective cost follows the merge model
M16_PROBE PASS: L31 id is sequential
M16_PROBE PASS: L31 island reference is Sunny Cove
M16_PROBE PASS: L31 matches the approved normal objective row
M16_PROBE PASS: L31 matches the approved timer row
M16_PROBE PASS: L31 matches the approved merge-cost row
M16_PROBE PASS: L31 normal targets stay within L5-L8
M16_PROBE PASS: L31 is non-VIP with neutral payload
M16_PROBE PASS: L31 normal objective cost follows the merge model
M16_PROBE PASS: L32 id is sequential
M16_PROBE PASS: L32 island reference is Sunny Cove
M16_PROBE PASS: L32 matches the approved normal objective row
M16_PROBE PASS: L32 matches the approved timer row
M16_PROBE PASS: L32 matches the approved merge-cost row
M16_PROBE PASS: L32 normal targets stay within L5-L8
M16_PROBE PASS: L32 exact VIP target and quantity
M16_PROBE PASS: L32 exact VIP reward
M16_PROBE PASS: L32 VIP workload ratio follows owner policy
M16_PROBE PASS: L32 VIP feature flag is enabled
M16_PROBE PASS: L32 normal objective cost follows the merge model
M16_PROBE PASS: L33 id is sequential
M16_PROBE PASS: L33 island reference is Sunny Cove
M16_PROBE PASS: L33 matches the approved normal objective row
M16_PROBE PASS: L33 matches the approved timer row
M16_PROBE PASS: L33 matches the approved merge-cost row
M16_PROBE PASS: L33 normal targets stay within L5-L8
M16_PROBE PASS: L33 is non-VIP with neutral payload
M16_PROBE PASS: L33 normal objective cost follows the merge model
M16_PROBE PASS: L34 id is sequential
M16_PROBE PASS: L34 island reference is Sunny Cove
M16_PROBE PASS: L34 matches the approved normal objective row
M16_PROBE PASS: L34 matches the approved timer row
M16_PROBE PASS: L34 matches the approved merge-cost row
M16_PROBE PASS: L34 normal targets stay within L5-L8
M16_PROBE PASS: L34 is non-VIP with neutral payload
M16_PROBE PASS: L34 normal objective cost follows the merge model
M16_PROBE PASS: L35 id is sequential
M16_PROBE PASS: L35 island reference is Sunny Cove
M16_PROBE PASS: L35 matches the approved normal objective row
M16_PROBE PASS: L35 matches the approved timer row
M16_PROBE PASS: L35 matches the approved merge-cost row
M16_PROBE PASS: L35 normal targets stay within L5-L8
M16_PROBE PASS: L35 is non-VIP with neutral payload
M16_PROBE PASS: L35 normal objective cost follows the merge model
M16_PROBE PASS: L36 id is sequential
M16_PROBE PASS: L36 island reference is Sunny Cove
M16_PROBE PASS: L36 matches the approved normal objective row
M16_PROBE PASS: L36 matches the approved timer row
M16_PROBE PASS: L36 matches the approved merge-cost row
M16_PROBE PASS: L36 normal targets stay within L5-L8
M16_PROBE PASS: L36 exact VIP target and quantity
M16_PROBE PASS: L36 exact VIP reward
M16_PROBE PASS: L36 VIP workload ratio follows owner policy
M16_PROBE PASS: L36 VIP feature flag is enabled
M16_PROBE PASS: L36 normal objective cost follows the merge model
M16_PROBE PASS: L37 id is sequential
M16_PROBE PASS: L37 island reference is Sunny Cove
M16_PROBE PASS: L37 matches the approved normal objective row
M16_PROBE PASS: L37 matches the approved timer row
M16_PROBE PASS: L37 matches the approved merge-cost row
M16_PROBE PASS: L37 normal targets stay within L5-L8
M16_PROBE PASS: L37 is non-VIP with neutral payload
M16_PROBE PASS: L37 normal objective cost follows the merge model
M16_PROBE PASS: L38 id is sequential
M16_PROBE PASS: L38 island reference is Sunny Cove
M16_PROBE PASS: L38 matches the approved normal objective row
M16_PROBE PASS: L38 matches the approved timer row
M16_PROBE PASS: L38 matches the approved merge-cost row
M16_PROBE PASS: L38 normal targets stay within L5-L8
M16_PROBE PASS: L38 is non-VIP with neutral payload
M16_PROBE PASS: L38 normal objective cost follows the merge model
M16_PROBE PASS: L39 id is sequential
M16_PROBE PASS: L39 island reference is Sunny Cove
M16_PROBE PASS: L39 matches the approved normal objective row
M16_PROBE PASS: L39 matches the approved timer row
M16_PROBE PASS: L39 matches the approved merge-cost row
M16_PROBE PASS: L39 normal targets stay within L5-L8
M16_PROBE PASS: L39 is non-VIP with neutral payload
M16_PROBE PASS: L39 normal objective cost follows the merge model
M16_PROBE PASS: L40 id is sequential
M16_PROBE PASS: L40 island reference is Sunny Cove
M16_PROBE PASS: L40 matches the approved normal objective row
M16_PROBE PASS: L40 matches the approved timer row
M16_PROBE PASS: L40 matches the approved merge-cost row
M16_PROBE PASS: L40 normal targets stay within L5-L8
M16_PROBE PASS: L40 exact VIP target and quantity
M16_PROBE PASS: L40 exact VIP reward
M16_PROBE PASS: L40 VIP workload ratio follows owner policy
M16_PROBE PASS: L40 VIP feature flag is enabled
M16_PROBE PASS: L40 normal objective cost follows the merge model
M16_PROBE PASS: L41 id is sequential
M16_PROBE PASS: L41 island reference is Sunny Cove
M16_PROBE PASS: L41 matches the approved normal objective row
M16_PROBE PASS: L41 matches the approved timer row
M16_PROBE PASS: L41 matches the approved merge-cost row
M16_PROBE PASS: L41 normal targets stay within L5-L8
M16_PROBE PASS: L41 is non-VIP with neutral payload
M16_PROBE PASS: L41 normal objective cost follows the merge model
M16_PROBE PASS: L42 id is sequential
M16_PROBE PASS: L42 island reference is Sunny Cove
M16_PROBE PASS: L42 matches the approved normal objective row
M16_PROBE PASS: L42 matches the approved timer row
M16_PROBE PASS: L42 matches the approved merge-cost row
M16_PROBE PASS: L42 normal targets stay within L5-L8
M16_PROBE PASS: L42 is non-VIP with neutral payload
M16_PROBE PASS: L42 normal objective cost follows the merge model
M16_PROBE PASS: L43 id is sequential
M16_PROBE PASS: L43 island reference is Sunny Cove
M16_PROBE PASS: L43 matches the approved normal objective row
M16_PROBE PASS: L43 matches the approved timer row
M16_PROBE PASS: L43 matches the approved merge-cost row
M16_PROBE PASS: L43 normal targets stay within L5-L8
M16_PROBE PASS: L43 is non-VIP with neutral payload
M16_PROBE PASS: L43 normal objective cost follows the merge model
M16_PROBE PASS: L44 id is sequential
M16_PROBE PASS: L44 island reference is Sunny Cove
M16_PROBE PASS: L44 matches the approved normal objective row
M16_PROBE PASS: L44 matches the approved timer row
M16_PROBE PASS: L44 matches the approved merge-cost row
M16_PROBE PASS: L44 normal targets stay within L5-L8
M16_PROBE PASS: L44 exact VIP target and quantity
M16_PROBE PASS: L44 exact VIP reward
M16_PROBE PASS: L44 VIP workload ratio follows owner policy
M16_PROBE PASS: L44 VIP feature flag is enabled
M16_PROBE PASS: L44 normal objective cost follows the merge model
M16_PROBE PASS: L45 id is sequential
M16_PROBE PASS: L45 island reference is Sunny Cove
M16_PROBE PASS: L45 matches the approved normal objective row
M16_PROBE PASS: L45 matches the approved timer row
M16_PROBE PASS: L45 matches the approved merge-cost row
M16_PROBE PASS: L45 normal targets stay within L5-L8
M16_PROBE PASS: L45 is non-VIP with neutral payload
M16_PROBE PASS: L45 normal objective cost follows the merge model
M16_PROBE PASS: L46 id is sequential
M16_PROBE PASS: L46 island reference is Sunny Cove
M16_PROBE PASS: L46 matches the approved normal objective row
M16_PROBE PASS: L46 matches the approved timer row
M16_PROBE PASS: L46 matches the approved merge-cost row
M16_PROBE PASS: L46 normal targets stay within L5-L8
M16_PROBE PASS: L46 is non-VIP with neutral payload
M16_PROBE PASS: L46 normal objective cost follows the merge model
M16_PROBE PASS: L47 id is sequential
M16_PROBE PASS: L47 island reference is Sunny Cove
M16_PROBE PASS: L47 matches the approved normal objective row
M16_PROBE PASS: L47 matches the approved timer row
M16_PROBE PASS: L47 matches the approved merge-cost row
M16_PROBE PASS: L47 normal targets stay within L5-L8
M16_PROBE PASS: L47 is non-VIP with neutral payload
M16_PROBE PASS: L47 normal objective cost follows the merge model
M16_PROBE PASS: L48 id is sequential
M16_PROBE PASS: L48 island reference is Sunny Cove
M16_PROBE PASS: L48 matches the approved normal objective row
M16_PROBE PASS: L48 matches the approved timer row
M16_PROBE PASS: L48 matches the approved merge-cost row
M16_PROBE PASS: L48 normal targets stay within L5-L8
M16_PROBE PASS: L48 exact VIP target and quantity
M16_PROBE PASS: L48 exact VIP reward
M16_PROBE PASS: L48 VIP workload ratio follows owner policy
M16_PROBE PASS: L48 VIP feature flag is enabled
M16_PROBE PASS: L48 normal objective cost follows the merge model
M16_PROBE PASS: L49 id is sequential
M16_PROBE PASS: L49 island reference is Sunny Cove
M16_PROBE PASS: L49 matches the approved normal objective row
M16_PROBE PASS: L49 matches the approved timer row
M16_PROBE PASS: L49 matches the approved merge-cost row
M16_PROBE PASS: L49 normal targets stay within L5-L8
M16_PROBE PASS: L49 is non-VIP with neutral payload
M16_PROBE PASS: L49 normal objective cost follows the merge model
M16_PROBE PASS: L50 id is sequential
M16_PROBE PASS: L50 island reference is Sunny Cove
M16_PROBE PASS: L50 matches the approved normal objective row
M16_PROBE PASS: L50 matches the approved timer row
M16_PROBE PASS: L50 matches the approved merge-cost row
M16_PROBE PASS: L50 normal targets stay within L5-L8
M16_PROBE PASS: L50 is non-VIP with neutral payload
M16_PROBE PASS: L50 normal objective cost follows the merge model
M16_PROBE PASS: L51 id is sequential
M16_PROBE PASS: L51 island reference is Sunny Cove
M16_PROBE PASS: L51 matches the approved normal objective row
M16_PROBE PASS: L51 matches the approved timer row
M16_PROBE PASS: L51 matches the approved merge-cost row
M16_PROBE PASS: L51 normal targets stay within L5-L8
M16_PROBE PASS: L51 is non-VIP with neutral payload
M16_PROBE PASS: L51 normal objective cost follows the merge model
M16_PROBE PASS: L52 id is sequential
M16_PROBE PASS: L52 island reference is Sunny Cove
M16_PROBE PASS: L52 matches the approved normal objective row
M16_PROBE PASS: L52 matches the approved timer row
M16_PROBE PASS: L52 matches the approved merge-cost row
M16_PROBE PASS: L52 normal targets stay within L5-L8
M16_PROBE PASS: L52 exact VIP target and quantity
M16_PROBE PASS: L52 exact VIP reward
M16_PROBE PASS: L52 VIP workload ratio follows owner policy
M16_PROBE PASS: L52 VIP feature flag is enabled
M16_PROBE PASS: L52 normal objective cost follows the merge model
M16_PROBE PASS: L53 id is sequential
M16_PROBE PASS: L53 island reference is Sunny Cove
M16_PROBE PASS: L53 matches the approved normal objective row
M16_PROBE PASS: L53 matches the approved timer row
M16_PROBE PASS: L53 matches the approved merge-cost row
M16_PROBE PASS: L53 normal targets stay within L5-L8
M16_PROBE PASS: L53 is non-VIP with neutral payload
M16_PROBE PASS: L53 normal objective cost follows the merge model
M16_PROBE PASS: L54 id is sequential
M16_PROBE PASS: L54 island reference is Sunny Cove
M16_PROBE PASS: L54 matches the approved normal objective row
M16_PROBE PASS: L54 matches the approved timer row
M16_PROBE PASS: L54 matches the approved merge-cost row
M16_PROBE PASS: L54 normal targets stay within L5-L8
M16_PROBE PASS: L54 is non-VIP with neutral payload
M16_PROBE PASS: L54 normal objective cost follows the merge model
M16_PROBE PASS: L55 id is sequential
M16_PROBE PASS: L55 island reference is Sunny Cove
M16_PROBE PASS: L55 matches the approved normal objective row
M16_PROBE PASS: L55 matches the approved timer row
M16_PROBE PASS: L55 matches the approved merge-cost row
M16_PROBE PASS: L55 normal targets stay within L5-L8
M16_PROBE PASS: L55 is non-VIP with neutral payload
M16_PROBE PASS: L55 normal objective cost follows the merge model
M16_PROBE PASS: L56 id is sequential
M16_PROBE PASS: L56 island reference is Sunny Cove
M16_PROBE PASS: L56 matches the approved normal objective row
M16_PROBE PASS: L56 matches the approved timer row
M16_PROBE PASS: L56 matches the approved merge-cost row
M16_PROBE PASS: L56 normal targets stay within L5-L8
M16_PROBE PASS: L56 exact VIP target and quantity
M16_PROBE PASS: L56 exact VIP reward
M16_PROBE PASS: L56 VIP workload ratio follows owner policy
M16_PROBE PASS: L56 VIP feature flag is enabled
M16_PROBE PASS: L56 normal objective cost follows the merge model
M16_PROBE PASS: L57 id is sequential
M16_PROBE PASS: L57 island reference is Sunny Cove
M16_PROBE PASS: L57 matches the approved normal objective row
M16_PROBE PASS: L57 matches the approved timer row
M16_PROBE PASS: L57 matches the approved merge-cost row
M16_PROBE PASS: L57 normal targets stay within L5-L8
M16_PROBE PASS: L57 is non-VIP with neutral payload
M16_PROBE PASS: L57 normal objective cost follows the merge model
M16_PROBE PASS: L58 id is sequential
M16_PROBE PASS: L58 island reference is Sunny Cove
M16_PROBE PASS: L58 matches the approved normal objective row
M16_PROBE PASS: L58 matches the approved timer row
M16_PROBE PASS: L58 matches the approved merge-cost row
M16_PROBE PASS: L58 normal targets stay within L5-L8
M16_PROBE PASS: L58 is non-VIP with neutral payload
M16_PROBE PASS: L58 normal objective cost follows the merge model
M16_PROBE PASS: L59 id is sequential
M16_PROBE PASS: L59 island reference is Sunny Cove
M16_PROBE PASS: L59 matches the approved normal objective row
M16_PROBE PASS: L59 matches the approved timer row
M16_PROBE PASS: L59 matches the approved merge-cost row
M16_PROBE PASS: L59 normal targets stay within L5-L8
M16_PROBE PASS: L59 is non-VIP with neutral payload
M16_PROBE PASS: L59 normal objective cost follows the merge model
M16_PROBE PASS: L60 id is sequential
M16_PROBE PASS: L60 island reference is Sunny Cove
M16_PROBE PASS: L60 matches the approved normal objective row
M16_PROBE PASS: L60 matches the approved timer row
M16_PROBE PASS: L60 matches the approved merge-cost row
M16_PROBE PASS: L60 normal targets stay within L5-L8
M16_PROBE PASS: L60 exact VIP target and quantity
M16_PROBE PASS: L60 exact VIP reward
M16_PROBE PASS: L60 VIP workload ratio follows owner policy
M16_PROBE PASS: L60 VIP feature flag is enabled
M16_PROBE PASS: L60 normal objective cost follows the merge model
M16_PROBE PASS: L61 id is sequential
M16_PROBE PASS: L61 island reference is Sunny Cove
M16_PROBE PASS: L61 matches the approved normal objective row
M16_PROBE PASS: L61 matches the approved timer row
M16_PROBE PASS: L61 matches the approved merge-cost row
M16_PROBE PASS: L61 normal targets stay within L5-L8
M16_PROBE PASS: L61 is non-VIP with neutral payload
M16_PROBE PASS: L61 normal objective cost follows the merge model
M16_PROBE PASS: L62 id is sequential
M16_PROBE PASS: L62 island reference is Sunny Cove
M16_PROBE PASS: L62 matches the approved normal objective row
M16_PROBE PASS: L62 matches the approved timer row
M16_PROBE PASS: L62 matches the approved merge-cost row
M16_PROBE PASS: L62 normal targets stay within L5-L8
M16_PROBE PASS: L62 is non-VIP with neutral payload
M16_PROBE PASS: L62 normal objective cost follows the merge model
M16_PROBE PASS: L63 id is sequential
M16_PROBE PASS: L63 island reference is Sunny Cove
M16_PROBE PASS: L63 matches the approved normal objective row
M16_PROBE PASS: L63 matches the approved timer row
M16_PROBE PASS: L63 matches the approved merge-cost row
M16_PROBE PASS: L63 normal targets stay within L5-L8
M16_PROBE PASS: L63 is non-VIP with neutral payload
M16_PROBE PASS: L63 normal objective cost follows the merge model
M16_PROBE PASS: L64 id is sequential
M16_PROBE PASS: L64 island reference is Sunny Cove
M16_PROBE PASS: L64 matches the approved normal objective row
M16_PROBE PASS: L64 matches the approved timer row
M16_PROBE PASS: L64 matches the approved merge-cost row
M16_PROBE PASS: L64 normal targets stay within L5-L8
M16_PROBE PASS: L64 exact VIP target and quantity
M16_PROBE PASS: L64 exact VIP reward
M16_PROBE PASS: L64 VIP workload ratio follows owner policy
M16_PROBE PASS: L64 VIP feature flag is enabled
M16_PROBE PASS: L64 normal objective cost follows the merge model
M16_PROBE PASS: L65 id is sequential
M16_PROBE PASS: L65 island reference is Sunny Cove
M16_PROBE PASS: L65 matches the approved normal objective row
M16_PROBE PASS: L65 matches the approved timer row
M16_PROBE PASS: L65 matches the approved merge-cost row
M16_PROBE PASS: L65 normal targets stay within L5-L8
M16_PROBE PASS: L65 is non-VIP with neutral payload
M16_PROBE PASS: L65 normal objective cost follows the merge model
M16_PROBE PASS: L66 id is sequential
M16_PROBE PASS: L66 island reference is Sunny Cove
M16_PROBE PASS: L66 matches the approved normal objective row
M16_PROBE PASS: L66 matches the approved timer row
M16_PROBE PASS: L66 matches the approved merge-cost row
M16_PROBE PASS: L66 normal targets stay within L5-L8
M16_PROBE PASS: L66 is non-VIP with neutral payload
M16_PROBE PASS: L66 normal objective cost follows the merge model
M16_PROBE PASS: L67 id is sequential
M16_PROBE PASS: L67 island reference is Sunny Cove
M16_PROBE PASS: L67 matches the approved normal objective row
M16_PROBE PASS: L67 matches the approved timer row
M16_PROBE PASS: L67 matches the approved merge-cost row
M16_PROBE PASS: L67 normal targets stay within L5-L8
M16_PROBE PASS: L67 is non-VIP with neutral payload
M16_PROBE PASS: L67 normal objective cost follows the merge model
M16_PROBE PASS: L68 id is sequential
M16_PROBE PASS: L68 island reference is Sunny Cove
M16_PROBE PASS: L68 matches the approved normal objective row
M16_PROBE PASS: L68 matches the approved timer row
M16_PROBE PASS: L68 matches the approved merge-cost row
M16_PROBE PASS: L68 normal targets stay within L5-L8
M16_PROBE PASS: L68 exact VIP target and quantity
M16_PROBE PASS: L68 exact VIP reward
M16_PROBE PASS: L68 VIP workload ratio follows owner policy
M16_PROBE PASS: L68 VIP feature flag is enabled
M16_PROBE PASS: L68 normal objective cost follows the merge model
M16_PROBE PASS: L69 id is sequential
M16_PROBE PASS: L69 island reference is Sunny Cove
M16_PROBE PASS: L69 matches the approved normal objective row
M16_PROBE PASS: L69 matches the approved timer row
M16_PROBE PASS: L69 matches the approved merge-cost row
M16_PROBE PASS: L69 normal targets stay within L5-L8
M16_PROBE PASS: L69 is non-VIP with neutral payload
M16_PROBE PASS: L69 normal objective cost follows the merge model
M16_PROBE PASS: L70 id is sequential
M16_PROBE PASS: L70 island reference is Sunny Cove
M16_PROBE PASS: L70 matches the approved normal objective row
M16_PROBE PASS: L70 matches the approved timer row
M16_PROBE PASS: L70 matches the approved merge-cost row
M16_PROBE PASS: L70 normal targets stay within L5-L8
M16_PROBE PASS: L70 is non-VIP with neutral payload
M16_PROBE PASS: L70 normal objective cost follows the merge model
M16_PROBE PASS: L71 id is sequential
M16_PROBE PASS: L71 island reference is Sunny Cove
M16_PROBE PASS: L71 matches the approved normal objective row
M16_PROBE PASS: L71 matches the approved timer row
M16_PROBE PASS: L71 matches the approved merge-cost row
M16_PROBE PASS: L71 normal targets stay within L5-L8
M16_PROBE PASS: L71 is non-VIP with neutral payload
M16_PROBE PASS: L71 normal objective cost follows the merge model
M16_PROBE PASS: L72 id is sequential
M16_PROBE PASS: L72 island reference is Sunny Cove
M16_PROBE PASS: L72 matches the approved normal objective row
M16_PROBE PASS: L72 matches the approved timer row
M16_PROBE PASS: L72 matches the approved merge-cost row
M16_PROBE PASS: L72 normal targets stay within L5-L8
M16_PROBE PASS: L72 exact VIP target and quantity
M16_PROBE PASS: L72 exact VIP reward
M16_PROBE PASS: L72 VIP workload ratio follows owner policy
M16_PROBE PASS: L72 VIP feature flag is enabled
M16_PROBE PASS: L72 normal objective cost follows the merge model
M16_PROBE PASS: L73 id is sequential
M16_PROBE PASS: L73 island reference is Sunny Cove
M16_PROBE PASS: L73 matches the approved normal objective row
M16_PROBE PASS: L73 matches the approved timer row
M16_PROBE PASS: L73 matches the approved merge-cost row
M16_PROBE PASS: L73 normal targets stay within L5-L8
M16_PROBE PASS: L73 is non-VIP with neutral payload
M16_PROBE PASS: L73 normal objective cost follows the merge model
M16_PROBE PASS: L74 id is sequential
M16_PROBE PASS: L74 island reference is Sunny Cove
M16_PROBE PASS: L74 matches the approved normal objective row
M16_PROBE PASS: L74 matches the approved timer row
M16_PROBE PASS: L74 matches the approved merge-cost row
M16_PROBE PASS: L74 normal targets stay within L5-L8
M16_PROBE PASS: L74 is non-VIP with neutral payload
M16_PROBE PASS: L74 normal objective cost follows the merge model
M16_PROBE PASS: L75 id is sequential
M16_PROBE PASS: L75 island reference is Sunny Cove
M16_PROBE PASS: L75 matches the approved normal objective row
M16_PROBE PASS: L75 matches the approved timer row
M16_PROBE PASS: L75 matches the approved merge-cost row
M16_PROBE PASS: L75 normal targets stay within L5-L8
M16_PROBE PASS: L75 is non-VIP with neutral payload
M16_PROBE PASS: L75 normal objective cost follows the merge model
M16_PROBE PASS: L76 id is sequential
M16_PROBE PASS: L76 island reference is Sunny Cove
M16_PROBE PASS: L76 matches the approved normal objective row
M16_PROBE PASS: L76 matches the approved timer row
M16_PROBE PASS: L76 matches the approved merge-cost row
M16_PROBE PASS: L76 normal targets stay within L5-L8
M16_PROBE PASS: L76 exact VIP target and quantity
M16_PROBE PASS: L76 exact VIP reward
M16_PROBE PASS: L76 VIP workload ratio follows owner policy
M16_PROBE PASS: L76 VIP feature flag is enabled
M16_PROBE PASS: L76 normal objective cost follows the merge model
M16_PROBE PASS: L77 id is sequential
M16_PROBE PASS: L77 island reference is Sunny Cove
M16_PROBE PASS: L77 matches the approved normal objective row
M16_PROBE PASS: L77 matches the approved timer row
M16_PROBE PASS: L77 matches the approved merge-cost row
M16_PROBE PASS: L77 normal targets stay within L5-L8
M16_PROBE PASS: L77 is non-VIP with neutral payload
M16_PROBE PASS: L77 normal objective cost follows the merge model
M16_PROBE PASS: L78 id is sequential
M16_PROBE PASS: L78 island reference is Sunny Cove
M16_PROBE PASS: L78 matches the approved normal objective row
M16_PROBE PASS: L78 matches the approved timer row
M16_PROBE PASS: L78 matches the approved merge-cost row
M16_PROBE PASS: L78 normal targets stay within L5-L8
M16_PROBE PASS: L78 is non-VIP with neutral payload
M16_PROBE PASS: L78 normal objective cost follows the merge model
M16_PROBE PASS: L79 id is sequential
M16_PROBE PASS: L79 island reference is Sunny Cove
M16_PROBE PASS: L79 matches the approved normal objective row
M16_PROBE PASS: L79 matches the approved timer row
M16_PROBE PASS: L79 matches the approved merge-cost row
M16_PROBE PASS: L79 normal targets stay within L5-L8
M16_PROBE PASS: L79 is non-VIP with neutral payload
M16_PROBE PASS: L79 normal objective cost follows the merge model
M16_PROBE PASS: L80 id is sequential
M16_PROBE PASS: L80 island reference is Sunny Cove
M16_PROBE PASS: L80 matches the approved normal objective row
M16_PROBE PASS: L80 matches the approved timer row
M16_PROBE PASS: L80 matches the approved merge-cost row
M16_PROBE PASS: L80 normal targets stay within L5-L8
M16_PROBE PASS: L80 exact VIP target and quantity
M16_PROBE PASS: L80 exact VIP reward
M16_PROBE PASS: L80 VIP workload ratio follows owner policy
M16_PROBE PASS: L80 VIP feature flag is enabled
M16_PROBE PASS: L80 normal objective cost follows the merge model
M16_PROBE PASS: L81 id is sequential
M16_PROBE PASS: L81 island reference is Sunny Cove
M16_PROBE PASS: L81 matches the approved normal objective row
M16_PROBE PASS: L81 matches the approved timer row
M16_PROBE PASS: L81 matches the approved merge-cost row
M16_PROBE PASS: L81 normal targets stay within L5-L8
M16_PROBE PASS: L81 is non-VIP with neutral payload
M16_PROBE PASS: L81 normal objective cost follows the merge model
M16_PROBE PASS: L82 id is sequential
M16_PROBE PASS: L82 island reference is Sunny Cove
M16_PROBE PASS: L82 matches the approved normal objective row
M16_PROBE PASS: L82 matches the approved timer row
M16_PROBE PASS: L82 matches the approved merge-cost row
M16_PROBE PASS: L82 normal targets stay within L5-L8
M16_PROBE PASS: L82 is non-VIP with neutral payload
M16_PROBE PASS: L82 normal objective cost follows the merge model
M16_PROBE PASS: L83 id is sequential
M16_PROBE PASS: L83 island reference is Sunny Cove
M16_PROBE PASS: L83 matches the approved normal objective row
M16_PROBE PASS: L83 matches the approved timer row
M16_PROBE PASS: L83 matches the approved merge-cost row
M16_PROBE PASS: L83 normal targets stay within L5-L8
M16_PROBE PASS: L83 is non-VIP with neutral payload
M16_PROBE PASS: L83 normal objective cost follows the merge model
M16_PROBE PASS: L84 id is sequential
M16_PROBE PASS: L84 island reference is Sunny Cove
M16_PROBE PASS: L84 matches the approved normal objective row
M16_PROBE PASS: L84 matches the approved timer row
M16_PROBE PASS: L84 matches the approved merge-cost row
M16_PROBE PASS: L84 normal targets stay within L5-L8
M16_PROBE PASS: L84 exact VIP target and quantity
M16_PROBE PASS: L84 exact VIP reward
M16_PROBE PASS: L84 VIP workload ratio follows owner policy
M16_PROBE PASS: L84 VIP feature flag is enabled
M16_PROBE PASS: L84 normal objective cost follows the merge model
M16_PROBE PASS: L85 id is sequential
M16_PROBE PASS: L85 island reference is Sunny Cove
M16_PROBE PASS: L85 matches the approved normal objective row
M16_PROBE PASS: L85 matches the approved timer row
M16_PROBE PASS: L85 matches the approved merge-cost row
M16_PROBE PASS: L85 normal targets stay within L5-L8
M16_PROBE PASS: L85 is non-VIP with neutral payload
M16_PROBE PASS: L85 normal objective cost follows the merge model
M16_PROBE PASS: L86 id is sequential
M16_PROBE PASS: L86 island reference is Sunny Cove
M16_PROBE PASS: L86 matches the approved normal objective row
M16_PROBE PASS: L86 matches the approved timer row
M16_PROBE PASS: L86 matches the approved merge-cost row
M16_PROBE PASS: L86 normal targets stay within L5-L8
M16_PROBE PASS: L86 is non-VIP with neutral payload
M16_PROBE PASS: L86 normal objective cost follows the merge model
M16_PROBE PASS: L87 id is sequential
M16_PROBE PASS: L87 island reference is Sunny Cove
M16_PROBE PASS: L87 matches the approved normal objective row
M16_PROBE PASS: L87 matches the approved timer row
M16_PROBE PASS: L87 matches the approved merge-cost row
M16_PROBE PASS: L87 normal targets stay within L5-L8
M16_PROBE PASS: L87 is non-VIP with neutral payload
M16_PROBE PASS: L87 normal objective cost follows the merge model
M16_PROBE PASS: L88 id is sequential
M16_PROBE PASS: L88 island reference is Sunny Cove
M16_PROBE PASS: L88 matches the approved normal objective row
M16_PROBE PASS: L88 matches the approved timer row
M16_PROBE PASS: L88 matches the approved merge-cost row
M16_PROBE PASS: L88 normal targets stay within L5-L8
M16_PROBE PASS: L88 exact VIP target and quantity
M16_PROBE PASS: L88 exact VIP reward
M16_PROBE PASS: L88 VIP workload ratio follows owner policy
M16_PROBE PASS: L88 VIP feature flag is enabled
M16_PROBE PASS: L88 normal objective cost follows the merge model
M16_PROBE PASS: L89 id is sequential
M16_PROBE PASS: L89 island reference is Sunny Cove
M16_PROBE PASS: L89 matches the approved normal objective row
M16_PROBE PASS: L89 matches the approved timer row
M16_PROBE PASS: L89 matches the approved merge-cost row
M16_PROBE PASS: L89 normal targets stay within L5-L8
M16_PROBE PASS: L89 is non-VIP with neutral payload
M16_PROBE PASS: L89 normal objective cost follows the merge model
M16_PROBE PASS: L90 id is sequential
M16_PROBE PASS: L90 island reference is Sunny Cove
M16_PROBE PASS: L90 matches the approved normal objective row
M16_PROBE PASS: L90 matches the approved timer row
M16_PROBE PASS: L90 matches the approved merge-cost row
M16_PROBE PASS: L90 normal targets stay within L5-L8
M16_PROBE PASS: L90 is non-VIP with neutral payload
M16_PROBE PASS: L90 normal objective cost follows the merge model
M16_PROBE PASS: L91 id is sequential
M16_PROBE PASS: L91 island reference is Sunny Cove
M16_PROBE PASS: L91 matches the approved normal objective row
M16_PROBE PASS: L91 matches the approved timer row
M16_PROBE PASS: L91 matches the approved merge-cost row
M16_PROBE PASS: L91 normal targets stay within L5-L8
M16_PROBE PASS: L91 is non-VIP with neutral payload
M16_PROBE PASS: L91 normal objective cost follows the merge model
M16_PROBE PASS: L92 id is sequential
M16_PROBE PASS: L92 island reference is Sunny Cove
M16_PROBE PASS: L92 matches the approved normal objective row
M16_PROBE PASS: L92 matches the approved timer row
M16_PROBE PASS: L92 matches the approved merge-cost row
M16_PROBE PASS: L92 normal targets stay within L5-L8
M16_PROBE PASS: L92 exact VIP target and quantity
M16_PROBE PASS: L92 exact VIP reward
M16_PROBE PASS: L92 VIP workload ratio follows owner policy
M16_PROBE PASS: L92 VIP feature flag is enabled
M16_PROBE PASS: L92 normal objective cost follows the merge model
M16_PROBE PASS: L93 id is sequential
M16_PROBE PASS: L93 island reference is Sunny Cove
M16_PROBE PASS: L93 matches the approved normal objective row
M16_PROBE PASS: L93 matches the approved timer row
M16_PROBE PASS: L93 matches the approved merge-cost row
M16_PROBE PASS: L93 normal targets stay within L5-L8
M16_PROBE PASS: L93 is non-VIP with neutral payload
M16_PROBE PASS: L93 normal objective cost follows the merge model
M16_PROBE PASS: L94 id is sequential
M16_PROBE PASS: L94 island reference is Sunny Cove
M16_PROBE PASS: L94 matches the approved normal objective row
M16_PROBE PASS: L94 matches the approved timer row
M16_PROBE PASS: L94 matches the approved merge-cost row
M16_PROBE PASS: L94 normal targets stay within L5-L8
M16_PROBE PASS: L94 is non-VIP with neutral payload
M16_PROBE PASS: L94 normal objective cost follows the merge model
M16_PROBE PASS: L95 id is sequential
M16_PROBE PASS: L95 island reference is Sunny Cove
M16_PROBE PASS: L95 matches the approved normal objective row
M16_PROBE PASS: L95 matches the approved timer row
M16_PROBE PASS: L95 matches the approved merge-cost row
M16_PROBE PASS: L95 normal targets stay within L5-L8
M16_PROBE PASS: L95 is non-VIP with neutral payload
M16_PROBE PASS: L95 normal objective cost follows the merge model
M16_PROBE PASS: L96 id is sequential
M16_PROBE PASS: L96 island reference is Sunny Cove
M16_PROBE PASS: L96 matches the approved normal objective row
M16_PROBE PASS: L96 matches the approved timer row
M16_PROBE PASS: L96 matches the approved merge-cost row
M16_PROBE PASS: L96 normal targets stay within L5-L8
M16_PROBE PASS: L96 exact VIP target and quantity
M16_PROBE PASS: L96 exact VIP reward
M16_PROBE PASS: L96 VIP workload ratio follows owner policy
M16_PROBE PASS: L96 VIP feature flag is enabled
M16_PROBE PASS: L96 normal objective cost follows the merge model
M16_PROBE PASS: L97 id is sequential
M16_PROBE PASS: L97 island reference is Sunny Cove
M16_PROBE PASS: L97 matches the approved normal objective row
M16_PROBE PASS: L97 matches the approved timer row
M16_PROBE PASS: L97 matches the approved merge-cost row
M16_PROBE PASS: L97 normal targets stay within L5-L8
M16_PROBE PASS: L97 is non-VIP with neutral payload
M16_PROBE PASS: L97 normal objective cost follows the merge model
M16_PROBE PASS: L98 id is sequential
M16_PROBE PASS: L98 island reference is Sunny Cove
M16_PROBE PASS: L98 matches the approved normal objective row
M16_PROBE PASS: L98 matches the approved timer row
M16_PROBE PASS: L98 matches the approved merge-cost row
M16_PROBE PASS: L98 normal targets stay within L5-L8
M16_PROBE PASS: L98 is non-VIP with neutral payload
M16_PROBE PASS: L98 normal objective cost follows the merge model
M16_PROBE PASS: L99 id is sequential
M16_PROBE PASS: L99 island reference is Sunny Cove
M16_PROBE PASS: L99 matches the approved normal objective row
M16_PROBE PASS: L99 matches the approved timer row
M16_PROBE PASS: L99 matches the approved merge-cost row
M16_PROBE PASS: L99 normal targets stay within L5-L8
M16_PROBE PASS: L99 is non-VIP with neutral payload
M16_PROBE PASS: L99 normal objective cost follows the merge model
M16_PROBE PASS: L100 id is sequential
M16_PROBE PASS: L100 island reference is Sunny Cove
M16_PROBE PASS: L100 matches the approved normal objective row
M16_PROBE PASS: L100 matches the approved timer row
M16_PROBE PASS: L100 matches the approved merge-cost row
M16_PROBE PASS: L100 normal targets stay within L5-L8
M16_PROBE PASS: L100 exact VIP target and quantity
M16_PROBE PASS: L100 exact VIP reward
M16_PROBE PASS: L100 VIP workload ratio follows owner policy
M16_PROBE PASS: L100 VIP feature flag is enabled
M16_PROBE PASS: L100 normal objective cost follows the merge model
M16_PROBE PASS: merge cost L5 is 16
M16_PROBE PASS: merge cost L6 is 32
M16_PROBE PASS: merge cost L7 is 64
M16_PROBE PASS: merge cost L8 is 128
M16_PROBE PASS: Level 1 anchor is 1xL5 at 20 seconds
M16_PROBE PASS: Level 100 anchor is L8+L7+L6+L5 at 300 seconds
M16_PROBE PASS: VIP quantity mix is 15x qty1 and 10x qty2
M16_PROBE PASS: Upgrade cadence is exactly VIP levels 20/40/60/80/100
M16_PROBE PASS: all other VIP rewards are +Time
M16_PROBE PASS: 75 Sunny Cove levels remain non-VIP
M16_PROBE PASS: VIP cost is excluded from normal timer validation
M16_PROBE PASS: CampaignManager configures from the canonical FULL database
M16_PROBE PASS: Level 1 is initially selected and unlocked
M16_PROBE PASS: Level 2 starts locked before Level 1 completion
M16_PROBE PASS: all 100 levels follow the sequential unlock chain
M16_PROBE PASS: Level 100 closes Sunny Cove without a next level
M16_PROBE PASS: Level 100 preserves the next-island unlock boundary
M16_PROBE PASS: marker campaign configures
M16_PROBE PASS: Island Map configures from canonical VIP data
M16_PROBE PASS: VIP crown marker is visible for COMPLETE VIP level
M16_PROBE PASS: VIP crown marker is visible for OPEN VIP level
M16_PROBE PASS: VIP crown marker is visible for CURRENT VIP level
M16_PROBE PASS: VIP crown marker is visible for LOCKED VIP level
M16_PROBE PASS: non-VIP level has no crown marker
M16_PROBE PASS: crown marker uses the canonical gameplay VIP badge asset
M16_PROBE PASS: crown marker display size is exactly 36x36
M16_PROBE PASS: crown marker stays adjacent without covering the level node
M16_PROBE PASS: crown marker remains inside the map bounds on both path sides
M16_PROBE PASS: replay campaign configures with Level 4 unlocked
M16_PROBE PASS: replay bridge configures with economy
M16_PROBE PASS: first play can start canonical VIP Level 4
M16_PROBE PASS: normal WIN succeeds when VIP is missed
M16_PROBE PASS: missed VIP grants no booster and persists false
M16_PROBE PASS: completed VIP level remains replayable
M16_PROBE PASS: replay can complete the missed VIP
M16_PROBE PASS: replay persists VIP completion and grants +Time once
M16_PROBE PASS: replay again is allowed after VIP completion
M16_PROBE PASS: replay-after-replay keeps VIP completed
M16_PROBE PASS: VIP reward ledger prevents duplicate +Time reward
M16_PROBE PASS: normal content signature is unchanged after marker/replay flows
M16_SUNNY_COVE_CONTENT_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M16_SUNNY_COVE_CONTENT_RESULT=PASS
REQUIRED_MARKER_PRESENT=True

### 06-M15-VIP-BOOSTERS
COMMAND=godot_console.exe --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M15_PROBE PASS: M15 fixture loads in FULL validation
M15_PROBE PASS: shared policy accepts normal/VIP L5
M15_PROBE PASS: shared policy accepts normal/VIP L8
M15_PROBE PASS: shared policy rejects normal/VIP L4
M15_PROBE PASS: shared policy rejects normal/VIP L9
M15_PROBE PASS: VIP zero quantity rejects
M15_PROBE PASS: VIP fractional quantity rejects
M15_PROBE PASS: disabled VIP metadata remains valid
M15_PROBE PASS: typed booster reward grants inventory
M15_PROBE PASS: reward ledger makes replay idempotent
M15_PROBE PASS: invalid reward fails closed without partial mutation
M15_PROBE PASS: insufficient booster consumption is non-mutating
M15_PROBE PASS: successful booster consumption is exact
M15_PROBE PASS: SaveManager persists economy balances and ledger
M15_PROBE PASS: pre-M15 valid save loads with empty ledger
M15_PROBE PASS: CampaignManager configures with shared economy
M15_PROBE PASS: GameplaySessionBridge configures with shared economy
M15_PROBE PASS: VIP session exposes exact target and pending 0/2 state
M15_PROBE PASS: +Time applies positive extension and consumes one item
M15_PROBE PASS: +Time with empty inventory does not consume or extend
M15_PROBE PASS: mismatched and nonpositive VIP deliveries pay zero
M15_PROBE PASS: paused VIP delivery pays zero
M15_PROBE PASS: GameplaySessionBridge configures with shared economy
M15_PROBE PASS: incomplete VIP still produces normal WIN
M15_PROBE PASS: incomplete VIP grants no VIP booster
M15_PROBE PASS: CampaignManager configures with shared economy
M15_PROBE PASS: GameplaySessionBridge configures with shared economy
M15_PROBE PASS: LOSE does not dispatch configured level or VIP rewards
M15_PROBE PASS: ineligible milestone is rejected without reward
M15_PROBE PASS: eligible milestone grants once and records claim
M15_PROBE PASS: milestone reward dispatch preserves progression independence
M15_PROBE PASS: production navigation exposes the same economy authority
M15_PROBE PASS: runtime selection reuses the shared bridge/economy
M15_PROBE PASS: production normal target is L6 and VIP target is L8
M15_PROBE PASS: combined owner-approved V06 HUD asset is active
M15_PROBE PASS: combined HUD keeps width and derives the tall V06 height
M15_PROBE PASS: obsolete procedural VIP card is absent
M15_PROBE PASS: normal target uses canonical cocktail and authoritative 0/1 progress
M15_PROBE PASS: normal reward remains Drink.order_reward
M15_PROBE PASS: VIP target reuses canonical cocktail texture
M15_PROBE PASS: normal and VIP cocktail slots share one scaling policy
M15_PROBE PASS: VIP pending presentation shows 0/N and doubled reward
M15_CAPTURE_UNAVAILABLE name=normal_vip_pending reason=HEADLESS_DISPLAY
MERGE L8 +1000  COMBO x1 +0  (toplam: 1000)
M15_PROBE PASS: newly merged VIP drink enters production capture
VIP DELIVERY L8 +1/2 BONUS 6000 (toplam: 7000)
M15_PROBE PASS: merged VIP receives exact 2x unit payout
M15_PROBE PASS: first actual VIP delivery accumulates 1/2
M15_PROBE PASS: VIP partial presentation shows 1/N without debug words
M15_CAPTURE_UNAVAILABLE name=normal_vip_partial reason=HEADLESS_DISPLAY
M15_PROBE PASS: stored VIP drink enters production capture
VIP DELIVERY L8 +2/2 BONUS 6000 (toplam: 13000)
M15_PROBE PASS: stored VIP receives exact 2x unit payout
M15_PROBE PASS: second actual VIP delivery completes cumulative 2/2
M15_PROBE PASS: VIP completed presentation replaces the fraction with a check mark
M15_CAPTURE_UNAVAILABLE name=normal_vip_completed reason=HEADLESS_DISPLAY
MERGE L8 +1000  COMBO x2 +250  (toplam: 14250)
M15_PROBE PASS: extra VIP delivery after completion is idempotent
M15_PROBE PASS: extra VIP delivery after completion pays zero
M15_PROBE PASS: normal L6 enters its separate production capture
TO-GO ORDER L6 +1000  (toplam: 15250)
M15_PROBE PASS: normal L6 delivery remains 1x payout
M15_PROBE PASS: normal progress reflects authoritative completed/required state
M15_PROBE PASS: terminal result score includes VIP bonuses
M15_PROBE PASS: normal WIN follows VIP completion and grants reward once
M15_PROBE PASS: repeated WIN resolution does not duplicate reward
MERGE L6 +350  COMBO x1 +0  (toplam: 350)
TO-GO ORDER L6 +1000  (toplam: 1350)
M15_PROBE PASS: same-level normal delivery claims first
M15_PROBE PASS: same-level later L6 remains protected while useful for mandatory L8
M15_CAPTURE_UNAVAILABLE name=non_vip_0_of_0 reason=HEADLESS_DISPLAY
M15_PROBE PASS: non-VIP keeps the combined panel visible
M15_PROBE PASS: non-VIP shows persistent 0/0 with no VIP reward
M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS
REQUIRED_MARKER_PRESENT=True

### 07-M14-GAMEPLAY-BRIDGE
COMMAND=godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M14_PROBE PASS: M14 fixture loads in FULL validation
M14_PROBE PASS: CampaignManager configures M14 fixture
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: M13 selection identity enters exact session
M14_PROBE PASS: session snapshot includes immutable level definition
M14_PROBE PASS: session snapshot carries timer, orders, VIP, rewards, thresholds, flags
M14_PROBE PASS: duplicate active session is rejected
M14_PROBE PASS: locked level selection is rejected
M14_PROBE PASS: canonical definition remains unchanged after snapshot
M14_PROBE PASS: timer starts only after gameplay ready
M14_PROBE PASS: active timer decrements from one authoritative value
M14_PROBE PASS: legitimate pause freezes timer
M14_PROBE PASS: paused timer does not drain
M14_PROBE PASS: resume restores active timer
M14_PROBE PASS: background pause freezes timer
M14_PROBE PASS: background-paused timer does not drain
M14_PROBE PASS: background resume restores timer
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: timeout resolves one deterministic LOSE
M14_PROBE PASS: terminal timeout does not repeat or go negative
M14_PROBE PASS: timeout does not advance progression
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: normal quantity ledger starts at 2xL6 then L7
M14_PROBE PASS: stored qualifying L6 can satisfy a later campaign order
M14_PROBE PASS: second quantity is required before advancing order
M14_PROBE PASS: incomplete VIP never blocks normal WIN
M14_PROBE PASS: score-only completion cannot earn three stars
M14_PROBE PASS: WIN progression is submitted exactly once
M14_PROBE PASS: WIN stops timer
M14_PROBE PASS: CampaignManager configures M14 fixture
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: VIP completion with insufficient three-star score earns two stars
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: VIP completion with three-star score earns three stars
M14_PROBE PASS: GameplaySessionBridge configures with database and campaign
M14_PROBE PASS: plain normal completion earns one star
M14_PROBE PASS: Retry creates a fresh READY session from original definition
M14_PROBE PASS: worse replay cannot lower best score or stars
M14_PROBE PASS: Next Level resolves only an unlocked next level
M14_PROBE PASS: next-level session starts with clean objective/timer state
M14_PROBE PASS: Island Map return preserves exact island boundary
M14_PROBE PASS: configured app entry is campaign shell
M14_PROBE PASS: configured entry instantiates the real M13 navigation host
M14_PROBE PASS: M13 navigation host configures exact fixture campaign
M14_PROBE PASS: navigation owns one reusable map pair
M14_PROBE PASS: real M12 World Map selection enters the exact M13 Island Map
M14_PROBE PASS: M13 level selection launches existing gameplay scene through M14
M14_PROBE PASS: production selection enters GAMEPLAY with one instance
M14_PROBE PASS: production gameplay pause hook pauses the active bridge
M14_PROBE PASS: production gameplay pause hook freezes the timer
M14_PROBE PASS: production gameplay resume hook resumes the active bridge
M14_PROBE PASS: production gameplay resume hook allows timer progress
M14_PROBE PASS: production application pause notification freezes the bridge timer
M14_PROBE PASS: production application resume notification resumes background-paused gameplay
M14_PROBE PASS: pre-existing user pause survives application resume
M14_PROBE PASS: terminal gameplay is not resumed by application lifecycle
M14_PROBE PASS: Retry path is bounded and does not duplicate gameplay
M14_PROBE PASS: Retry remains the same exact level
M14_PROBE PASS: Island Map path returns through bridge boundary
M14_PROBE PASS: Island Map return has no duplicate gameplay instance
M14_PROBE PASS: final canonical definition remains unchanged
M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS
REQUIRED_MARKER_PRESENT=True

### 08-M02-PHYSICS
COMMAND=godot_console.exe --headless --path . --script res://tests/m02_physics_regression.gd
STDOUT_BEGIN
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

M02_PROBE user_save_path=C:/Users/sekip/AppData/Roaming/Godot/app_userdata/CocktailMerge/save.cfg
M02_PROBE PASS: main scene loads as PackedScene
M02_PROBE PASS: runtime GameManager/World is ready
M02_PROBE PASS: runtime world has four named rails
M02_BODY_CONFIG level=6 mass=2.5 radius=42.0 freeze_mode=0 ccd=2 linear_damp=0.0 angular_damp=3.0 friction=0.07999999821186 bounce=0.0
M02_PROBE PASS: RigidBody2D body and zero-bounce physics configuration
M02_PROBE PASS: settled body starts dynamic, sleeping, and collidable
M02_MASS_RADIUS_TABLE L1 radius=20.0 mass=1.0 json_mass=1.0; L2 radius=23.0 mass=1.29999995231628 json_mass=2.0; L3 radius=27.0 mass=1.60000002384186 json_mass=4.0; L4 radius=31.0 mass=1.89999997615814 json_mass=8.0; L5 radius=36.0 mass=2.20000004768372 json_mass=16.0; L6 radius=42.0 mass=2.5 json_mass=32.0; L7 radius=49.0 mass=2.79999995231628 json_mass=64.0; L8 radius=56.0 mass=3.09999990463257 json_mass=128.0; L9 radius=64.0 mass=3.40000009536743 json_mass=256.0; L10 radius=72.0 mass=3.70000004768372 json_mass=512.0; L11 radius=80.0 mass=4.0 json_mass=1024.0; L12 radius=90.0 mass=4.30000019073486 json_mass=2048.0
M02_PROBE PASS: all 12 collider radii are positive and runtime mass is monotonic
M02_PROBE PASS: held state is frozen and non-physical before release
M02_PROBE PASS: held-to-sliding transition enables dynamic collision
M02_TOP_CONTACT final_position=(360.0, 391.7339) motion_state=2 velocity=(0.0, 0.0)
M02_PROBE PASS: top boundary contact settles without +Y rebound
M02_DIRECT_HIT contacts=1 target_position=(150.0, 632.3226) target_state=1
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_GLANCING_HIT contacts=1 target_position=(572.5089, 654.0648) target_state=1
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: collision response remains forward-only
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
M02_SINGLE_MERGE score_delta=20 level2_bodies=1 pending=0
M02_PROBE PASS: one pair resolves once with one score and one result body
MERGE L2 +20  COMBO x2 +5  (toplam: 45)
MERGE L3 +50  COMBO x3 +25  (toplam: 120)
M02_CHAIN_STRESS l3_bodies=2 moving_stress=true pending=0
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: chain merge consumes only the intended chain inputs
M02_PROBE PASS: L12 plus L12 remains two L12 bodies with no L13
M02_PROBE PASS: L12 remains a hard cap
M02_RAPID_STEP index=1 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=2 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=3 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=4 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=5 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=6 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_LAUNCH launches=6 world_drinks=7 simulated_previous=6 current_valid=true current_state=0
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: earlier rapid-launch drinks continue physical simulation
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
OYUN BITTI - Skor: 0
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE PASS: post-Game-Over restart has no stale moving-body references
M02_PROBE_RESULT=PASS
STDOUT_END
STDERR_BEGIN
STDERR_END
NATIVE_EXIT_CODE=0
REQUIRED_MARKER=M02_PROBE_RESULT=PASS
REQUIRED_MARKER_PRESENT=True


```

## Limitations and handoff

- Headless-only validation; no owner/native/manual visual acceptance and no independent GPT audit was performed
- M15 emitted expected HEADLESS_DISPLAY capture-unavailable diagnostics for visual snapshots while its functional probe passed
- Terminal post-publication equality is recorded in docs/codex-logs/BCM-M17_V07_R03_R02_V04_CAPTURE_COMPATIBLE_CODEX_LOG.md
- This is builder evidence only; ChatGPT remains the independent auditor and lifecycle owner

## Evidence URLs

- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_R02_CHILD_01_V04.md
- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_R02_V04.md
- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07_R03.md

## Completion marker

AWAITING_M17_AUDIT_V07_R03_R02

--- END PRESERVED V04 MASTER LOG ---

## Final handoff

The terminal record will contain the second-publication equality, final clean status, `git diff --check`, TASKS.md immutability, and final marker. The V05 logs end with:

AWAITING_M17_AUDIT_V07_R03_R02
