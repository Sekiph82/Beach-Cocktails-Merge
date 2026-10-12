# BCM-M32 Campaign Foundation — Pre-implementation Log V01

Status: `PREFLIGHT_COMPLETE; IMPLEMENTATION_NOT_YET_STARTED`.

## Work item and authority

- Work item: `BCM-M32-001` through `BCM-M32-004`, one continuous master sequence.
- Master prompt: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/CHATGPT_M32_MASTER_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/BCM_M32_AUDIT_CRITERIA_V01.md`.
- Owner rulings: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/OWNER_M32_RULINGS.md`.
- Initial synchronized HEAD: `465862d29b3011233786d2a9cf3fbac0322f935f`.
- Branch / remote: `main` / `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Sync preflight and owner-work preservation

- Ran `git status --short --branch`, `git remote -v`, `git fetch origin main`, and `git rev-list --left-right --count HEAD...origin/main` from the canonical Desktop repository.
- Initial state was `0 ahead / 6 behind`. Incoming paths were `TASKS.md` and the M31 audit plus M32 prompt, criteria, and owner rulings. They were disjoint from all inventoried local changes.
- Followed the standing owner-authorized tracked-only safe-sync procedure. The seven modified tracked paths were stashed under the exact message `owner-local-safe-sync-f8b921c`, fast-forwarded to `465862d`, and restored with `git stash apply`; the stash was retained. No untracked path was stashed or altered. Post-sync divergence was `0/0`.
- Restored owner-local tracked modifications remain unstaged: six M21/M22 evidence JSON files and `project.godot`.
- Untracked owner evidence remains present and untouched: two M21 Home critique PNGs, M23 closeout text, the M23-R01 image evidence folder, and `CODEX_LOG_M23_R01_V01.md`.
- Existing branches/worktrees were inspected. No branch or worktree was created.

## Synchronized task facts and initial source findings

- Root `TASKS.md` identifies `BCM-M32-001` as active and directs Codex to execute the master through M32-004. It was read and not modified.
- Canonical registry has ten ordered island IDs: Sunny Cove, Tiki Island, Azure Bay, Coconut Beach, Sunset Island, Party Beach, Frozen Paradise, Volcano Bay, Billionaire Island, and Final Island (TBD). Sunny Cove declares 100 levels; the other nine declare zero. The first post-Sunny-Cove island is Tiki Island.
- Existing `LevelDatabase` already has SEED/FULL validation modes, canonical JSON loading, and objective legality checks. `CampaignManager` supports completion, next-island unlock rules, and persisted progression.
- `GameEconomy` provides coin/booster inventory and idempotent reward grants, but no purchase/spend service is connected to a player-facing shop and Home gems are a fixed display value. Booster consumption has no production flow. Existing time booster is explicitly retired by owner rules.
- The interactive tutorial and first-island authoring paths require direct source inspection before changes. Sunny Cove canonical rows and existing owner visuals are protected.

## Planned implementation and verification boundaries

- M32-001: add an explicit ten-island/100-level campaign contract, staged `PENDING_CONTENT` readiness, strict exactly-100 contiguous full-content validation, and a deterministic generation/verification workflow that reuses production objective and move/star rules. Sunny Cove source records will be fingerprinted and preserved byte-for-byte.
- M32-002: add a compact, varied Tiki Island playable slice against existing theme/map/surface authorities and prove sequential unlock/play/result/retry/save-load with production systems. No other island content and no Final Island naming/theme changes.
- M32-003: implement data-driven free-game currency sources/sinks, saved gems with compatibility defaults, transactional idempotent spending/grants, a functioning Shop and booster display/use path, without payments, ads, timers, or gameplay-physics changes.
- M32-004: implement guided in-game launch/merge/To-Go/VIP/move-star/retry tutorial with skip, settings replay, persistence and accessibility preferences, retaining real engine gameplay and save recovery.
- Required probes, Godot import/parse/boot and affected baseline regressions will run only in a separately identified project copy configured with a verified distinct `user://` path. Real user saves and diagnostic logs are not test targets.
- Child commits/logs and a final master handoff will be published on the existing `main` branch. Independent audit remains pending; this log makes no acceptance claim.

## Initial preservation boundary

- No source or product data has been modified yet.
- `TASKS.md`, owner-local tracked changes, all untracked owner evidence, owner-approved art, local save data, existing stashes, and existing branches/worktrees remain untouched.
