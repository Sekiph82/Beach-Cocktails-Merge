# BCM-M33 R04 publication and Desktop sync addendum — V02

This immutable addendum supersedes the pending publication/parity lines in `CODEX_LOG_M33_R04_V01.md`. V01 accurately captured the initial DNS failure and the state at its commit time; the retries and canonical Desktop sync completed afterward.

## Published commits

- Product/evidence commit: `7954ccbe4f76e0bf4f628ebb8b406508c6e8efd5` — `feat(campaign): apply M33 R04 approved difficulty profiles`.
- Builder log commit: `eeaf08833e9b2107c4f0c6f75a387867e0d07f39` — `docs: record M33 R04 builder evidence`.
- Both were pushed directly to the existing `origin/main`; no GitHub branch was created. The first push attempt failed before changing a ref because GitHub DNS could not resolve. The retry succeeded, and `git ls-remote origin refs/heads/main` returned `eeaf08833e9b2107c4f0c6f75a387867e0d07f39`.

## Canonical Desktop safe sync

- Before sync: canonical `main` was `e6159421a137594e2f857888c09038224c1ffe3d`, zero ahead/two behind. Seven tracked paths were modified and fifteen untracked files were inventoried.
- The incoming diff contained 31 paths and intersected none of the full dirty-path inventory. A tracked-only stash, `owner-local-safe-sync-e615942`, was created and retained; no untracked file was stashed.
- `git merge --ff-only origin/main` advanced Desktop to `eeaf08833e9b2107c4f0c6f75a387867e0d07f39`. The exact new stash was applied without dropping it.
- Verification: all 7/7 tracked owner file hashes matched the saved stash tree; all 15 untracked files remained; zero conflict entries, zero staged paths, and `git rev-list --left-right --count HEAD...origin/main` was `0 0`.
- Final parity at this verification: Desktop `HEAD`, local `origin/main`, and `git ls-remote origin refs/heads/main` all equaled `eeaf08833e9b2107c4f0c6f75a387867e0d07f39`.
- Desktop root entries matching Beach/Cocktail/BCM remained only the authorized project folder. The exact tutorial-review `.lnk` remained absent, no other shortcut targeted the launcher/review project, and no matching active tutorial-review process was present. No Desktop root item was created or deleted.
- Root `TASKS.md` remained unchanged.

## Final builder boundary

R04 builder work is committed and published. Static campaign/content, Godot content, navigation, and save probes passed. The bounded physical samples did not complete their selected levels, and no human playtest was performed; physics reachability and the 2–5 minute typical / ≤8 minute p90 human targets remain unverified. Cross-island recipe repetition remains 361 and is documented. Do not transition `TASKS.md` or treat this builder record as acceptance.

Required stop marker: `AWAITING_GPT_M33_R04_AUDIT_AND_OWNER_DIFFICULTY_REVIEW`.
