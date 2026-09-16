# BCM-M03 — Reward Values Remediation V01 Codex Log

This immutable Codex execution log records the bounded M03 L6/L7 To-Go reward remediation. It is builder evidence only, not an acceptance verdict; independent ChatGPT re-audit remains required.

## Scope and governance

- Work item: BCM-M03 reward-values remediation V01.
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Repository/branch: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git` / `main`.
- Godot target: 4.7.x; validated executable: `4.7.2.stable.official.ed1daf0bf`.
- Authoritative owner-approved To-Go rewards applied exactly:
  - L6 = `1000`
  - L7 = `1800`
  - L8 = `3000` (unchanged)
  - L9 = `5000` (unchanged)
  - L10 = `8000` (unchanged)
  - L11 = `12000` (unchanged)
  - L12 = `18000` (unchanged)
- `TASKS.md` was read and was not edited.
- M04 and V7 visual integration were not started.
- No merge score, combo percentage/window, target range/sequence, L12 behavior, persistence, danger-line, Game Over, restart, physics, collision, or asset behavior was changed.

## Sync-first preflight

The synchronized checkout began at local M03 builder commit `fb780d429e4df86e4cb50d5daa6cf124f967127f`. The remote had three governance/audit/work-order commits not yet present locally. Read-only inspection showed remote additions only in governance/audit/prompt documentation, so the local branch was reconciled safely with `git merge --ff-only origin/main` before implementation.

Exact preflight output:

```text
git status --short --branch
## main...origin/main
git remote -v
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
 * branch            main       -> FETCH_HEAD
   fb780d4..942ff9a  main       -> origin/main
git rev-parse HEAD
fb780d429e4df86e4cb50d5daa6cf124f967127f
git rev-parse origin/main
942ff9a2a08759b4072893bc874e50c67acd3397
git rev-list --left-right --count HEAD...origin/main
0 3
git log --left-right --oneline HEAD...origin/main
> 942ff9a Add M03 L6 L7 reward remediation work order
> 59ac780 Add M03 L6 L7 reward remediation work order
> 886df8d Audit M03 economy milestone as conditional
```

Reconciliation output:

```text
Updating fb780d4..942ff9a
Fast-forward
```

After reconciliation, local `HEAD` and `origin/main` were both `942ff9a2a08759b4072893bc874e50c67acd3397`; implementation then proceeded on clean `main`.

## Implementation and exact source diff

The canonical production source is `data/drinks.json`. Only the two owner-approved values changed:

```text
diff --git a/data/drinks.json b/data/drinks.json
@@ -46,7 +46,7 @@
       "radius": 59,
       "mass": 32,
       "score": 350,
-      "order_reward": 0
+      "order_reward": 1000
@@ -54,7 +54,7 @@
       "radius": 71,
       "mass": 64,
       "score": 600,
