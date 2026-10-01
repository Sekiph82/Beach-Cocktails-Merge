# CODEX Execution Log — BCM-M20-003

Status: `PUBLISHED_BUILDER_EVIDENCE / AWAITING_CHILD_03_AUDIT`

## Contract and ordered gate

- Work item: `BCM-M20-003` — Settings / Accessibility.
- Prompt/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_03.md` and `CHATGPT_AUDIT_CRITERIA_V01_CHILD_03.md`.
- Child 02 publication gate was satisfied before work began: `de6458fdafe0e258d9ddc89195e36b21f7775126` matched local HEAD, `origin/main`, and remote `main`.
- No Child 04 work was started.

## Synchronization preflight

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Branch: `main`.
- Start HEAD: `de6458fdafe0e258d9ddc89195e36b21f7775126`.
- `git status --short --branch`: clean, `main...origin/main`.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Child 02 equality proof was rechecked before implementation.

## Implementation

- Added `scripts/campaign/user_settings.gd` with an independent schema-versioned preference store at `user://user_settings.json`.
- Added safe defaults and persistence for master/music/SFX volume and mute controls, haptics, reduced motion, and high contrast.
- Missing/unreadable/corrupt/unsupported preference files fall back to defaults without reading or rewriting campaign progression.
- Audio application uses named AudioServer buses when present and returns safe false status for absent Music/SFX buses.
- Added bounded presentation application to gameplay: haptics are forwarded to the existing `FeedbackService` gate, and reduced-motion/high-contrast state is exposed without changing gameplay math.
- Added a dedicated Settings UI surface in `ApplicationShell` with persistent sliders/toggles and a back-to-menu action.
- Added `tests/m20_settings_probe.gd` covering UI fields, defaults, persistence, corruption recovery, audio fallback, haptic gating, presentation state, and campaign isolation.
- `TASKS.md` was not modified.

## Builder checks

- `godot_console.exe --headless --path . --check-only --script res://tests/m20_settings_probe.gd`: exit 0.
- `godot_console.exe --headless --path . --script res://tests/m20_settings_probe.gd`: exit 0; `M20_CHILD_03_RESULT=PASS`.
- Corrupt-settings fixture emitted the expected JSON diagnostic and recovered to safe defaults.
- `git diff --check`: passed before commit.
- Manual owner-native visual acceptance: not performed; required production captures remain Child 05 evidence and independent audit scope.

## Changed files

- `scripts/campaign/user_settings.gd`
- `scripts/campaign/application_shell.gd`
- `scripts/game_manager.gd`
- `tests/m20_settings_probe.gd`
- this Codex child log

## Publication

- Implementation commit: `6e05a8c5451e5e187f3bea557a8a42c81b5c3bd7` (`BCM-M20-003 add independent user settings`).
- Publication log commit: recorded separately after this log update.
- No campaign save schema bump, physics, objective, timer, scoring, reward, VIP, or progression authority change was made.
- Equality was verified after publication with `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`; all matched.

## Limitations / handoff

- This is builder evidence only, not acceptance. Independent ChatGPT audit remains required.
- Child 04 is authorized only after the publication equality proof above.
