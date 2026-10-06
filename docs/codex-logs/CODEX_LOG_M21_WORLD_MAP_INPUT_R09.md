# Codex Execution Log — BCM-M21-001-R09 Sunny Cove Back Input Closure

## Start and synchronization

- Work item: BCM-M21-001-R09; user-directed narrow closure for real Sunny Cove Island Map Back mouse/touch navigation.
- Start HEAD after safe sync: `fd9ef854dd7995f78b06b0b6eb23ca18d30a76c1`; branch `main`; remote `origin`.
- Pre-sync HEAD was `dd6f65f3f101ef370d966c09a9fb57f632de3132`, behind-only `0 ahead / 5 behind`.
- Pre-sync owner-local state: modified tracked `project.godot` plus two pre-existing untracked owner critique PNGs. Incoming paths did not overlap. Created tracked-only stash `owner-local-safe-sync-dd6f65f`, fast-forwarded, then reapplied only that stash without dropping it. Owner critique PNGs were untouched.
- After sync `HEAD == origin/main == fd9ef854dd7995f78b06b0b6eb23ca18d30a76c1`; live `TASKS.md` authorizes BCM-M21-001-R09, CODEX, and remains read-only.
- User narrowed this follow-up to the Sunny Cove Island Map Back control and explicitly froze World Map→Home, all visuals, map geometry, gameplay, and economy.

## Execution

- Read the synchronized R09 prompt/criteria, active TASKS row, R08 audit, production controllers, and unchanged V05 probe before code edits. Captured the unmodified V05 failure first in `coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/evidence/initial_v05_unchanged.log` (exit 1; three failed checks).
- Diagnosed the first failure with the real production Back control and actual viewport pointer movement/press/release. The prior hit target was `LevelNodes`, with no Back signal and no view transition. Full measurements and per-failure classification are in `evidence/real_input_diagnostics.md`.
- Production fix is limited to `scripts/campaign/island_map_controller.gd`: the existing Back Button is placed in the Island Map root input layer at z index 10. Its visual rect and styling remain unchanged. No World Map/Home code was modified.
- Updated `tests/m21_world_map_production_v05_probe.gd` to retain real mouse/touch inputs and assert one signal/transition, instance reuse, visibility, and the World Map→Home route. No direct signal emit is used as input proof.
- Final locked V05 test was run twice consecutively with the normal Godot viewport; both commands exited 0. Both logs report mouse Back once, touch entry once per touch, touch Back once, World Map Back→Home once, and `M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS`.
- Regression checks exited 0: R08 Home frontier, R07 page focus, R07 node visual, M20 app shell, full Sunny Cove background, M18 star contract, asset validator (373/373 checksums; 10/10 R04 families), Godot editor parse/import, headless boot, and `git diff --check`. The R07 visual probes were also run with the normal viewport and returned PASS without script errors.
- Godot probes regenerated three tracked legacy evidence screenshots; those exact generated files were restored byte-for-byte from current HEAD. The existing `project.godot` owner-local diff matches the preserved `owner-local-safe-sync-dd6f65f` stash and remains unstaged. Two owner critique PNGs remain untouched and untracked.
- No visuals, level coordinates, stars, labels, scroll/page logic, gameplay, economy, or TASKS were changed. No manual owner F5 review was performed; this remains builder evidence pending independent audit.

## Final repository state

- Implementation commit: `d5937e2d497b6e315308514599decff2bb0308f0` on `main`.
- The execution log is being published in a follow-up log-only commit so this record can name the implementation SHA. The local owner diff in `project.godot` still exactly matches the preserved safe-sync stash and is not staged. The two owner critique PNGs remain untouched and untracked.
- `TASKS.md` is byte-identical. `git diff --check` and `git diff --cached --check` passed before implementation publication.
- Final push/ref equality is verified after the log-only publication commit and recorded in the handoff response.
- User-requested final marker: `AWAITING_GPT_SUNNY_COVE_BACK_BUTTON_AUDIT`.
