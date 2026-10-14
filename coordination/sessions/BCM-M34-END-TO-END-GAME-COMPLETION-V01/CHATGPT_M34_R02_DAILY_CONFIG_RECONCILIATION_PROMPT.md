# BCM-M34-R02 ONE-SHOT CODEX REMEDIATION MASTER

Read M34-R01 independent audit and R01 log. Run all work below without pausing, in an isolated non-Desktop worktree at origin/main; do not touch owner canonical Desktop checkout, dirty/untracked files, stashes, saves or root TASKS.md.

R02-001: Resolve single-source authority for Daily Rewards. Existing data/campaign/daily_rewards.json is stale (OWNER_DECISION_REQUIRED; slot3 disabled null) while runtime DailyRewardService hardcodes approved values. Safely update only this versioned tracked JSON in isolated checkout to OWNER-LOCKED UTC_MIDNIGHT, five slots [free 40 Coins, verified ad +20 Energy, verified ad +40 Coins, verified ad +2 Gems, verified ad +80 Coins]. Read actual live call chain, have service consume canonical validated JSON rather than divergent hardcoded policy, fail closed on invalid fields and prevent silent code/data drift. Check competing owner-local changes ONLY with read-only status/hashes. No overwriting canonical checkout or other JSON. On sync conflict isolate and report, do not force.

R02-002: Add focused Godot tests proving actual runtime JSON values and UTC day reset, schema migration, rollback, missing ad provider fail-closed, duplicate receipts, full energy, slot3 +40, invalid/tampered config rejected, old/new saves. Preserve all 5 slots and their owner-approved rules; real ad provider remains unavailable until native verified callback. No simulated grant in production.

R02-003: Investigate economy probe's reported 15 leaked ObjectDB instances and 3 live resources. Correct test fixture lifecycle cleanup where safe; verify no production leak. Don't suppress warnings artificially or damage existing accepted user artwork/physics. Scope and report residual warnings honestly.

R02-004: Audit M34-005 26 asset REVIEW candidates and provide reference-based verdicts only; remove only files proven unused with reversible commit, never untracked/owner-local or Godot active caches. Do not create Desktop-root files. No native SDK, store upload, signing or real transactions in this remediation.

Push safe fast-forward commits to main, retain root TASKS.md untouched; publish one log and exact commands/test results. Stop marker AWAITING_GPT_M34_R02_INDEPENDENT_AUDIT.