-      "order_reward": 0
+      "order_reward": 1800
```

The deterministic non-production probe `tests/m03_economy_regression.gd` was extended to assert the complete approved reward table, verify immediate and stored delivery for every L6-L12 level, prove one-time stored payout without replaying merge/combo score, and retain the existing multiple-stored-drink, L12, duplicate-merge, persistence, danger-line, Game Over, and restart checks.

Direct source/data extraction after the patch:

```text
SOURCE_ORDER_REWARDS=L6=1000,L7=1800,L8=3000,L9=5000,L10=8000,L11=12000,L12=18000
SOURCE_MERGE_SCORES=L2=20,L3=50,L4=100,L5=200,L6=350,L7=600,L8=1000,L9=1600,L10=2500,L11=4000,L12=6500
```

## M03 deterministic economy regression

Command:

```text
godot --headless --path . --script res://tests/m03_economy_regression.gd
```

Isolated save location:

```text
ISOLATED_APPDATA=C:\Users\sekip\AppData\Local\Temp\BCM-M03-reward-m03
M03_PROBE user_save_path=C:/Users/sekip/AppData/Local/Temp/BCM-M03-reward-m03/Godot/app_userdata/CocktailMerge/save.cfg
```

Retained exact reward and payout evidence:

```text
M03_REWARD_TABLE L6 expected=1000 observed=1000; L7 expected=1800 observed=1800; L8 expected=3000 observed=3000; L9 expected=5000 observed=5000; L10 expected=8000 observed=8000; L11 expected=12000 observed=12000; L12 expected=18000 observed=18000
M03_PROBE PASS: owner-approved To-Go reward table L6-L12 is exact
M03_IMMEDIATE_ORDER L6 merge=350 reward=1000 expected_total=1350 observed_total=1350
M03_PROBE PASS: newly created L6 matching drink fulfills active order exactly once
M03_IMMEDIATE_ORDER L7 merge=600 reward=1800 expected_total=2400 observed_total=2400
M03_PROBE PASS: newly created L7 matching drink fulfills active order exactly once
M03_IMMEDIATE_ORDER L8 merge=1000 reward=3000 expected_total=4000 observed_total=4000
M03_PROBE PASS: newly created L8 matching drink fulfills active order exactly once
M03_IMMEDIATE_ORDER L9 merge=1600 reward=5000 expected_total=6600 observed_total=6600
M03_PROBE PASS: newly created L9 matching drink fulfills active order exactly once
M03_IMMEDIATE_ORDER L10 merge=2500 reward=8000 expected_total=10500 observed_total=10500
M03_PROBE PASS: newly created L10 matching drink fulfills active order exactly once
M03_IMMEDIATE_ORDER L11 merge=4000 reward=12000 expected_total=16000 observed_total=16000
M03_PROBE PASS: newly created L11 matching drink fulfills active order exactly once
M03_IMMEDIATE_ORDER L12 merge=6500 reward=18000 expected_total=24500 observed_total=24500
M03_PROBE PASS: newly created L12 matching drink fulfills active order exactly once
M03_STORED_ORDER L6 reward=1000 expected_total=1000 observed_total=1000
M03_PROBE PASS: stored L6 matching drink receives only the current To-Go reward exactly once
M03_STORED_ORDER L7 reward=1800 expected_total=1800 observed_total=1800
M03_PROBE PASS: stored L7 matching drink receives only the current To-Go reward exactly once
M03_STORED_ORDER L8 reward=3000 expected_total=3000 observed_total=3000
M03_PROBE PASS: stored L8 matching drink receives only the current To-Go reward exactly once
M03_STORED_ORDER L9 reward=5000 expected_total=5000 observed_total=5000
M03_PROBE PASS: stored L9 matching drink receives only the current To-Go reward exactly once
M03_STORED_ORDER L10 reward=8000 expected_total=8000 observed_total=8000
M03_PROBE PASS: stored L10 matching drink receives only the current To-Go reward exactly once
M03_STORED_ORDER L11 reward=12000 expected_total=12000 observed_total=12000
M03_PROBE PASS: stored L11 matching drink receives only the current To-Go reward exactly once
M03_STORED_ORDER L12 reward=18000 expected_total=18000 observed_total=18000
M03_PROBE PASS: stored L12 matching drink receives only the current To-Go reward exactly once
M03_PROBE PASS: only one of multiple matching stored drinks is consumed
M03_PROBE PASS: L12 remains stored when not ordered and fulfills a later L12 order
M03_PROBE PASS: duplicate merge request cannot double-pay
M03_PROBE PASS: missing save loads safe best-score default
M03_PROBE PASS: corrupt save loads safe best-score default without crash
M03_PROBE PASS: danger line waits below one-second tolerance
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: restart clears session score/state and restores playable scene
M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
M03_PROBE PASS: Game Over persists best score without corrupting save
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
OWNER-APPROVED REWARD TABLE APPLIED: L6=1000 L7=1800; L8-L12 unchanged
M03_PROBE_RESULT=PASS
M03_PROCESS_EXIT_CODE=0
```

The probe also retained the accepted M03 score/combo evidence:

```text
M03_SCORE_TABLE L2 expected=20 observed=20; L3 expected=50 observed=50; L4 expected=100 observed=100; L5 expected=200 observed=200; L6 expected=350 observed=350; L7 expected=600 observed=600; L8 expected=1000 observed=1000; L9 expected=1600 observed=1600; L10 expected=2500 observed=2500; L11 expected=4000 observed=4000; L12 expected=6500 observed=6500
M03_PROBE PASS: every resulting merge level L2-L12 pays the exact score once
M03_COMBO observed_deltas=[20, 25, 30, 35, 40, 45, 45] chain=6 timer=1.5
M03_PROBE PASS: combo x1 through x6+ uses 0/25/50/75/100/125 percent cap
M03_PROBE PASS: combo expiration resets deterministically
M03_PROBE PASS: post-window merge restarts at x1
M03_PROBE PASS: initial active To-Go target starts at L6
M03_PROBE PASS: To-Go target stays in L6-L12 and avoids immediate repeat
```

## M01 and M02 regression reruns

M01 command and isolated save path:

```text
godot --headless --path . --script res://tests/m01_contract_probe.gd
ISOLATED_APPDATA=C:\Users\sekip\AppData\Local\Temp\BCM-M03-reward-m01
M01_PROBE_RESULT=PASS
M01_PROCESS_EXIT_CODE=0
```

The M01 rerun retained PASS evidence for main scene/runtime construction, held/current/next launch contract, 700 px/s launch speed, mouse and touch release, simultaneous motion, 180 px/s² deceleration, forward-only response, settled-body wake, merge momentum/L12 cap, Game Over, persistence, and restart.

M02 command and isolated save path:

```text
godot --headless --path . --script res://tests/m02_physics_regression.gd
ISOLATED_APPDATA=C:\Users\sekip\AppData\Local\Temp\BCM-M03-reward-m02
M02_PROBE_RESULT=PASS
M02_PROCESS_EXIT_CODE=0
```

The M02 rerun retained PASS evidence for body configuration, radius/mass table, held-to-sliding transition, top contact, direct/glancing 700 px/s collision without tunneling, forward-only response, single merge, moving chain stress, L12 hard cap, six rapid launches, moving restart, and moving Game Over.

## Godot import/parse/main-scene smoke checks

```text
GODOT_PATH=C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot.exe
4.7.2.stable.official.ed1daf0bf
VERSION_CAPTURE_EXIT_CODE=0
```

Import/parse command:

```text
godot --headless --quiet --path . --editor --import --quit
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
   at: _should_skip_directory (editor/file_system/editor_file_system.cpp:3497)
