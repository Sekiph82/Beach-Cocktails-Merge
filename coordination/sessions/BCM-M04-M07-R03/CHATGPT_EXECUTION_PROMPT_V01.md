# BCM-M04-M07-R03 — Strict Remediation Master Execution Prompt V01

Status: **ISSUED**

This prompt supersedes `coordination/sessions/BCM-M04-M07-R02/CHATGPT_EXECUTION_PROMPT_V01.md` for all unresolved M04-M07 remediation work.

## Goal

Perform one final strict remediation sequence across M04, M05, M06 and M07 using the latest independent ChatGPT audit findings. Execute all four milestones in one Codex session, but keep each milestone isolated with its own bounded commit and its own Codex log.

Required order:

1. M04-R02
2. M05-R02
3. M06-R03
4. M07-R02
5. STOP for independent ChatGPT audit

Do not self-audit. Do not mark any milestone `AUDITED_PASS`.

## Canonical repository/workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: 4.7.x

## Visual authority

Primary owner master:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Later owner directions override the old master where they conflict:

- no persistent/dotted guide line;
- preserve the improved M07 tropical composition as the positive starting point;
- Best Score and Score should sit higher;
- To-Go and NEXT need correct inner-content layout;
- gameplay cocktails should be somewhat larger, with collider credibility preserved;
- danger line should sit lower while remaining synchronized with `death_line_y`;
- launch halo must sit beneath and centered under the held cocktail;
- progression must be an intentional 2x6 layout with top row L07-L12 and bottom row L01-L06.

## Mandatory first step

