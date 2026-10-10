# Codex Execution Log — BCM-M27-002 FULL/REDUCED V01

Status: `FUNCTIONAL_BUILDER_EVIDENCE_PASS; PAIRED_VISUAL_REVIEW_PENDING`.

- Work item: BCM-M27-002 under `BCM-M27-MASTER-V01`, prompt V01 and locked audit criteria V01.
- Start HEAD: `95074183d1494e8c87bb21168265e145aa5401e7` (the M27-001 implementation and child-log commits are on `origin/main`).
- Implementation/evidence commit: `ec36174a339bc90ec1e2532a8433c6521e27036c`; the child-log documentation commit follows separately.
- Checkout: detached sandbox based on `main`; no branch created. The sandbox-only project identity override remains local and unstaged. The canonical Desktop owner work remains preserved. `TASKS.md` was not modified.
- Before the M27-002 suite, five remaining owner Godot logs were copied to an isolated stage backup and SHA-256 verified. The guarded runner checked owner user-data parity and task-owned process cleanup on every invocation. Owner files remained 229/229 hash-identical and the 38-directory inventory was unchanged.

## Implementation

- Corrected `CampaignNavigationController.show_island_map()` so the Island Map becomes visible before it dispatches a pending island-completion presentation. The prior order emitted the semantic while the target label was hidden; the bridge withheld the effect. The M26 campaign-unlock probe reproduced the issue and passed after this narrow presentation-order correction.
- Added M27-specific copies of the M22–M26 effect probes with all generated reports redirected into this M27 evidence folder. The M23 combo fake session was updated to implement the current `set_current_score`, `tick`, and move-budget methods, so the regression no longer emits script errors. Headless M26 copies skip framebuffer capture rather than invoking a dummy renderer.
- Hardened `tests/m27_isolated_godot_runner.ps1`: it verifies owner data after failed Godot exits before reporting the test failure, fixes the editor-import gate path, and normalizes CRLF and path separators in the isolation assertion.

## Functional evidence

- M20 settings persistence/high contrast/reduced-motion probe: `M20_CHILD_03_RESULT=PASS`.
- M22-003 effect policy and FULL/REDUCED mapping: 97 checks, zero failures; all 16 semantic kinds have paired policy rows.
- M23-001 MICRO: 28 checks, zero failures. M23-002 MERGE: 32 checks, zero failures. M23-003 COMBO/MASTERY: 29 checks, zero failures after correcting the copied fake session.
- M24-001 ORDER progress: 7 checks, zero failures. M24-002 ORDER completion: 8 checks, zero failures. M24-003 VIP: 8 checks, zero failures.
- M25 result presentation: 22 checks, zero failures, including FULL/REDUCED WIN, LOSE, duplicate suppression, and Retry action.
- M26-001 Island Map presentation: 23 dispatches, zero failures. M26-002 completion/unlock: zero failures after the visibility-order fix, with the GLOBAL active-particle maximum at 48. M26-003 reward/CTA: zero failures.
- All functional runs used the M26 PID runner through the M27 isolation wrapper. Verified runner records show exit code 0 and no task-owned Godot processes remaining. `TASKS.md` was read only.

## Visual evidence and limitations

- Headless M26 runs intentionally produced no captures and skipped framebuffer assertions. They are functional evidence only.
- A windowed GL Compatibility M26-001 run saved five 720×1280/720×1440 Island Map captures and reported `M26_001_ISLAND_MAP_RESULT=PASS captures=5 failures=0`. Godot then exited with Windows code `-1073741819` during shutdown. The PID runner verified cleanup and owner-data parity, but the abnormal exit means the windowed run is not a clean renderer pass. The PNGs are retained as preliminary builder captures.
- No paired FULL/REDUCED capture set has been produced for every requested category. No target-device performance or owner-native visual acceptance is claimed. The required M27-003 clean import/boot, renderer capture set, and full regression remain open.
- Invalid resource UID fallback warnings appeared before the clean editor import. The four owner log files lost during the earlier accepted isolation incident remain unavailable; no reconstruction was attempted.

`TASKS.md` was not modified. This log is builder evidence, not independent acceptance.
