# M34-005 Safe Cleanup Record

## Completed bounded cleanup

| Measure | Before | After | Delta |
|---|---:|---:|---:|
| Proven-unused tracked source files | 1 path / 359 bytes at task base HEAD | 0 paths / 0 bytes | 1 path / 359 source bytes removed from current tree |
| Worktree’s modified catalog immediately before deletion | 91 bytes | 0 bytes | 91 checkout bytes |
| Tracked `.import` sidecars | 0 | 0 | 0 |
| Tracked orphan `.import` sidecars | 0 | 0 | 0 |
| Git history size | unchanged | unchanged | No history rewrite or LFS rewrite |
| Release export size | unavailable | unavailable | No export preset/build was available |

The only deletion is `data/campaign/shop_catalog.json`. Its M34 worktree variant was already empty; whole-repository reference search found no runtime/config/test/tool consumer. `ApplicationShell` no longer loads it and the active Shop is Energy-only. The prior Focus offers now survive solely as historical narrative in immutable M32/M34 evidence and are not loaded by runtime. The CSV inventory records type, baseline size, pre-removal hash, reference proof, replacement, disposition, and rollback method.

## Deferred cleanup scope

No cocktail art, accepted island art, gameplay surfaces/profiles, source scenes/scripts beyond the Focus action, plugin directory, historical acceptance evidence, or Godot cache was deleted. No other unreferenced image/script/scene/plugin family was promoted to category E without a complete import/dynamic-reference/dependency-closure proof. A broad duplicate-art and unused-module sweep is deferred rather than treating grep absence as proof. Existing `.godot` cache and task-owned `user://` data are isolated to this LocalAppData worktree; the canonical Desktop cache/user data was never accessed. The cache is not part of tracked source removal.

## Rollback

The removal is a normal tracked deletion in the M34 child commit and can be reversed with a new forward commit restoring `data/campaign/shop_catalog.json` from the parent commit. No destructive history operation is planned. See `cleanup_inventory.csv` for the machine-readable candidate record.