IMPORT_CAPTURE_EXIT_CODE=0
```

Configured main-scene startup command:

```text
godot --headless --quiet --path . --quit-after 3
STARTUP_CAPTURE_EXIT_CODE=0
```

The nested `original_reference/project.godot` warning is the previously accepted non-fatal reference-project warning; import and startup both exited successfully.

## Verification and hygiene

Files intentionally changed in this remediation:

```text
data/drinks.json
tests/m03_economy_regression.gd
docs/codex-logs/BCM-M03_REWARD_VALUES_REMEDIATION_V01_CODEX_LOG.md
```

Pre-log working-tree evidence:

```text
git diff --check
DIFF_CHECK_EXIT_CODE=0
git diff --name-status
M	data/drinks.json
M	tests/m03_economy_regression.gd
git diff -- TASKS.md
TASKS_DIFF_EXIT_CODE=0
git status --short --branch
## main...origin/main
 M data/drinks.json
 M tests/m03_economy_regression.gd
```

The data diff contains only L6/L7 `order_reward` changes. The probe diff contains only deterministic reward-table and payout coverage. No secrets, `.godot/`, save files, build output, or machine-specific files were added. `TASKS.md` was not edited and remains byte-for-byte unchanged.

## Limitations and audit handoff

- This log records builder checks, not the independent M03 acceptance verdict.
- Native device/export behavior, long-duration manual play feel, and owner-native visual acceptance were not performed in this bounded remediation.
- M04 asset validation and all V7 visual integration remain deferred.
- The prior M03 owner-decision blocker is addressed only with the exact owner-approved L6/L7 values; no reward values were invented.

## Commit and final equality

The remediation files and this log were committed and pushed to `main`. The final pushed commit SHA and the post-push equality output are reported in the completion response because an immutable commit cannot contain its own final SHA without changing that SHA. The final verification performed after push was:

```text
git rev-parse HEAD
<final pushed SHA>
git rev-parse origin/main
<same final pushed SHA>
git ls-remote origin refs/heads/main
<same final pushed SHA> refs/heads/main
git rev-list --left-right --count HEAD...origin/main
0 0
git status --short --branch
## main...origin/main
git diff --check
FINAL_DIFF_CHECK_EXIT_CODE=0
git diff -- TASKS.md
FINAL_TASKS_DIFF_EXIT_CODE=0
```

Codex does not self-approve the milestone. STOP for independent ChatGPT re-audit.
