# Codex Execution Log — BCM-M27-001 Lifecycle Stress V01

Status: `BUILDER_EVIDENCE_PASS; INDEPENDENT_AUDIT_PENDING`.

- Work item: BCM-M27-001 under `BCM-M27-MASTER-V01`, prompt V01 and locked audit criteria V01.
- Start HEAD: `9667a1c0ad51cb7f93dcc870e276949006bae205` (`origin/main` at start).
- Implementation/evidence commit: `d64c63d` (`Add M27-001 isolated lifecycle stress evidence`). The child-log documentation commit follows separately.
- Checkout: detached sandbox at `C:\Users\sekip\.codex\worktrees\bcm-m27-master-v01-sandbox`, derived from `main`; no new branch was created. The sandbox-only `project.godot` identity override remains local and is not included in the child commit.
- Canonical Desktop sync: owner-local work was preserved by the approved path-disjoint fast-forward procedure; canonical checkout reached `9667a1c0ad51cb7f93dcc870e276949006bae205` and retained its seven modified tracked and five untracked owner paths. `TASKS.md` was read only and not modified.

## Isolation and owner-data protection

- The earlier failed M27 attempt and its incident record remain preserved. The owner explicitly chose to accept the loss of four rotated `CocktailMerge` diagnostic logs. Their original byte contents were unavailable and were not recreated. The corrected incident inventory retains their filenames and hashes.
- Before the permitted minimal probe, Preflight A recorded the full owner `user://` file/hash inventory and directory list (229 files, 38 directories), 832 canonical asset hashes, and the owner-log manifest. Five remaining owner diagnostic logs were copied byte-for-byte to an isolated backup and each copy was hash verified.
- Sandbox identity: `BCM-M27-MASTER-V01-20261010-Sandbox`. Resolved user-data directory and log target were outside `app_userdata\CocktailMerge`. The actual no-editor probe printed the resolved Godot user-data paths and `M27_ISOLATION_PROBE=PASS`.
- After each Godot invocation, the isolated wrapper compared all 229 owner user-data file hashes and all 38 directory entries to the preflight manifest. No differences were found. The PID-tracking runner reported exit code 0, cleanup verified, and zero remaining project-matching Godot processes.
- One initial wrapper assertion rejected the probe because it did not trim the CRLF captured from Godot stdout. The process had already exited cleanly; its captured stdout independently showed both actual paths and PASS. Owner-tree parity, current-log backup parity, expected sandbox log, and process cleanup were rechecked before recording the guard as PASS. The assertion now normalizes line endings and path separators.

## Work and evidence

- Added `tests/m27_001_lifecycle_stress_probe.gd`, `tests/m27_user_data_isolation_probe.gd`, and `tests/m27_isolated_godot_runner.ps1`.
- Isolated lifecycle stress run 07: `M27_001_LIFECYCLE_RESULT=PASS checks=64 failures=0 dispatches=18 active_particles=40 captures=0`. The probe exercised rapid merge feedback, FULL particle bands, 30 rapid To-Go/VIP event pairs, <=48 active-particle behavior and backpressure, repeated listener reconfiguration, output-handle cancellation, exact color restoration, and 12 terminal-world-effect cleanup cycles. The rapid delivery snapshot peaked at 44 particles with dispatch delta 5.
- Isolated M14 GameplaySessionBridge regression: `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`; it covered production navigation, one gameplay instance, Retry, and return through the Island Map boundary.
- Both evidence sets include runner result records, captured stdout/stderr, and wrapper guard JSON under `coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-001/`.
- `git diff --cached --check` reported one pre-existing captured-output blank line at EOF in `baseline_M23_002.stdout.txt`; it did not modify the source or test result. The commit completed successfully.

## Limitations and remaining checks

- The stress probe is synthetic and recorded zero visual captures. It does not establish owner-native visual acceptance or target-device performance.
- Godot emitted invalid UID fallback warnings for `scenes/main.tscn` and `WorldMapScene.tscn` in the M14 regression. A clean editor import/parse/boot remains in the M27-003 gate.
- Repeated end-to-end retry/map loops and the complete WIN/LOSE paired capture set remain to be covered by the continuing M27 regression sequence. No owner visual approval is claimed.
- The real `CocktailMerge` owner user-data tree and remaining logs stayed byte-identical during these isolated runs. The four earlier missing logs remain unavailable.

`TASKS.md` was not modified. This log is builder evidence, not independent acceptance.
