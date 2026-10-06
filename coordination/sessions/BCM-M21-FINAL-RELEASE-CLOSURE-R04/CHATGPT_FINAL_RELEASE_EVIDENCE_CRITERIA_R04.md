# BCM-M21-006-R04 — Locked Evidence Publication Closure Criteria

Status: **LOCKED BEFORE EXECUTION**

## Scope

Evidence-only closure for R03.

Production runtime, accepted visuals, campaign data, economy draft, gameplay, and current test semantics are frozen.

Allowed:
- publish/copy existing R03 command logs as commit-eligible text evidence;
- rerun a command only when its original log is unavailable;
- correct R03 evidence metadata;
- add final sync/cleanliness proof;
- update builder evidence log.

Forbidden:
- production code changes;
- new visual changes;
- changing test tolerances/assertions;
- changing campaign/save/economy semantics;
- starting M22.

Root `TASKS.md` remains read-only to Codex.

## Required committed evidence

Under:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/evidence/`

publish commit-eligible text evidence for:

1. M07 R04 final
2. M07 R05 final
3. M07 composition final
4. M07 R06 final
5. M08 run 1
6. M08 run 2
7. R08 Home frontier
8. R09 V05 run 1
9. R09 V05 run 2
10. R07 page focus
11. R07 node visual
12. full Sunny Cove background
13. M18 star contract
14. M18 replay
15. M18 cumulative rewards
16. M18 reward claim
17. M20 ApplicationShell
18. fresh L1–L100 progression
19. performance/stability
20. save/restart persistence
21. accepted gameplay regression commands
22. asset validator
23. Godot import/parse
24. Godot boot
25. git diff --check
26. final git/ref/status proof.

Every evidence file must include or be accompanied by:
- command;
- stdout/stderr;
- explicit exit code.

M08 evidence additionally must make clear:
- expected PASS marker;
- exit 0;
- no access violation;
- no SCRIPT ERROR / ERROR teardown failure.

R09 V05 must show two consecutive exit-0 passes.

## Existing local logs

Because `*.log` is ignored:

Preferred:
- copy exact existing local `.log` content into corresponding `.txt` file;
- compute SHA-256 of source log and committed txt;
- hashes must match when bytes are copied exactly.

If a source log is absent:
- rerun that command;
- capture directly to `.txt`;
- document rerun.

Do not edit outputs to make them cleaner.

## project.godot evidence

Calculate canonical current tracked `project.godot` SHA-256 once.

Update the evidence so one consistent hash is used.

Record:
- current Git blob/path identity;
- SHA-256;
- zero tracked diff;
- autoload path authority.

Do not change project.godot unless a tracked diff has unexpectedly reappeared.

## Release manifest

Create:
`release_manifest_r04.json`

Include separate fields:
- `product_baseline_sha` = R03 frozen production baseline;
- `r03_implementation_evidence_sha`;
- `r03_builder_handoff_sha`;
- `r04_evidence_closure_sha` may be filled in the final log/receipt if self-reference prevents putting final commit inside the manifest;
- Godot version;
- save schema;
- main scene;
- viewport;
- export preset availability;
- artifact list/hashes;
- known limitations.

Do not claim a distributable exists when it does not.

## Final repository proof

Publish:
- `git status --short --branch`;
- `git rev-parse HEAD`;
- `git rev-parse origin/main`;
- `git ls-remote origin refs/heads/main`;
- `git rev-list --left-right --count HEAD...origin/main`;
- tracked-diff proof for project.godot;
- list of remaining untracked owner critique files;
- stash list with an explicit statement that no stash is required to represent the current working tree.

Historical preservation stashes must not be silently dropped.

## Final log

Create:
`docs/codex-logs/CODEX_LOG_M21_FINAL_RELEASE_CLOSURE_R04.md`

Do not edit root TASKS.md.

Final marker exactly:

`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R04`
