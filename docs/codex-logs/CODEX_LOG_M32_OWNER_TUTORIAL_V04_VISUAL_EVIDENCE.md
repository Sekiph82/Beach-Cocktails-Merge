# CODEX EXECUTION LOG — BCM-M32 TUTORIAL V04 SIX-STEP VISUAL EVIDENCE

## Work item and contract

- Work item: `BCM-M32-OWNER-TUTORIAL-REVIEW`.
- Active prompt: `coordination/sessions/BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01/CHATGPT_TUTORIAL_V04_SIX_STEP_VISUAL_EVIDENCE_PROMPT.md`.
- Prompt version: V04 six-step visual evidence.
- Required stop marker: `AWAITING_GPT_AND_OWNER_TUTORIAL_VISUAL_REVIEW`.
- Worktree branch state: detached at the synchronized `main` commit; no new branch was created.

## Repository and sync preflight

- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Start HEAD: `0e79cfee71a0161965d1a66f43164eec1e3e5e48`.
- `git fetch origin main`: succeeded.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Start `origin/main`: `0e79cfee71a0161965d1a66f43164eec1e3e5e48`.
- Start `git ls-remote origin refs/heads/main`: `0e79cfee71a0161965d1a66f43164eec1e3e5e48`.
- Evidence start HEAD: `0e79cfee71a0161965d1a66f43164eec1e3e5e48`.
- End-of-evidence commit SHA: `2eb55e44bb90df417b808dff117e1d5f1419eca0`. The record-only log commit follows it.

## Files changed

- `coordination/sessions/BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01/evidence/V04-six-step-screenshots/README.md`.
- `coordination/sessions/BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01/evidence/V04-six-step-screenshots/OWNER_FEEDBACK.md`.
- Twelve original PNGs: six steps at each of `390x844` and `432x960`.
- Two six-panel contact sheets at their original per-frame pixel dimensions: `contact_sheet_390x844.png` (`828x2768`) and `contact_sheet_432x960.png` (`912x3116`).
- This execution log.

## Implementation and capture method

- Production tutorial source is commit `8050bd796c7aecd49b73c0a3123cdc5d30a3c36e`; V04 capture project source was archived from commit `0e79cfee71a0161965d1a66f43164eec1e3e5e48`. The tutorial code/assets were unchanged between these source points.
- Each capture ran from a separate `%LOCALAPPDATA%\BeachCocktails\BCM-M32-Tutorial-V04-SixStep-Evidence\<resolution>` test project with a unique Godot application name and separate `user://` data. The project was extracted from committed Git source; reusable generated Godot import cache was read from the existing isolated owner-review project. No owner project, save, open game window, stash, or production asset was edited.
- Runtime: Godot `4.7.2.stable.official.ed1daf0bf`, OpenGL API 3.3.0 Compatibility, Intel Iris Xe Graphics.
- The harness never writes `GameplayTutorial.current_step`. It starts the production tutorial, dispatches launch mouse input to the production `ShotController`, waits for the physics `MergeQueue` and `GameManager.on_merged`, then seeds an order-level drink through `GameManager.spawn_drink` and invokes the production stocked-target matcher. The production collection tween, session delivery signal, and tutorial hook advance DELIVER. Continue steps use input events on the production `TutorialContinue` button.
- Reversible test setup: the matching merge partner and one L5 order drink were spawned in the isolated game through production `GameManager.spawn_drink`. Sunny Cove's original level data was retained byte-for-byte; the ordinary L5 delivery completes level 1 and its real Level Complete feedback remains visible in later captures.
- At 390x844 the VIP Continue button bounds are `[229.2, 826.66, 91, 52]`, extending below the viewport. The harness activated that focused production button with Enter for the VIP-to-MOVES transition; the following Continue fit and received a mouse event. Both Continue inputs fit and received mouse events at 432x960.
- The PNGs are full viewport image captures from the running game. They were not cropped, retouched, or composited. Contact sheets contain the six untouched original captures.

## Commands and builder checks

- Graphical launch command for each size used `godot.exe --path <isolated-project> --rendering-method gl_compatibility --resolution <390x844|432x960> -- --evidence-dir <matching-evidence-folder>`.
- 390x844 process exit: `0`; output contained six `V04_CAPTURE` lines and `V04_SEQUENCE_COMPLETE six_steps=6 direct_current_step_mutation=false` at `2026-10-12T17:50:12Z` (first frame `17:50:11Z`).
- 432x960 process exit: `0`; output contained six `V04_CAPTURE` lines and the same completion marker at `2026-10-12T17:50:22Z` (first frames `17:50:21Z`).
- Pillow validation opened and verified all 12 PNGs, exact viewport dimensions, and nonzero file lengths. Both contact sheets were also opened and verified.
- `git diff --check`: passed.
- `git diff --exit-code HEAD -- TASKS.md coordination/sessions/BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01/evidence/godot_tutorial_owner_review.png docs/codex-logs/CODEX_LOG_M32_OWNER_TUTORIAL_REVIEW_V03.md`: passed; tracker and V03 artifacts unchanged.
- After pushing evidence commit `2eb55e44bb90df417b808dff117e1d5f1419eca0`, every one of the 14 PNGs in `origin/main` had a nonzero blob size and the same Git blob ID as its local file.
- Both graphical runs logged two startup UID fallback warnings (`WorldMapScene.tscn` and `main.tscn`), then launched and captured all stages. No runtime parse errors or capture failures remained in the final runs.
- No separate automated test suite was run or added; this task's required verification was the graphical transition/capture sequence.

## Manual visual checks and findings

- Inspected original frames at both resolutions and the 390x844 contact sheet.
- The custom drink/arrow/hand, merge, delivery, crown, move/star, and retry drawings are distinguishable at full resolution. The short step text fits its card.
- At 390x844 the VIP Continue control extends 34.66 px below the viewport; this is a real input accessibility issue. The focused Enter event allowed evidence collection without changing the screen.
- The tutorial card partly covers the Pause control at lower left. The Continue and Skip controls are crowded against the card edge.
- After the seeded L5 delivery completes Sunny Cove level 1, the real Level Complete result panel overlaps the tutorial in MOVES & STARS and PLAY AGAIN captures and covers much of the board. Result-panel text is clipped at the right edge in both narrow viewports. PLAY AGAIN highlights the result-panel body while its Retry instruction's action row is behind/under the tutorial card.
- These are builder observations only. The six owner feedback cells remain `PENDING_OWNER`; no visual approval or design pass is claimed.

## Manual checks not performed and limitations

- No physical touch device or owner-led review was performed. The input events were delivered to the real production handlers by the isolated capture harness.
- No redesign or remediation was made, as prohibited by V04. The screenshots preserve the observed overlay/button issues for review.
- Existing V03 evidence and log were checked unchanged.

## Owner-work protection

- Root `TASKS.md` was not modified.
- Canonical Desktop owner checkout remains at the synchronized `0e79cfee71a0161965d1a66f43164eec1e3e5e48`; its seven tracked owner edits and five untracked owner paths remain present and unstaged. Existing stashes were not touched or dropped.
- Existing owner-review project data/windows and original V03 evidence were not modified.

## Final publication and parity

- Evidence commit `2eb55e44bb90df417b808dff117e1d5f1419eca0` was published by fast-forward to `main`. At evidence-publication verification, local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` all equaled that SHA. The record-only log commit is a direct child and will be pushed next; final post-log parity is verified separately and reported in the handoff.
- Required stop marker: `AWAITING_GPT_AND_OWNER_TUTORIAL_VISUAL_REVIEW`.
- Root `TASKS.md` remains read-only and independent review/owner acceptance remains pending.
