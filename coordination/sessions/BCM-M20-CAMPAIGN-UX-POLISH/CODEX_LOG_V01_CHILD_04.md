# CODEX Execution Log — BCM-M20-004

Status: `PUBLISHED_BUILDER_EVIDENCE / AWAITING_CHILD_04_AUDIT`

## Contract and ordered gate

- Work item: `BCM-M20-004` — Pause / App Lifecycle.
- Prompt/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_04.md` and `CHATGPT_AUDIT_CRITERIA_V01_CHILD_04.md`.
- Child 03 publication gate was satisfied before work began: `82fd1e92df32a315d26d793b6cd4e42f85b22ee1` matched local HEAD, `origin/main`, and remote `main`.
- No Child 05 work was started.

## Synchronization preflight

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Branch: `main`.
- Start HEAD: `82fd1e92df32a315d26d793b6cd4e42f85b22ee1`.
- `git status --short --branch`: clean, `main...origin/main`.
- `git fetch origin main`: completed.
- `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
- Child 03 equality proof was rechecked before implementation.

## Implementation

- Added a visible in-game pause button and overlay to the existing gameplay scene.
- Overlay actions are Resume and Island Map. Island Map uses `GameplaySessionBridge.return_to_island_map()`; it does not submit completion or grant rewards.
- Manual pause and resume remain routed through the existing bridge. The bridge remains the sole timer/pause authority.
- Existing application lifecycle notifications continue through `GameplaySessionBridge.set_background_paused()`, preserving manual pause across background/resume and auto-resuming only a background pause.
- Terminal results hide the pause controls and cannot be resumed.
- Router gameplay disposal now detaches the old node before queue-free, preventing retry name collisions and keeping one live gameplay instance.
- Updated the M14 compatibility probe to mount the new shell before accessing its existing navigation host.
- Added `tests/m20_pause_lifecycle_probe.gd` covering visible pause, timer freeze, manual/background distinction, terminal behavior, retry, Island Map exit, progression isolation, and instance counts.
- `TASKS.md` was not modified.

## Builder checks

- `godot_console.exe --headless --path . --script res://tests/m20_pause_lifecycle_probe.gd`: exit 0; `M20_CHILD_04_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd`: exit 0; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- Child 01, Child 02, and Child 03 focused probes were rerun and passed.
- `git diff --check`: passed before commit.
- Manual owner-native visual acceptance: not performed; required production captures remain Child 05 evidence and independent audit scope.

## Changed files

- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/game_manager.gd`
- `tests/m14_gameplay_session_bridge_probe.gd`
- `tests/m20_pause_lifecycle_probe.gd`
- this Codex child log

## Publication

- Implementation commit: `902627a9014108fcaa01232d3fe2f377d95d4faf` (`BCM-M20-004 add pause overlay and lifecycle controls`).
- Publication log commit: recorded separately after this log update.
- No second timer, pause authority, gameplay engine, progression gate, reward path, or M21 work was introduced.
- Equality was verified after publication with `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`; all matched.

## Limitations / handoff

- This is builder evidence only, not acceptance. Independent ChatGPT audit remains required.
- Child 05 is authorized only after the publication equality proof above.
