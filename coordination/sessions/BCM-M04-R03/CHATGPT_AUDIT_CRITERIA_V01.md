# BCM-M04-R03 — Locked Audit Criteria V01

Status: LOCKED BEFORE IMPLEMENTATION

## Scope
Owner-directed replacement of six canonical visual assets. Later owner-provided files override older versions and any conflicting earlier visual interpretation.

## Exact owner source files
The implementation must use these exact source files, identified by filename, dimensions and SHA-256:

| Owner file | Dimensions | SHA-256 | Canonical target |
|---|---:|---|---|
| `game_board_background 2.png` | 1024x1536 | `5d3d795935e2a69175e048c354ab4ce82ef13627cd27a8894f0605f78f0559b3` | `assets/environment/game_board_background.png` |
| `panel_best_score 5(1).png` | 1671x941 | `62a237642c2007d538c12653e7fa60c7e4208291b35d4070df7f55e87d12c988` | `assets/ui/panel_best_score.png` |
| `panel_score 2(2).png` | 1672x941 | `8b540fbad12d1d4c76ff4af935ee48d39cee5c33d2a25dd0e1a077b3e67a56ec` | `assets/ui/panel_score.png` |
| `panel_next 4(2).png` | 1103x1426 | `46527d3e6161d72e0960473c313f845efe6140222ba00c752200b8c5c1802996` | `assets/ui/panel_next.png` |
| `panel_to_go_orders 3(1).png` | 1132x1389 | `4871dee116d04a906c8b467e82c511895c427ef8c6cbca8566ef91d6169f8828` | `assets/ui/panel_to_go_orders.png` |
| `progression_strip 5(2).png` | 2048x684 | `fff4228423e5381ee3972231d71aa3d5c948c57c5a38f29030d64789d9d49873` | `assets/ui/progression_strip.png` |

## PASS requirements
1. All six canonical targets exist and their bytes hash exactly to the owner SHA-256 values above.
2. No substitute, generated approximation, screenshot, recompressed derivative, resize or re-export is accepted.
3. All six targets decode successfully in Python/Pillow and Godot.
4. Alpha/transparency contracts are preserved where present.
5. The total canonical asset inventory remains truthful and M04 validator/manifest reflects the new hashes and dimensions.
6. Existing cocktail assets and effects are not modified by this replacement.
7. `guide_line` remains absent.
8. M04 evidence/contact sheets are regenerated from the new canonical files.
9. The old owner master may remain as a historical composition reference, but it must not override these six newer owner files.
10. `TASKS.md` is not edited by Codex.
11. ChatGPT-owned prompt/criteria/audit/policy files are not edited by Codex.
12. Godot import/startup and `git diff --check` pass.
13. Source discovery is safe: if an exact owner file cannot be located by SHA-256, the task must STOP with a blocker rather than substitute another image.

Any material failure blocks AUDITED_PASS.