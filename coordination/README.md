# Beach Cocktails Merge Coordination Protocol

## Authority model [OWNER-LOCKED — 2026-09-28]

- GitHub `origin/main` is repository truth.
- Root `TASKS.md` is the **only live project-status tracker** and the only H!veAI current-state/parser surface.
- `AGENTS.md` and `coordination/AUDIT_POLICY.md` are governance manuals, not status trackers.
- `coordination/sessions/<SESSION-ID>/` contains versioned cycle evidence.
- Historical branch task lists, visual-production task lists, manifests, screenshots, prompts, logs, and audits are evidence only and must not mirror current project state.
- Do not create `.hiveai/*`, `coordination/SESSION_INDEX.md`, `coordination/AUDIT_INDEX.md`, `docs/04_ROADMAP.md`, dashboards, progress snapshots, active-cycle maps, artifact maps, or equivalent live status mirrors.

## Versioned cycle bundle

```text
CHATGPT_EXECUTION_PROMPT_VNN.md
CHATGPT_AUDIT_CRITERIA_VNN.md
CODEX_LOG_VNN.md
CHATGPT_AUDIT_VNN.md
```

Owner rulings may be added when needed, but they are contract evidence rather than a second tracker.

## Normal cycle flow

1. ChatGPT reads synchronized root `TASKS.md`, current source, prior relevant audits, and owner rulings.
2. ChatGPT publishes the versioned execution prompt and locked audit criteria.
3. Codex synchronizes the canonical Desktop checkout, verifies root `TASKS.md` authorizes Codex, implements/tests, writes the matching immutable `CODEX_LOG_VNN.md`, pushes, synchronizes the canonical Desktop checkout, and stops at `AWAITING_AUDIT`.
4. Codex never edits root `TASKS.md` and never self-awards an audit verdict.
5. ChatGPT independently audits actual GitHub state and evidence.
6. ChatGPT alone updates root `TASKS.md` after the audit or owner-gate decision, including `Project Status`, canonical task rows, next actor/action, and `Progress`.

## H!veAI parser contract

The parser reads root `TASKS.md`. Keep `## Project Status` near the top and preserve these exact labels:

- `Current Milestone`
- `Current Sprint`
- `Current Task`
- `Current Task Status`
- `Next Task/Action`
- `Required Actor`
- `Tracking Repository`
- `Tracking Branch`
- `Progress`

Canonical task rows use:

```text
- [x] TASK-ID — validated complete
- [~] TASK-ID — active / owner closure pending
- [ ] TASK-ID — planned / pending
- [!] TASK-ID — blocked / changes required
```

Every canonical task ID appears exactly once. Progress is computed from unique canonical task IDs in root `TASKS.md` only.

Canonical repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
Canonical tracker: `https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/TASKS.md`