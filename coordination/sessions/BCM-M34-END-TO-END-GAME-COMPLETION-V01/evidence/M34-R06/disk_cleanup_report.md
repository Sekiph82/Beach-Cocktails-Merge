# R06 V02-001/002 — C: disk forensics and safe cleanup

## Capacity readings

`System.IO.DriveInfo` measured C: at 1,022,767,394,816 total bytes (952.526 GiB). During the live task, free-space readings moved from approximately 81.25 GiB at the earlier V01 preflight, to 85.172 GiB before the cleanup inventory, 84.206 GiB immediately before the first cleanup batch, and 89.560 GiB after the last cleanup batch. A later post-probe reading was 85.951 GiB. These changes occurred while other Windows/Codex work was active; they cannot all be attributed to BCM. `Get-Volume` returned no data and `fsutil volume diskfree C:` returned access denied, so per-path allocated bytes/deduplication are not exposed here. Per-path figures are logical file lengths; free bytes are volume measurements.

The owner-reported change from approximately 200 GB free to 81.2 GB free is not attributable to this repository from available evidence. The largest inspected BCM-named root was `C:\Users\sekip\AppData\Local\BeachCocktails` at about 16.12 GB logical, but it contains M32 owner-review project copies and source TAR archives. Its matching Codex LocalCache path has the same file IDs for sampled files, so the two paths are shared/hard-linked views, not proof of twice the physical use. The 2.63 GB M25 Temp source snapshot contains a PNG, M17 confirmation JSONs, isolated profile data, and test outputs. Both roots were preserved except for generated `.godot` caches proven regenerable.

## Completed cleanup

Removed six exact generated Godot cache targets:

- Five `.godot` import caches beneath abandoned M32 tutorial/review project copies under the `BeachCocktails` owner-evidence roots; each contained about 1.17–1.18 GB logical and 2,982–3,120 files. Their project source, owner screenshots, archives, saves, and logs remain.
- `C:\Users\sekip\AppData\Local\Temp\BCM-M25-PERCENT400-20261009-182322\.godot`, 1,234,704,014 logical bytes / 3,103 files. The Temp project snapshot, PNG, JSONs, and isolated profiles remain.

The `BeachCocktails` and package LocalCache paths expose the same files through matching file IDs. Removing one `.godot` path caused its paired alias to disappear; the command's second exact-path removal reported “path does not exist.” Both paths were then confirmed absent, so no retry occurred. Six batches reported 6.438 GB / 5.997 GiB in free-space deltas. The endpoint measurement rose by 5,748,166,656 bytes / 5.353 GiB from 84.206 to 89.560 GiB; the difference reflects other volume activity during the batches. See `cleanup_receipts.json`.

## Protected or unresolved categories

- The 16.12 GB M32 owner-review tree and its 15.31 GB app LocalCache view remain because their source TAR and visual evidence ownership/redundancy are unresolved.
- The 2.63 GB M25 Temp source snapshot remains; only its `.godot` cache was removed.
- The R05 owner-data recovery backup and R06 safe-sync backup remain. All 72 Git stashes remain.
- The canonical Desktop checkout is unchanged: seven tracked owner modifications, fifteen untracked owner paths, 72 stash identities, `project.godot`, and `TASKS.md` match their pre-cleanup hashes.
- At the first scan, eleven older clean worktrees were measured at about 7.33 GiB logical. Before any deletion, those paths had disappeared from the registered worktree list; the M33 physics worktree had advanced to `eb05ddc` and had an active process reference. No worktree was removed, no `git worktree prune` was run, and the disappearing paths are recorded as an external state change. Four stale Desktop worktree metadata entries still point to nonexistent checkouts and were not pruned.
- Process command lines showed no Godot process using the removed caches. Windows local open-file enumeration was unavailable: `openfiles /query` said the system object-list flag was disabled. This boundary is recorded rather than inferred away.

## Remaining capacity and categories

After cleanup, C: held more than 85 GiB free at the latest measured point. That exceeds the V02 25 GiB floor and preferred 40 GiB reserve. The downloaded tool archives occupy about 1.63 GB logical; SDK installation is conservatively estimated at 8–15 GiB peak including extraction, leaving at least 70 GiB under the pre-install reading. Actual installation was blocked by shell policy, documented in `android_install_outcome.md`; no installed footprint or Android tool status is claimed.
