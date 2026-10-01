# BCM-M21 Final Owner Runtime Closure V02-R01 — Locked Criteria

Status: **LOCKED BEFORE EXECUTION**

Active task IDs:
- BCM-M21-001
- BCM-M21-004
- BCM-M21-006

This criterion supersedes only the V02 sync-preflight handling. All V02 product/runtime criteria remain authoritative.

## A — generated untracked preflight exception

The canonical Windows checkout may contain exactly the currently observed 14 untracked Godot `.translation` binaries whose headers identify them as generated `OptimizedTranslation` resources.

They are permitted to remain during sync if and only if all of the following are true:

1. every file is untracked;
2. none is staged;
3. none existed as a tracked file at local HEAD;
4. none of their paths appears in the incoming tracked diff from local HEAD to `origin/main`;
5. they are not modified/staged/committed by CODEX;
6. no other unexpected tracked or untracked owner file is present.

Deletion is **not required**.

If desired for a clean status display, CODEX may add the exact 14 generated paths to local-only `.git/info/exclude`. Do not edit repository `.gitignore` merely for this preflight.

## B — mandatory safe sync

Starting condition reported by CODEX:
- local HEAD: `814198440dc5c13792087b351a151241bd2664a5`;
- remote/main at blocker: `7d7b490d7a3e5fb42c15850c4ecfedab6ce2bb5e`.

CODEX must:

1. `git fetch origin main`;
2. enumerate the 14 untracked `.translation` paths;
3. compute incoming tracked paths with `git diff --name-only HEAD..origin/main`;
4. prove intersection(untracked generated paths, incoming tracked paths) = empty;
5. prove tracked worktree/index are clean;
6. perform a fast-forward-only sync, e.g. `git merge --ff-only origin/main`;
7. verify local HEAD = origin/main = remote main;
8. only then read/execute the final closure prompt.

If any untracked path collides with an incoming tracked path, or any unexpected local owner modification exists, STOP. Do not delete or overwrite it.

## C — final closure scope

After successful sync, execute the complete V02 final owner-runtime closure for:

- BCM-M21-001
- BCM-M21-004
- BCM-M21-006

All criteria in:
`CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_CRITERIA_V02.md`
remain locked, including:

- real mouse 10/10 and touch 10/10 via viewport dispatch;
- direct launch calls = 0;
- no timers / no TIME UP;
- no active +Time reward;
- correct Sunny Cove five-layer theme;
- old board fallback only;
- calibrated ten-island World Map;
- 486×864 debug override over 720×1280;
- release-relevant regressions;
- owner F5 checklist;
- no release-ready claim before owner PASS.

## D — working-tree interpretation

The final handoff may report:

`TRACKED_WORKTREE_CLEAN_WITH_KNOWN_GENERATED_UNTRACKED_TRANSLATION_EXCEPTION`

only if the exact same verified generated files remain untracked and untouched.

They must not be counted as product changes or committed evidence.

## E — final marker

Technical success:

`AWAITING_OWNER_F5_ACCEPTANCE_V02`

Unresolved technical failure:

`CHANGES_REQUIRED_OWNER_RUNTIME_V02`
