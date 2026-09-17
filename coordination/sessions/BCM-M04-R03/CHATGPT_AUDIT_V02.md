# BCM-M04-R03 — Independent ChatGPT Audit V02

## Verdict
**FAIL / CHANGES_REQUIRED**

## Basis
The owner explicitly supplied six replacement PNGs in the current chat. Their actual attachment bytes are authoritative for this audit. The M04-R03 V02 implementation instead used different local files discovered on Desktop after ChatGPT incorrectly superseded the original upload-derived hashes.

### Owner attachment truth
- game_board_background 2.png — 1024x1536 — SHA-256 `5d3d795935e2a69175e048c354ab4ce82ef13627cd27a8894f0605f78f0559b3`
- panel_best_score 5(1).png — 1671x941 — SHA-256 `62a237642c2007d538c12653e7fa60c7e4208291b35d4070df7f55e87d12c988`
- panel_score 2(2).png — 1672x941 — SHA-256 `8b540fbad12d1d4c76ff4af935ee48d39cee5c33d2a25dd0e1a077b3e67a56ec`
- panel_next 4(2).png — 1103x1426 — SHA-256 `46527d3e6161d72e0960473c313f845efe6140222ba00c752200b8c5c1802996`
- panel_to_go_orders 3(1).png — 1132x1389 — SHA-256 `4871dee116d04a906c8b467e82c511895c427ef8c6cbca8566ef91d6169f8828`
- progression_strip 5(2).png — 2048x684 — SHA-256 `fff4228423e5381ee3972231d71aa3d5c948c57c5a38f29030d64789d9d49873`

### Implemented bytes in Codex log
The log records different hashes for all six files, including progression `2170x725` SHA `6354b44c...` instead of the owner attachment `2048x684` SHA `fff42284...`.

## Findings
1. **BLOCKER — wrong owner source bytes were canonicalized.** The six canonical targets do not correspond to the owner's actual attached replacement files.
2. The Python/Godot asset validators passing only proves consistency with the wrong selected files; it cannot satisfy owner-source identity.
3. M04 evidence regenerated from those files is therefore not acceptance evidence for the requested asset refresh.
4. Governance behavior was otherwise safe: Codex did not mutate unrelated cocktail/effect PNGs, TASKS, or ChatGPT-owned files.

## Required remediation
Restore the exact six owner attachment bytes above as canonical targets, regenerate M04 evidence/manifest, then rebuild M06 and M07 against those exact canonical files. No visually similar substitute is acceptable.
