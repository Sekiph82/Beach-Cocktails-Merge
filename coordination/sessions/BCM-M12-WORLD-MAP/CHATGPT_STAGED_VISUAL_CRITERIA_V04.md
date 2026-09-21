# BCM-M12-WORLD-MAP — Staged Visual Production Criteria V04

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Retry visual production with Codex using a staged workflow instead of attempting all 398 assets in one execution.

The goal is to prove Codex can produce the required final-quality art before scaling to the complete asset library.

## Mandatory visual authority

These two images remain the highest-priority visual authority:

1. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board_remediation_v01.png
2. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board.png

No procedural/Pillow-style final art is allowed.

## Stage 1 only

Generate only these master visuals:

1. Sunny Cove environment master
2. Tiki Island environment master
3. Azure Bay environment master
4. Coconut Beach environment master
5. Sunset Island environment master
6. Party Beach environment master
7. Frozen Paradise environment master
8. Volcano Bay environment master
9. Billionaire Island environment master
10. Final Island environment master
11. World Map master composition
12. Main Menu master composition

These are concept/master images, not yet the complete 398-asset export set.

## Quality gate

Each master must visibly match the authority boards in:
- painterly/cartoon-realistic finish;
- lighting richness;
- material richness;
- tropical/resort premium mood;
- commercial mobile-game polish;
- depth and environmental detail.

Do not use low-quality substitutes.

If Codex cannot generate these 12 master visuals at the required quality, stop and report BLOCKED.

## Output

Store masters under:
assets/ui_assets/v04_masters/

Suggested filenames:
- sunny_cove_master.png
- tiki_island_master.png
- azure_bay_master.png
- coconut_beach_master.png
- sunset_island_master.png
- party_beach_master.png
- frozen_paradise_master.png
- volcano_bay_master.png
- billionaire_island_master.png
- final_island_master.png
- world_map_master.png
- main_menu_master.png

Do not overwrite existing runtime assets yet.

## Evidence

Create:
- assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png
- assets/ui_assets/v04_masters/README.md

The README must describe generation method, dimensions, and how each master maps to future production assets.

## Owner approval gate

Do not continue from these masters into the full 398-asset regeneration in the same run.

After generating the 12 masters, STOP for independent ChatGPT + owner visual approval.

Only after approval will a later prompt authorize Stage 2 asset derivation/export.

## Protected items

Do not modify:
- canonical logo artwork;
- table geometry/masks;
- the two visual-authority boards;
- accepted gameplay/runtime logic;
- existing UI runtime assets outside the new v04_masters folder.

## Log

Write:
coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V04.md