Read and obey:

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`

Then read all prior relevant strict audit material before editing:

### Historical M04
- `coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md`

### Historical M05
- `coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md`

### Historical M06
- `coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md`

### Historical M07
- `coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V02.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_REMEDIATION_PROMPT_V02.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_AUDIT_CRITERIA_V02.md`
- `coordination/sessions/BCM-M07-R01/CODEX_LOG_V02.md`

The strict findings below are now authoritative remediation requirements.

---

# PHASE 1 — M04-R02 — COMPLETE ASSET-SET TRUTH + VISUAL EVIDENCE

## Why M04 remains open

The previous M04 validator improved cocktails/environment/UI validation, but it still did **not** validate the complete effects directory against repository truth.

Repository reality currently contains four effect PNGs:

- `assets/effects/merge_glow.png`
- `assets/effects/sparkle.png`
- `assets/effects/splash.png`
- `assets/effects/to_go_trail.png`

The existing validator treated only `to_go_trail.png` as canonical M04 effects scope. That means the claimed exact asset-library validation was incomplete.

## Required M04 remediation

1. Decide and document the exact current M04 asset contract from repository/project intent.
2. Do **not** silently delete or ignore `merge_glow.png`, `sparkle.png`, or `splash.png`.
3. If all four effects are part of the approved V7 asset library, include all four in the exact-set validator and manifest.
4. If any are intentionally deferred to M08 but still approved canonical source assets, classify them explicitly as `APPROVED_DEFERRED_EFFECT_ASSET` and still validate existence/tracking/dimensions/alpha/hash.
5. The validator must compare the actual `assets/effects/*.png` set against the explicitly documented expected effects set. No count omission.
6. Recompute the total canonical visual-asset inventory truthfully. Do not keep saying `22` if the real approved library count is larger.
7. Godot probe observed counts must come from the repository directories, not from the expected list length.
8. Retain machine-readable manifest entries for every approved PNG under cocktails/environment/ui/effects.
9. Retain contact-sheet evidence for all effect assets, not just To-Go trail.
10. Preserve the existing M04 semantic evidence package and canonical source bytes.
11. No owner PNG may be edited simply to satisfy the validator.
12. `guide_line` remains forbidden.

## M04 verification

Run:

- corrected Python validator;
- corrected Godot M04 asset-import probe;
- Godot 4.7.x import/parse;
- main-scene startup;
- `git diff --check`.

## M04 log

Write:

`coordination/sessions/BCM-M04-R02/CODEX_LOG_V01.md`

The log must include:

- exact approved file set by folder;
- exact total count;
- classification of all four effect assets;
- actual-vs-expected directory-set output;
- manifest/evidence inventory and hashes;
- test outputs and exit codes;
- changed files;
- confirmation canonical asset bytes unchanged;
- confirmation `TASKS.md` untouched.

Commit and push M04-R02 separately before continuing.

---

# PHASE 2 — M05-R02 — REMOVE CIRCULAR VISUAL/COLLIDER ACCEPTANCE

## Why M05 remains open

The previous M05 remediation produced useful runtime overlays, but key machine checks remain circular:

- production `VISIBLE_BODY_WIDTH_PX` feeds `visual_scale_for_level()`;
- production `COLLIDER_RADII` feeds collider creation;
- the focused probe then checks runtime values against those same production APIs/constants.

That proves implementation consistency, not correctness of body measurement, collider fit, apparent touching quality, pivot credibility, or garnish exclusion.

## Required M05 remediation

1. Preserve the single canonical L01-L12 texture mapping.
2. Preserve invalid-level/L13 safety.
3. Preserve canonical PNG bytes.
4. Create an **independent evidence dataset** outside `scripts/drink.gd` that records, for L01-L12:
   - source image dimensions;
   - independently measured glass/body bbox;
   - independent visible-body center;
   - independent target collision diameter/radius envelope;
   - allowed tolerance.
5. The independent dataset must not be generated by importing production constants from `Drink`.
6. Strengthen the M05 probe so it compares production runtime scale/offset/collider output against the independent dataset/tolerances.
7. Retain actual live-runtime `all_levels_clean`, collider overlay, touching-pair and merge continuity evidence.
8. Add at least one independently measured visible-body overlap/gap metric for representative small/mid/high touching pairs.
9. Representative pairs must include at minimum:
   - low: L01/L02;
   - mid: L06/L07;
   - high: L11/L12.
10. A PASS must fail if visible glass bodies show a material invisible gap or extreme overlap at physical contact.
11. Inspect all 12 pivot/body-center overlays. The test/evidence must not rely only on `sprite.position == Drink.visual_offset_for_level(level)`.
12. Shape diversity must remain explicitly reviewed for tumbler, martini, highball, goblet, coconut, pineapple.
13. Gameplay cocktails must remain somewhat larger than the old pre-remediation M07 baseline, but do not enlarge them if independent body/collider evidence becomes implausible.
14. Preserve launch speed 700, deceleration 180, momentum, L12 cap, rapid launch, restart/Game Over, scoring/To-Go/persistence.

## M05 verification

Run:

- independent M05 evidence-dataset generator/checker;
- strengthened M05 runtime probe;
- M01-M04 regressions;
- Godot import/parse/startup;
- `git diff --check`.

## M05 log

Write:

`coordination/sessions/BCM-M05-R02/CODEX_LOG_V01.md`

The log must explicitly distinguish:

- independent expected measurements;
- production constants;
- runtime observed measurements;
- allowed tolerances;
- visual touching-pair gap/overlap evidence;
- any scale/radius/offset changes made because of evidence.

Commit and push M05-R02 separately before continuing.

---

# PHASE 3 — M06-R03 — BREAK LANDMARK CIRCULARITY + PRESERVE GOOD M07 COMPOSITION

## Why M06 remains open

The previous M06 remediation was materially better than the old prototype evidence, but `expected_landmarks.json` is still derived manually from the same background image and closely mirrors production constants.

This is better than self-calling a production helper, but it is still insufficient as the only visual acceptance basis.

## Required M06 remediation

1. Preserve the successful full-screen tropical/table direction visible in current M07. Do **not** regress to the old M06 prototype-style composition.
2. Keep owner master and canonical background as separate visual references.
3. Retain independent source-landmark dataset, but add **render-space evidence derived from screenshots**, not only source-coordinate transforms.
4. For each viewport 720x1280, 720x1440, 800x1280, compute/record actual rendered visual rail landmarks from the final capture or overlay evidence.
5. Compare production collision rails against those rendered visual rail landmarks with documented tolerances.
6. The expected rendered landmarks must not be obtained by calling `get_table_rail_bounds_at_y()` or copying production constants.
7. Verify far/middle/near left and right visible wood boundaries independently.
8. Verify top stop sits at visible far-table boundary, not scenery.
9. Verify launch remains visibly on wood.
10. Verify danger threshold is low and close to launch while leaving most table usable.
11. Verify both rails remain materially visible/credible on taller and shorter/wider portrait cases.
12. Verify no black bars/stretching and controlled cropping.
13. Preserve final M07-compatible background/table appearance.
14. Preserve no-guide-line rule.
15. Preserve M01-M05 gameplay contracts.

## M06 verification

Run:

- independent reference-evidence generator;
- strengthened screenshot/render landmark comparison;
- M06 geometry probe;
- M01-M05 regressions;
- Godot import/parse/startup;
- `git diff --check`.

## M06 evidence

Retain for all three viewports:

- clean runtime capture;
- runtime rail/danger/launch overlay;
- independently annotated visible-wood rail reference;
- master-vs-runtime table comparison sheet.

## M06 log

Write:

`coordination/sessions/BCM-M06-R03/CODEX_LOG_V01.md`

Commit and push M06-R03 separately before continuing.

---

# PHASE 4 — M07-R02 — REAL CONTENT-BOX / VISIBLE-BOUNDS VALIDATION

## Why M07 remains open

The current M07 production screen is directionally good and significantly closer to the owner master than the old M06 evidence. Preserve it.

However, the focused test still accepts several UI conditions using node-center or percentage-position checks rather than actual visible-content bounds.

Examples:

- To-Go checks positions and box percentages but not the actual visible alpha/text bounds of target/name/reward;
- NEXT checks sprite center but not real garnish clipping into the wood frame;
- progression checks icon mapping/order and scale increase but not actual visible alpha bounds inside each cell;
- score/best content-box acceptance does not fully prove rendered text stays in the intended blank inset.

## Required M07 remediation

Preserve all successful V02 changes:

- score stack higher;
- To-Go/NEXT enlarged/refined;
- lower synchronized danger line;
- larger gameplay cocktails from M05;
- halo centered beneath held cocktail;
- intentional 2x6 progression;
- live Score/Best/To-Go/NEXT;
- shared texture mapping;
- no guide line.

Then strengthen visual correctness as follows.

### A. Define authoritative inner content boxes

For Best Score, Score, To-Go target, To-Go level/name, To-Go reward, NEXT inset, and each progression cell:

1. Define explicit content rectangles in one auditable layout dataset or constants block.
2. These content boxes must be independent from the assertions that test them.
3. Retain them in annotated evidence.

### B. Measure actual rendered visible bounds

For screenshots/runtime output, calculate or otherwise deterministically derive actual visible bounds for:

- Best Score value text;
- Score value text;
- To-Go target cocktail alpha bounds;
- To-Go level/name rendered text bounds;
- To-Go reward rendered text bounds;
- NEXT cocktail alpha bounds;
- all 12 progression cocktail alpha bounds.

Use actual rendered/texture-visible bounds, not only Sprite2D center positions.

### C. Fail on real overflow/clipping

Tests must fail if:

- score/best text enters headings/icons/borders;
- To-Go target overlaps level/name or reward;
- reward exits its intended content region;
- NEXT garnish/alpha pixels enter wood/header/border materially;
- any progression icon visible bounds leave its cell or overlap neighboring cells materially.

### D. Preserve owner-directed composition

The final canonical 720x1280 screenshot should remain recognisably master-like and preserve the improved tropical M07 layout.

Do not "fix" tests by shrinking everything back to unreadable sizes.

### E. Responsive evidence

For 720x1280, 720x1440, 800x1280 retain:

- clean screenshot;
- HUD inner-box overlay;
- visible-bounds overlay;
- master/runtime side-by-side;
- progression 2x6 close-up;
- launch/danger/table overlay.

### F. Regression

Rerun:

- M01 gameplay;
- M02 physics/collision/merge/rapid launch;
- M03 economy/To-Go/persistence/danger/Game Over/restart;
- corrected M04-R02;
- corrected M05-R02;
- corrected M06-R03;
- strengthened M07-R02;
- Godot import/parse/startup;
- `git diff --check`.

## M07 log

Write:

`coordination/sessions/BCM-M07-R02/CODEX_LOG_V01.md`

The log must include:

- final outer HUD rectangles;
- final authoritative inner content boxes;
- actual visible bounds for each dynamic content class;
- progression cell and icon visible bounds;
- exact overflow tolerances;
- clean/overlay evidence inventory + hashes;
- before/after screenshots if any further layout adjustment is made;
- exact regression outputs;
- changed files;
- asset preservation/governance statements.

Commit and push M07-R02 separately.

---

# GLOBAL REGRESSION / GOVERNANCE

After the final M07-R02 commit, rerun the complete suite on final `main`:

- M01 gameplay contract
- M02 physics/collision/merge/rapid launch
- M03 scoring/combo/To-Go/persistence/danger/Game Over/restart
- M04-R02 asset truth validation
- M05-R02 independent visual/collider validation
- M06-R03 independent render-geometry validation
- M07-R02 visible-bounds HUD validation
- Godot 4.7.x import/parse
- main-scene startup
- `git diff --check`

Do not weaken earlier tests simply to make final remediation green. If an earlier assertion must change, explain exactly why the new assertion is stricter or more accurate.

## Absolute governance

- Codex must never edit root `TASKS.md`.
- Codex must never edit ChatGPT-owned audit, re-audit, prompt, criteria, policy or prior audit files.
- Do not rewrite historical Codex logs.
- Do not self-audit.
- Do not assign `AUDITED_PASS`.
- Do not start M08+.
- Do not add `guide_line`.
- Do not destructively edit owner-approved canonical PNGs merely to make tests pass.
- Preserve all owner/local work.
- No reset --hard, force push, automatic rebase, destructive checkout or silent stash.

## Required separate commits/logs

Exactly four bounded remediation commits are required, in this order:

1. M04-R02
   - log: `coordination/sessions/BCM-M04-R02/CODEX_LOG_V01.md`
2. M05-R02
   - log: `coordination/sessions/BCM-M05-R02/CODEX_LOG_V01.md`
3. M06-R03
   - log: `coordination/sessions/BCM-M06-R03/CODEX_LOG_V01.md`
4. M07-R02
   - log: `coordination/sessions/BCM-M07-R02/CODEX_LOG_V01.md`

Do not blend the four remediations into one commit.

## Final synchronization proof

After all four pushes:

```powershell
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git rev-list --left-right --count HEAD...origin/main
git status --short --branch
git diff --check
git diff -- TASKS.md
```

Local HEAD, `origin/main`, and remote `refs/heads/main` must match.

## Completion response

Return only:

- M04-R02 log URL + commit SHA + `AWAITING_AUDIT`;
- M05-R02 log URL + commit SHA + `AWAITING_AUDIT`;
- M06-R03 log URL + commit SHA + `AWAITING_AUDIT`;
- M07-R02 log URL + commit SHA + `AWAITING_AUDIT`;
- final synchronized main SHA;
- confirmation `TASKS.md` untouched;
- confirmation ChatGPT-owned coordination files untouched;
- confirmation M08+ not started;
- confirmation no guide line added.

Then STOP for independent ChatGPT audit.
