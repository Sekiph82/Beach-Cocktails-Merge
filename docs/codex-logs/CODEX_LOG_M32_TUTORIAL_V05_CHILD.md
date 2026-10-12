# BCM-M32 Tutorial V05 — Child Execution Log

- Work item: BCM-M32 Tutorial V05 visual remediation (V05-001 through V05-004)
- Prompt: `coordination/sessions/BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01/CHATGPT_TUTORIAL_V05_VISUAL_REMEDIATION_MASTER_PROMPT.md`
- Branch: `main` (implementation checkout is a detached managed worktree)
- Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`)
- Start HEAD: `a64e0f2594645b99b2899049281c8277d82beaa1`
- Start preflight: worktree at `a64e0f2`; `origin/main` at `a64e0f2`; ahead/behind `0/0`. Canonical Desktop was initially two commits behind with inventoried owner-local paths; path-disjoint safe sync used the mandated tracked-only stash/ff-only/reapply process. The stash `owner-local-safe-sync-ea44344` was retained. Desktop dirty evidence/project.godot and untracked owner files were preserved.

## Changed files

- `scripts/campaign/gameplay_tutorial.gd`
- `scripts/game_manager.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/campaign/campaign_feedback_overlay.gd`
- `tests/m32_economy_tutorial_probe.gd`
- `tools/owner-review/tutorial_v05_capture.gd`
- `coordination/sessions/BCM-M32-TUTORIAL-OWNER-GODOT-REVIEW-V01/evidence/V05-visual-remediation/` — 12 original runtime frames, two contact sheets, per-resolution interaction traces, README, owner review sheet
- `docs/codex-logs/CODEX_LOG_M32_TUTORIAL_V05_CHILD.md`
- `docs/codex-logs/CODEX_LOG_M32_TUTORIAL_V05_MASTER.md`

## Implementation

Reworked the six-step contextual tutorial to use shipped cocktail/star/VIP art and context highlights. The guidance card is compact and placed below the board for gameplay steps; the completion step uses a top banner while the real Results surface is shown. The Results/Retry presentation scales at both requested phone viewports. Results display is deferred until PLAY AGAIN or Skip. Retry highlight is measured from the actual RETRY control. Gameplay physics, star policy, To-Go/VIP rules, campaign/save semantics, and root `TASKS.md` were not changed.

The graphical evidence runner uses isolated Godot app identities and the production navigation/input/physics/target/retry paths. The disposable save unlocks Levels 1–3 only to expose the production Level 4 optional VIP HUD. It delivers an actual test-only L6 through target capture/tween, order recording, and tutorial hook. Individual images are byte-identical copies of the captured PNGs; contact sheets only arrange them in a 2×3 review grid.

## Commands and results

- Godot: `4.7.2.stable.official.ed1daf0bf`; renderer `Intel(R) Iris(R) Xe Graphics`.
- Clean isolated Godot import: completed. Warnings: invalid UID fallback for existing `WorldMapScene`/`main` references and CSV translation locale warning; no import runtime error.
- `godot --headless --path <isolated project> --script tests/m32_economy_tutorial_probe.gd`: `M32_ECONOMY_TUTORIAL_RESULT=PASS` (including actual Retry target on-screen, completion persistence, replay/settings, and campaign/economy checks).
- 390×844 graphical run: `TUTORIAL_V05_CAPTURE_RESULT=PASS resolution=390x844`; six 390×844 PNGs and trace at `evidence/V05-visual-remediation/390x844/`. Runtime log: `%LOCALAPPDATA%\BeachCocktails\BCM-M32-Tutorial-V05-Visual-Remediation\390x844-graphical-run-r07.log`.
- 432×960 graphical run: `TUTORIAL_V05_CAPTURE_RESULT=PASS resolution=432x960`; six 432×960 PNGs and trace at `evidence/V05-visual-remediation/432x960/`. Runtime log: `%LOCALAPPDATA%\BeachCocktails\BCM-M32-Tutorial-V05-Visual-Remediation\432x960-graphical-run-r08.log`.
- Results RETRY bounds: 390×844 `[P: (62.4, 553.52), S: (265.0, 56.0)]`; 432×960 `[P: (69.12, 620.8), S: (293.0, 56.0)]`; both within the viewport.
- Contact sheets were visually inspected at full six-step layout. Both are at `evidence/V05-visual-remediation/contact_sheet_390x844.png` and `.../contact_sheet_432x960.png`.
- `git diff --check`: pending final pre-commit execution.

## Manual checks / limitations

Inspected all six 390×844 captures and representative launch/merge/delivery/VIP/result captures at 432×960, then inspected both full contact sheets. Tutorial steps visibly use real game sprites and actual HUD/target/result controls. The graphical evidence is builder evidence only. GPT independent visual audit and explicit owner visual acceptance are pending. Existing runtime HUD on the gameplay board is unchanged.

No owner save was modified: captures used distinct `%APPDATA%\Godot\app_userdata\BCM-M32-Tutorial-V05-{390-R07,432-R08}` identities. Only task-owned graphical-run processes were inspected/managed. No release/store workflow was run.

## Repository truth

- `TASKS.md` was not modified.
- Final implementation/evidence commit SHA: `031e620770d3f31f78c24ed53ae7b5fe18e7b22e`. This immutable log follow-up records that implementation SHA; final remote publication equality is verified during handoff.
- Required stop marker: `AWAITING_GPT_AND_OWNER_TUTORIAL_V05_VISUAL_REVIEW`.
