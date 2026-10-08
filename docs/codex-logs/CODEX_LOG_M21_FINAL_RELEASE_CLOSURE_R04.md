# Codex Execution Log — BCM-M21-006-R04 Evidence Publication Closure

## Work item and scope

- Work item: BCM-M21-006-R04
- Prompt: coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_EVIDENCE_PROMPT_R04.md
- Locked criteria: coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_EVIDENCE_CRITERIA_R04.md
- Independent R03 audit: coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_AUDIT_R03.md
- Start HEAD after sync: 663e68c5ed89a7325e8f16800acc57b386a59730
- Evidence publication/end HEAD: 6c76741ea49ac2c084d05546b968871eba5f6498
- Branch / remote: main / origin (https://github.com/Sekiph82/Beach-Cocktails-Merge.git)
- Scope was evidence-only. No product, runtime, test, tolerance, campaign, save, economy, or asset file was edited. M22 was not started.

## Sync preflight and preservation

The required preflight was run from the canonical Desktop checkout:

- Initial branch/status: main, no tracked modifications, two untracked owner critique PNGs.
- Remote: canonical origin.
- git fetch origin main: fetched five incoming commits; local was 0 ahead / 5 behind.
- Incoming changed paths were AGENTS.md, TASKS.md, and the R04 audit/prompt/criteria files. They were disjoint from the two untracked critique image paths.
- git merge --ff-only origin/main fast-forwarded to 663e68c5ed89a7325e8f16800acc57b386a59730; ahead/behind became 0/0.
- No stash was created or applied. Existing preservation stashes were not dropped or otherwise changed.
- Root TASKS.md was read-only and was not modified.

## Evidence publication

The original R03 local logs were present under the ignored R03 evidence directory. Thirty-one required .log files were copied byte-for-byte to same-basename .txt files under coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/evidence/.

- source_log_sha256.json contains the SHA-256 for each source and copy; all 31 pairs match.
- COMMAND_INDEX.txt maps every committed run output to its command. The copied outputs retain the original combined stdout/stderr and explicit EXIT_CODE line.
- No required test command was rerun. The original git diff --check .log was absent, so that exact command was rerun and captured as git_diff_check.txt with no output and EXIT_CODE=0.

The selected final runs include:

- M07 R04, R05, composition, and R06 final outputs.
- M08 normal GL runs 3 and 4, consecutive, each with the PASS marker and EXIT_CODE=0; neither contains access-violation, SCRIPT ERROR, or teardown ERROR output.
- R08 Home frontier PASS.
- R09 V05 real-input runs 1 and 2, each with seven captures, mouse PASS, touch PASS, and exit 0.
- R07 page focus, node visual, full Sunny Cove background.
- M18 star contract, replay, cumulative rewards, reward claim; M20 ApplicationShell.
- Fresh L1–L100/Tiki progression, performance/stability, save/restart persistence.
- M01/M02/M03/M09/M13/M14/M15 and the ten-island R04 surface authority regression.
- Asset validation, Godot editor import/parse, Godot boot.

The corresponding exact output files and command details are enumerated in COMMAND_INDEX.txt; machine-readable SHA-256 pairs are in source_log_sha256.json.

## Corrected project.godot metadata

Current canonical project.godot is unchanged and has no tracked diff.

- SHA-256: DE79FF257F4F4BE0DBE01BECB574A3E502F9BF36F07CF662B293A4B6242D0267
- Git blob ID (SHA-1): 15a168304d729108313be58563592d50da1f99bf
- GameFeelFlow autoload remains res://addons/game_feel_flow/core/game_feel_flow.gd; its UID sidecar maps to uid://ckhnfaf1odnpl.

The R03 reconciliation note incorrectly labeled the Git blob ID as SHA-256. The R03 execution log carried the actual SHA-256. R04 records one correct SHA-256 consistently in project_godot_hash.txt and release_manifest_r04.json; historical R03 files were left immutable.

## Release manifest identity

release_manifest_r04.json distinguishes:

- Product baseline: 8801136b18a502d08e5f03b1995f470ad5b1ecad.
- R03 implementation/evidence: c2ef88d772c8a5ae38a99f9c1b24e92eb09af2fe.
- R03 builder handoff: 7a00da5e5163e0e31e7e6a7ed621ce845413890d.
- R04 evidence publication/end HEAD: 6c76741ea49ac2c084d05546b968871eba5f6498.

No export_presets.cfg is present; no distributable was generated and the artifact list is empty. Physical-device performance and native install/signing remain unverified.

## Final repository proof and stash state

evidence/final_git_proof.txt records the Git commands and their outputs immediately after evidence commit 6c76741 was pushed:

- HEAD, origin/main, and remote main all equal 6c76741ea49ac2c084d05546b968871eba5f6498.
- Ahead/behind was 0/0.
- project.godot and TASKS.md had no diff.
- The only untracked paths in that snapshot were the two owner critique PNGs. They remain untouched and outside release inputs.
- The full historical stash list is recorded. A stash is NOT required to reproduce the current canonical working tree; no historical stash was dropped.

The Codex log itself is published in a subsequent log-only commit. Final post-log-commit ref parity is verified after push and reported in the handoff.

## Files changed

Evidence-only additions are under coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/evidence/: 31 exact .txt log copies, command index, source/copy SHA-256 index, project hash evidence, release manifest, diff-check capture, and final Git proof. This execution log is the only addition outside that evidence directory.

No other files changed. Root TASKS.md is byte-for-byte unchanged.

## Builder stop marker

AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R04
