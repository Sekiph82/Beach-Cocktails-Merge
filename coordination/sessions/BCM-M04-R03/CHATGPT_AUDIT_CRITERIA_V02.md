# BCM-M04-R03 — Locked Audit Criteria V02

Status: LOCKED BEFORE REMEDIATION RETRY

This V02 supersedes V01 only for owner-source identity. All other M04-R03 acceptance requirements from V01 remain in force.

## Owner-authoritative source files
The owner explicitly confirmed that the locally discovered files below are the intended replacement assets. These exact local bytes are now authoritative, regardless of earlier ChatGPT-upload-derived hashes.

- `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\game_board_background 2.png`
  - 1024x1536
  - SHA-256 `bf9ef25bfe27b78805c487410601a9fef16b36f83c97b9bc6f3bf70670dfd17a`
  - target `assets/environment/game_board_background.png`
- `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_best_score 5.png`
  - 1671x941
  - SHA-256 `94ce6aeac7847834e91273dc6d32cb9bfd4a273ca459ed387c91624905f71157`
  - target `assets/ui/panel_best_score.png`
- `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_score 2.png`
  - 1672x941
  - SHA-256 `3e20ed0266c65b75fc0724d3d7c239adef113e0f9d4f0a693eb64adc8b7104e2`
  - target `assets/ui/panel_score.png`
- `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_next 4.png`
  - 1103x1426
  - SHA-256 `36396f70b14c58a543bcfe79f2b7bdf3da4e18f31767acf3d8260b23580da56d`
  - target `assets/ui/panel_next.png`
- `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\panel_to_go_orders 3.png`
  - 1132x1389
  - SHA-256 `ef9d395a2e2d9cfd0b9a3e998ef5874acec0c9210cbe05633a04934fbddc4400`
  - target `assets/ui/panel_to_go_orders.png`
- `C:\Users\sekip\Desktop\beach cocktails resim degisimleri\progression_strip 5.png`
  - 2170x725
  - SHA-256 `6354b44cf1d4152c952802fb0f26d03e387b70f37001c75dbb1d886b6eac611c`
  - target `assets/ui/progression_strip.png`

## PASS requirements
1. Each canonical target must exactly match the authoritative local source SHA above after copy.
2. No resizing, recompression, re-encoding, cropping, recoloring or other image mutation is allowed.
3. M04 asset validation and evidence must be regenerated from the replaced canonical files.
4. The repository asset inventory must remain truthful and complete.
5. All unrelated canonical PNGs must remain unchanged.
6. `guide_line` remains absent.
7. TASKS and ChatGPT-owned files must remain untouched by Codex.
8. Codex must produce `coordination/sessions/BCM-M04-R03/CODEX_LOG_V02.md` with source/target hashes, dimensions, commands, exits and changed files.
9. M04-R03 may not be marked AUDITED_PASS by Codex.

The previous V01 blocker caused by mismatched upload-derived hashes is superseded by this owner-confirmed V02 source identity.