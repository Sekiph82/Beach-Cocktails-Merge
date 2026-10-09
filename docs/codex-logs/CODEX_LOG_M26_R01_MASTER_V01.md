# Codex Execution Log — BCM-M26-R01 Master V01

Status: `AWAITING_GPT_M26_R01_MILESTONE_AUDIT`.

- Work item: BCM-M26-R01, prompt `coordination/sessions/BCM-M26-MASTER-V01/BCM-M26-R01_MASTER_PROMPT.md`.
- Start HEAD: `fb9f7e4afb81cc51fd7ee499738078ec7eae3eee`; branch `main`; remote `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`).
- Sync: canonical `main` was behind-only by `0/3`; incoming changes were disjoint from seven dirty tracked owner paths and fourteen untracked owner files. Applied the exact tracked-only stash `owner-local-safe-sync-929e3fd` without dropping it, fast-forwarded `929e3fd..fb9f7e4`, reapplied tracked owner edits, and verified all owner hashes and `0/0` parity. Final pre-publication fetch remained `0/0`.
- Controlled baseline: pre-M26 parent `459d7013676be4ad9b7291e33df2867779017520`; live source: `fb9f7e4afb81cc51fd7ee499738078ec7eae3eee`.
- Task-owned source/test changes are limited to the ten regression probes, M17 screening model, and presentation feedback bridge. Captures, raw logs, summaries and manifests are under `coordination/sessions/BCM-M26-MASTER-V01/evidence/M26-R01/`.

## Baseline and pre-fix findings

- M08 mixed tabs at two nested statements caused a parse failure on both baseline and live. Replaced those tabs with the surrounding four-space indentation; M08 probe passes.
- M17 objective reachability treated `time_limit_sec == 0` as impossible although the canonical campaign and owner contract are untimed. Removed timer validation from the reachability predicate; timer/cost analysis remains separate. Updated the stale timeout fixture to prove that a 3600-second tick cannot synthesize a timeout in an untimed session.
- M17 seeds `17017001` and `17017002` both generate the same first spawn (`2`); changed the comparison to seed `17017003`, whose first spawn is distinct (`1`). Same-seed determinism and exact action-log replay checks remain intact.
- M20 failed only when run after campaign tests had persisted progress: the current active level was 3, and retry correctly returned to level 3. Replaced the hard-coded level-1 assertion with a comparison to the active level captured before the terminal event. The complete M20 sequence passes.
- M23 baseline dispatched 4 of 6 stress events, counted 40 particles, and stayed within the 48-particle ceiling. Live M26 returned zero whenever the Spark pool existed, even when the plugin adapter had not materialized its accepted outputs, so all 6 stress events dispatched. Active count now uses the larger of actual pool particles and unexpired bridge estimates; this retains a fail-closed ceiling without double-counting. The probe records particle, dispatch, and GFF counts separately.
- Full-suite M19 text checks also failed on the pre-M26 baseline because a Windows CRLF file was searched for a fixed LF substring. The two checks now normalize CRLF before matching; the text criteria are unchanged.
- M23 combo baseline passed. M26 serializes large celebrations, so the score cue may wait behind an active merge burst. The probe now allows that bounded presentation to drain before asserting the score effect; bridge flush prunes expired fallback outputs, shallow-copies queued requests, validates target lifetime before queueing, and clears pending requests on cancellation. This also fixes the M26-002 freed-target error reproduced in the first full matrix.

Raw pre-fix failures, baseline controls, and passing reruns are retained under `evidence/M26-R01/`.

## Final verification

- Focused post-fix: M08 PASS; M17 V06 analytical PASS (`100` levels, `45` classes); M17 difficulty PASS; M20 pause/retry PASS; M23 merge PASS (`32` checks, `40` active particles, `13` total dispatches); M19 scalability and ordered child 03 PASS; M23 combo PASS; M26-002 PASS; M26-003 PASS.
- Full regression matrix M01–M26: `55 passed, 0 failed`, every runner cleanup verified. Final summary: `evidence/M26-R01/full_matrix_postfix/summary.json`. The earlier first full run and its raw failed logs remain in `evidence/M26-R01/full_matrix/`.
- M21 GL QA: two independent runs, each `16` captures, zero failed checks, exit 0 and cleanup verified. Outputs are in `evidence/M26-R01/M21-qa-run-01/` and `M21-qa-run-02/`.
- M26 GL views: FULL and REDUCED at `720x1280` and `720x1440`, from both production probes; nine captures and SHA-256 manifests are in `evidence/M26-R01/visuals/`.
- Godot 4.7.2 editor import: exit 0. Headless 120-frame project boot: exit 0. Both used `tests/m26_001_r01_godot_runner.ps1`; no task-owned Godot processes remain.
- `git diff --check` passed. The 229 owner user-data files, seven tracked owner-local changes, fourteen untracked owner files, and root `TASKS.md` were hash-checked and unchanged. `TASKS.md` SHA-256 remains `14FFC4B79176BCEA812106E38D89D47CABE41EC9CC604FC71FEA929710340483`.
- Builder GL captures do not constitute physical-device or owner visual acceptance. No independent milestone verdict is claimed.

## Files changed

- Product: `scripts/presentation_feedback_bridge.gd`; `scripts/campaign/m17_canonical_screening_model.gd`.
- Tests: `tests/m08_to_go_delivery_probe.gd`; `tests/m17_canonical_screening_v06_analytical_probe.gd`; `tests/m17_difficulty_validation_probe.gd`; `tests/m19_multi_island_scalability_probe.gd`; `tests/m19_r01_ordered_verification_probe.gd`; `tests/m20_pause_lifecycle_probe.gd`; `tests/m23_002_merge_feedback_probe.gd`; `tests/m23_003_combo_milestone_probe.gd`; `tests/m26_002_campaign_unlock_presentation_probe.gd`; `tests/m26_003_reward_primary_feedback_probe.gd`.
- Builder record and evidence: this log and `coordination/sessions/BCM-M26-MASTER-V01/evidence/M26-R01/`.

## Publication

- `TASKS.md` was not modified; no M27 work was started.
- Implementation/evidence commit SHA: `429982f` (`BCM-M26-R01 fix regressions and capture evidence`).
- After implementation publication, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` were required to match; final verification evidence will be added to the task handoff.
- Stop marker: `AWAITING_GPT_M26_R01_MILESTONE_AUDIT`.

