# BCM-M34-R20 | Autonomous Bot Improvement and Integrity Repair

Read AGENTS.md, root TASKS.md, R19 builder log and independent audit. Root TASKS.md is edited only by ChatGPT.

Priority A: repair the unmatched TRIAL_START / missing TRIAL_FINISHED postprocessing failure in R19 retry evidence. Make recovery repeatable, append-only, and idempotent. Test abrupt subprocess exits and resumptions without overwriting evidence or falsely claiming completion.

Priority B: determine why eight of eleven budget-unknown cases showed zero objective progress. Instrument per-shot launch input coordinates, collision events, merge chain, progress delta and objective feasibility; compare only actual production scene, geometry, ShotController and physics against the debug test harness. Never treat static feasibility or bot timeouts as impossibility.

Priority C: build and measure an objective-aware alternative to the existing feedback bot using a bounded candidate-lane/lookahead strategy and real production simulation. Do not assume bit-for-bit deterministic Godot physics or use fixed-FPS to assert wins. Start with one nontrivial early/mid-level challenge and strict 4T shot cap. Require a legitimately observed win beyond Sunny Cove L1 before expanding batch size. If no win, report objective bottlenecks and credible options rather than running blind bulk tests.

Maintain all owner rulings: WIN consumes 0 energy; LOSE/QUIT consume 20 once per attempt; no timer; optional VIP; four-T star rules; no Focus. Never ask the owner to play 1000 levels. Studio is an optional debug tool, not a manual qualification requirement. No device tests.

Preserve 8 modified tracked Desktop owner files and all current untracked owner files as verified by a fresh preflight, without assuming the old number remains 15 or 6. Safe Git sync only; no resets, git clean, force pushes, or destruction of stashes. No extra persistent worktrees, GB-scale disposable caches or unnecessary AppData. Do not retry the previously deferred 44,266-byte cleanup. If policy blocks deletion, report and continue work without circumvention.

Fresh Godot import, relevant focused probes, and ten standard regression groups. Provide a concise evidence ledger with honest WIN_OBSERVED, LOSS_OBSERVED, BUDGET_UNKNOWN, ERROR, and manifest integrity results. Publish code, tests and builder log to GitHub main normally; never modify TASKS.md. Stop for independent GPT audit.
