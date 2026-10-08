# BCM-M23-R03 — Balanced Effects & Exact Color Restoration (Codex)

Repository Sekiph82/Beach-Cocktails-Merge
Local C:\Users\sekip\Desktop\Beach Cocktails - Merge

FIRST: safe non-destructive git sync with origin/main. Preserve owner-local project.godot and two untracked PNGs, inventory other local evidence/stashes, fast-forward only when safe. No hard reset, clean, destructive stash, rebase or force push. Read AGENTS.md, root TASKS.md (Codex READ ONLY), owner M23 visual reviews, latest M23 R02 code/log/report and R03 locked criteria.

Owner acceptance ruling: R01/initial M23 effects too faint, R02 effects too strong; **aim for between**, with visible but restrained particles and distinct combo tier escalation. Some color changes sometimes never revert: **critical correctness defect**. Do NOT start M24.

Inspect exactly why GFF color tint sometimes sticks. Trace GFFColorTarget.apply_params and GFFEffect tween lifecycle; record each target's original modulate, effect start/end, overlapping effects, cancellation/teardown and final modulate. Ensure exact initial per-target color restored on natural completion, interruption, replacement, plugin failure and scene exit, including rapid mixed score/contact/merge. Avoid forcing default Color.WHITE or touching physics root. If addon modification needed, add isolated tests and keep public API compatible.

Perform controlled FULL effect profiles: report previous pre-R02 values vs R02 and new values for size, palette, GFF punch/color intensity, speed and duration. Prefer reducing current oversaturated cyan, overly large 5–8px particle sizes and powerful tint/punch; do not regress all the way to imperceptible 3px baseline. Differentiate BASE/SURGE/PEAK within M22 limits (do not exceed caps). REDUCED merge MUST stay particle-free.

Real-renderer evidence: event and settled frames at several points, explicitly after effects completed, original tint value equal to final; genuine 800x1422 window, native gameplay 720x1280, FULL and REDUCED. Use screenshot/video before/after for score, contact, launch, BASE/SURGE/PEAK. No fabricated evidence or captures=0 PASS. Owner F5 still needed.

Run locked R03 audit criteria and earlier M23/M22/M02/M09/M15/M21 regression, editor parse/boot, teardown, plugin absent/failing and score/physics/save parity; report M21 720x1440 World Map mobile QA failure separately, investigate root cause without unapproved M21 geometry changes. Produce docs/codex-logs/CODEX_LOG_M23_R03.md and evidence/M23-R03. Push all eligible files and logs, verify local HEAD/origin/live main equal with 0/0. Preserve owner-local files. Codex must not modify TASKS.md.

STOP AWAITING_GPT_M23_R03_REAUDIT. Owner visual acceptance remains separate.
