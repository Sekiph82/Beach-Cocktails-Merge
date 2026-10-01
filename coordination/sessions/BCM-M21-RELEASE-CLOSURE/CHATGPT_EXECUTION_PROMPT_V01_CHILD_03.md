# BCM-M21-003 — Fresh Save L1→L100 Progression

Execute only after Child 02 publication equality.

Build/run a deterministic production-path campaign progression test from a true fresh state through Sunny Cove Levels 1–100.

Use LevelDatabase + CampaignManager + GameplaySessionBridge/runtime completion APIs. Do not directly mark completion records as the main proof.

Requirements:
- complete normal objectives for every level;
- VIP may remain missed;
- save/reload checkpoints after L1/L25/L50/L75/L100;
- verify stars/best/rewards persistence and duplicate safety;
- Tiki locked through L99;
- Tiki unlock after L100;
- Tiki remains zero-level/unplayable after unlock;
- final restart preserves state.

Publish machine-readable + Markdown report and `CODEX_LOG_V01_CHILD_03.md`; prove equality before Child 04.
