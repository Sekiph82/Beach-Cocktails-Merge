# BCM-M00-001 — Equality Evidence Remediation V01

## Scope

Remediate only audit finding `F-M00-001-EVIDENCE-001` from:

`docs/audits/BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V01_AUDIT.md`

Do not start BCM-M00-002 and do not begin Godot V7 integration.

## Mandatory governance

Read and obey:

- `AGENTS.md`
- `TASKS.md`
- `docs/prompts/BCM-M00-001.md`
- `docs/audits/BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V01_AUDIT.md`

Never edit `TASKS.md`.

## Local workspace

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository:

`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:

`main`

## Required work

1. Run the normal sync-first preflight from the canonical local workspace.
2. Fetch `origin/main`.
3. Reconcile safely if the owner has created any new local work since the V01 log. Preserve all owner work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.
4. Create a new immutable remediation log:

`docs/codex-logs/BCM-M00-001_REPOSITORY_SYNC_AND_BASELINE_V02_CODEX_LOG.md`

The V02 log must record:

- remediation work item and audit finding ID;
- start HEAD;
- fetched `origin/main` HEAD;
- branch/remotes/status/divergence;
- whether any new owner work had to be reconciled;
- all files changed by the remediation;
- confirmation that `TASKS.md` was not modified;
- confirmation that BCM-M00-002 / V7 integration was not started;
- commands/checks performed and exact results;
- known limitations.

5. Commit and push the V02 remediation log and any legitimately required owner-preservation reconciliation changes.
6. After the final V02 log-bearing commit has been pushed, run **without making any further repository changes**:

```powershell
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
```

7. The SHA from `git rev-parse HEAD`, the SHA from `git rev-parse origin/main`, and the SHA shown before `refs/heads/main` by `git ls-remote` must be identical.
8. Do not create another commit after this equality check.
9. In the Codex completion response, return only:

- V02 log GitHub URL;
- final commit SHA;
- exact output of `git rev-parse HEAD`;
- exact output of `git rev-parse origin/main`;
- exact output of `git ls-remote origin refs/heads/main`;
- statement that no repository changes occurred after those commands;
- statement that `TASKS.md` was not edited;
- statement that BCM-M00-002 / V7 integration was not started.

Then STOP for independent ChatGPT re-audit.

## Important evidence note

Do not attempt to write the final commit SHA into the same commit that creates the log. That is self-referential in Git. The immutable V02 log is committed first; the final local/remote equality is then proven by the exact post-push command outputs in the completion response while GitHub independently exposes the remote `main` SHA for audit.
