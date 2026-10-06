# Codex Execution Log — BCM-M21-001-R07 Full Sunny Cove Background Follow-up R01

## Start and synchronization

- Work item: owner-directed follow-up to BCM-M21-001-R07 — show the complete Sunny Cove Island Map background and realign its level landmarks to the complete art.
- Start HEAD: `79811cec9988efd2dec51b3b74d511695b5e6a80`; branch `main`; remote `origin`.
- Sync preflight: canonical Desktop checkout verified; `git status --short --branch` showed only two preserved owner critique PNGs as untracked; `git fetch origin main` completed; `HEAD...origin/main` was `0 0`.
- Root `TASKS.md` is read-only. The live task remains BCM-M21-001 / R07 awaiting owner review; this follow-up is based on the owner's direct new instruction.

## Execution

- Production correction:
  - Changed Sunny Cove `island_map_layout.page_height` from `1100` to the source image's complete `1280` height and `background_origin_y` from `-178` to `0`.
  - Rebased all ten level landmark centers onto the complete 720×1280 background using the same `+178px` vertical translation. Horizontal centers and authored level ordering are unchanged.
  - Made each repeated page background use the configured page height, extended the scrolling map behind the fixed header/footer so the source remains visible across the full viewport, and made the sky wash transparent.
- Added `tests/m21_island_map_full_background_followup_r01_probe.gd` and retained owner-review evidence in `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence/followup-full-background-r01/`.
- Verification (all exit code 0):
  - `godot_console.exe --headless --path . --script tests/m21_island_map_full_background_followup_r01_probe.gd` — `M21_FULL_BACKGROUND_R01_RESULT=PASS pages=10 levels_per_page=10 background=720x1280`; verifies all ten source dimensions/positions and level hit targets, captures page 1 and page 10, progresses through level 90, and checks frontier 91 reopens on page 10.
  - `godot_console.exe --headless --path . --script tests/m21_island_map_page_focus_r07_probe.gd` — `M21_ISLAND_MAP_PAGE_R07_RESULT=PASS boundaries=9`.
  - `godot_console.exe --headless --path . --script tests/m13_island_map_probe.gd` — `M13_ISLAND_MAP_RESULT=PASS`.
  - `godot_console.exe --headless --path . --script tests/m21_r04_gameplay_surface_authority_probe.gd` — `M21_R04_SURFACE_PROBE_RESULT=PASS islands=10 checks=71`.
  - `python tools/ui_assets/validate_assets.py` — checksums `373/373`, R04 families `10/10`, retired art absent, semantic duplicate groups valid.
  - `godot_console.exe --headless --editor --path . --quit` — exit 0, editor parse/import completed.
  - `godot_console.exe --headless --path . --quit` — exit 0, project boot completed.
  - `git diff --check` — exit 0. `git diff --exit-code -- TASKS.md` — exit 0.
- Manual builder visual inspection: reviewed saved production viewport captures for page 1 and page 10; the full source art reaches the page edges, all ten map nodes sit on their corresponding full-image landmarks, and fixed header/footer remain visible. Owner-native F5 review was not performed and remains pending.
- Preserved the three pre-existing R07 frontier screenshots byte-for-byte after the regression probe regenerated them. Restored Godot's incidental `project.godot` UID normalization from `HEAD`; it is not included in this change.
- Owner critique PNGs already present in the checkout remain untouched and unstaged.

## Final repository state

- Implementation/evidence commit: `e7abee759534ebd6bdbd198a95ad0380bf9b6a77` on `main`, pushed to `origin/main`.
- After push and fetch, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `e7abee759534ebd6bdbd198a95ad0380bf9b6a77`; divergence was `0 0`.
- `TASKS.md` remained byte-identical (`git diff --exit-code -- TASKS.md` exit 0). Only the two pre-existing owner critique PNGs remain untracked; they were not staged or changed.
- Final product implementation and builder evidence are published. Owner-native F5 review and independent ChatGPT audit remain pending; no acceptance or tracker transition is claimed.
- Required stop marker: `AWAITING_OWNER_ISLAND_MAP_BACKGROUND_FULL_REVIEW_R01`.
