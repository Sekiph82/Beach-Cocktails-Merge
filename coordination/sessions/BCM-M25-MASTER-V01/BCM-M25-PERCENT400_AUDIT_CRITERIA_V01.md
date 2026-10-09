# Locked M25 PERCENT400 audit criteria

All 100 Sunny Cove levels from canonical campaign JSON must get derived finite theoretical shots T = sum(quantity * 2^(cocktail_level-3)) for mandatory To-Go orders. Audit all 100 inputs; no magic fixed cap, no unbounded entries. Note optional VIP theoretical targets separately without extending the To-Go max budget. move_limit = 4*T.

Stars for a natural WIN: if actual committed moves < 2*T -> 3; if 2*T <= moves < 3*T -> 2; if 3*T <= moves <= 4*T -> 1. Otherwise 0 for LOSE. This includes exact integer boundaries T=12: 23 ->3, 24 ->2, 35 ->2, 36 ->1, 48 final-shot WIN ->1, 48 incomplete -> LOSE. Handle optional VIP independently without prior VIP third-star gate, as superseded by owner formula. No score input to stars.

Count each successful launch once, correctly block extra shots, wait for physics and merge/order delivery to settle, idempotent terminal resolution, final-shot WIN takes priority; natural LOSE reason MOVES_EXHAUSTED. Retry/replay/reset and best-star progression behave properly. Never change physics, order targets, random spawn distributions, timer, economy reward authority or visual effects.

Migrate tests dependent on old score-star/VIP rule. Unit and 100-level property tests for every level and each 199%/200%/299%/300%/400% boundary, including integer edge cases, FULL/REDUCED and optional VIP, plus natural real GL WIN/LOSE/Retry in production. M02/M09/M15/M21/M22/M23/M24/M25 regressions and mobile QA twice with exit 0. Canonical 720x1280 and tall 720x1440 HUD, import/boot. Isolated APPDATA and evidence before first run, preserve all owner-local files/saves by hashes. Do not modify TASKS.md as Codex. Log each child and master; stop before M26.
