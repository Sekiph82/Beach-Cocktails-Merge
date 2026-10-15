# BCM-M34-R15 Publication Verification — V02

This immutable supplement records the publication checkpoint for the R15 code/evidence change set described in `CODEX_LOG_M34_R15_NUMERICAL_PARITY_V01.md`. V01 is preserved unchanged; this file supplies the values that were not available when V01 was committed.

## Published implementation/evidence checkpoint

- R15 implementation, test, trace, regression, and V01 log commit: `92d9a940caa69232e2ba2428da26d20515f18125`.
- At the post-push verification checkpoint, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `92d9a940caa69232e2ba2428da26d20515f18125`.
- Ahead/behind at that checkpoint: `0/0`.
- The update was a normal non-force push to `main`; no branch was created.
- Root `TASKS.md` remained unchanged at hash `e68c079308626733d2b2759260c4ea75712a6547`.
- BCM-M33-004 remains open. Codex did not assign an acceptance verdict.

## Canonical Desktop after publication

- Desktop remains at `27e38f93e7ef048c51bbd0d34967fc33d73a6988`, 0 ahead / 8 behind the published `origin/main`.
- Its same eight tracked and fifteen untracked owner paths remain present with all 23 hashes matching the pre-sync preservation manifest. Stash `owner-local-safe-sync-5c7f854` remains retained; older preservation stashes were left untouched.
- Desktop was not fast-forwarded because those owner-local changes remain dirty.

## Reused worktree note

- The detached R15 worktree was clean for intended changes at publication except for the untracked, one-action smoke output `r15_parse_probe.json`, created by the initial Godot probe invocation. It was not staged or published. All intended R15 changes and evidence were committed.

Builder stop marker remains `AWAITING_GPT_M34_R15_INDEPENDENT_AUDIT`.
