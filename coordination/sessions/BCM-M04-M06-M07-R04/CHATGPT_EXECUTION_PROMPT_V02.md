# BCM-M04-M06-M07-R04 — Owner Canonical Asset Replacement Master Prompt V02

Status: ISSUED

This V02 supersedes V01 only where source-file identity conflicts. All M06-R04 and M07-R03 implementation requirements from V01 remain authoritative.

## Corrected owner-source authority
The owner explicitly confirms that the following locally discovered files are the intended replacement assets. Use these exact files and hashes. Do NOT use the obsolete upload-derived hashes from V01.

| Local owner source | Dimensions | SHA-256 | Canonical target |
|---|---:|---|---|
| `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\game_board_background 2.png` | 1024x1536 | `bf9ef25bfe27b78805c487410601a9fef16b36f83c97b9bc6f3bf70670dfd17a` | `assets/environment/game_board_background.png` |
| `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_best_score 5.png` | 1671x941 | `94ce6aeac7847834e91273dc6d32cb9bfd4a273ca459ed387c91624905f71157` | `assets/ui/panel_best_score.png` |
| `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_score 2.png` | 1672x941 | `3e20ed0266c65b75fc0724d3d7c239adef113e0f9d4f0a693eb64adc8b7104e2` | `assets/ui/panel_score.png` |
| `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_next 4.png` | 1103x1426 | `36396f70b14c58a543bcfe79f2b7bdf3da4e18f31767acf3d8260b23580da56d` | `assets/ui/panel_next.png` |
| `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_to_go_orders 3.png` | 1132x1389 | `ef9d395a2e2d9cfd0b9a3e998ef5874acec0c9210cbe05633a04934fbddc4400` | `assets/ui/panel_to_go_orders.png` |
| `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\progression_strip 5.png` | 2170x725 | `6354b44cf1d4152c952802fb0f26d03e387b70f37001c75dbb1d886b6eac611c` | `assets/ui/progression_strip.png` |

## Required sequence
1. Read `AGENTS.md`, `coordination/AUDIT_POLICY.md`, `TASKS.md`.
2. Read:
   - `coordination/sessions/BCM-M04-R03/CHATGPT_AUDIT_CRITERIA_V02.md`
   - `coordination/sessions/BCM-M06-R04/CHATGPT_AUDIT_CRITERIA_V01.md`
   - `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_CRITERIA_V01.md`
   - previous master prompt V01 for the full M06-R04 and M07-R03 implementation details.
3. Execute M04-R03 retry first using the corrected owner files above.
4. Write `coordination/sessions/BCM-M04-R03/CODEX_LOG_V02.md`.
5. Commit and push M04-R03 separately.
6. Continue with M06-R04 exactly as specified in V01, remeasuring geometry from the newly replaced background.
7. Write `coordination/sessions/BCM-M06-R04/CODEX_LOG_V01.md`, commit and push separately.
8. Continue with M07-R03 exactly as specified in V01, rebuilding HUD layout around the new Best/Score/NEXT/To-Go/progression artwork.
9. Write `coordination/sessions/BCM-M07-R03/CODEX_LOG_V01.md`, commit and push separately.
10. Run final M01-M07 regression suite on final main and STOP for independent audit.

## Critical M07 rules retained from V01
- Best Score PNG already contains crown + heading; runtime adds only the number.
- Score PNG already contains star + heading; runtime adds only the number.
- NEXT PNG already contains NEXT; runtime adds only the true next cocktail.
- To-Go PNG already contains heading; runtime adds only target cocktail + live name/level + reward.
- progression_strip.png contains the baked 2x6 slot artwork. Remove runtime-generated cell frames and place only cocktail sprites into the baked slots.
- Top row L07-L12, bottom row L01-L06.
- Measure actual baked slot interiors from the new PNG rather than reusing old generic grid constants.
- Preserve aspect ratio; no stretching.
- No guide line.
- Do not start M08+.

## Governance
Codex must not edit TASKS.md or ChatGPT-owned prompt/audit/criteria/policy files. Do not rewrite historical logs. Do not self-audit or assign AUDITED_PASS.

Final response after all three phases: return the three log URLs + commit SHAs, final suite result, `AWAITING_AUDIT`, then STOP.