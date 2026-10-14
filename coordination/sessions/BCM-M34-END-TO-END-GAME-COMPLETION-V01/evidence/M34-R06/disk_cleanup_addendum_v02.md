# R06 V02 disk-cleanup execution addendum

This addendum records a cleanup pass that completed in the same shared Windows environment after the initial V01 log snapshot. It corrects the V01 statement that no registered worktrees were removed. The original log is preserved unchanged.

## Registered worktrees removed

Each target was a registered clean worktree under `.codex\worktrees`, at a commit reachable from `origin/main`, with committed logs, no task process command-line reference, no reparse points, and an empty porcelain status immediately before the normal `git worktree remove` operation. No `--force` was used. One clean isolated BCM worktree was retained for the R06 work.

| Worktree | Logical bytes | Measured free-space delta |
|---|---:|---:|
| `bcm-m12-v03-visual-regeneration\Beach Cocktails - Merge` | 234,576,171 | 236,527,616 |
| `bcm-m12-v04-staged-masters\Beach Cocktails - Merge` | 721,110,669 | 725,823,488 |
| `bcm-m12-v06-work` | 413,599,985 | 415,494,144 |
| `bcm-m12-world-map\Beach Cocktails - Merge` | 408,220,381 | 414,449,664 |
| `bcm-m14-gameplay-session-bridge\Beach Cocktails - Merge` | 745,443,658 | 751,366,144 |
| `bcm-m32-owner-tutorial-review` | 1,587,341,304 | 1,568,804,864 |
| `bcm-main-merge` | 435,566,411 | 432,500,736 |
| `bcm-owner-audit-remediation\Beach Cocktails - Merge` | 435,566,298 | 426,070,016 |
| `bcm-remaining-table-assets` | 418,138,815 | 420,163,584 |
| `beach-visual-production\Beach Cocktails - Merge` | 447,259,037 | 449,769,472 |

Combined logical size was 5,846,822,729 bytes. Measured per-batch free-space deltas summed to 5,840,969,728 bytes. The whole-task volume delta is smaller because free space changed concurrently; see `cleanup_receipts.csv` for each full path and before/after sample.

At the time of this pass the exact removal of the M25 `.godot` cache was blocked by execution policy; this pass stopped without another deletion mechanism. Later, the concurrent R06 cleanup recorded its own exact M25 cache removal in the committed `cleanup_receipts.json`. The cache is now absent. That receipt is separate and is not attributed to the worktree cleanup above.

The R05 canonical-sync backup and R06 sync backup were retained. Seven owner-dirty tracked-file hashes, all 15 owner-untracked hashes, `TASKS.md`, canonical `project.godot`, the 72-stash inventory, and the canonical checkout tree were verified unchanged after cleanup and Android setup. The canonical Desktop checkout now shows `behind 3` because remote main advanced during this task; its dirty owner paths remain untouched, and no Desktop fast-forward was attempted.

The earlier report of approximately 200 GB free followed by 81.2 GB free cannot be attributed to BCM without historical volume telemetry. This task's measured removals are evidence only for the targets and time windows listed above.
