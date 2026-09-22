# BEACH COCKTAILS MERGE — CODEX VISUAL ASSET LOG

Append-only execution log for the dedicated visual-production branch.

Do not erase prior factual entries.

For each batch append:
- timestamp;
- task IDs;
- exact output paths;
- generation or protected technical derivation;
- V04 reference(s) used;
- rejected/regenerated attempts;
- QA performed;
- commit SHA;
- remote branch HEAD;
- blockers.

## Initialization

Dedicated visual system created from the owner-approved ScrubBots Codex visual-production workflow and adapted to Beach Cocktails Merge.

V04 masters are the frozen primary visual authority.
V05 production visuals are owner-rejected and are not style authority.

## Batch 001 — global action and frame states

- Timestamp: 2026-09-21 23:10:16 +03:00.
- Tasks: VA-339, VA-340, VA-342, VA-343, VA-344, VA-345, VA-363, VA-364, VA-365, VA-368, VA-376.
- Outputs: `assets/ui_assets/ui/global/button_danger.png`, `button_disabled.png`, `button_locked.png`, `button_primary.png`, `button_secondary.png`, `button_small.png`, `panel_generic_large.png`, `panel_generic_medium.png`, `panel_generic_small.png`, `popup_frame.png`, `tooltip_frame.png`.
- Generation: one separate built-in image-generation operation per distinct asset; no atlas slicing. The V04 `main_menu_master.png` was used as the direct style authority for every operation.
- Technical cleanup: each selected transparent output was resized/padded to its exact master-list dimensions only.
- Rejected/regenerated attempts: none.
- QA: inspected generated button locked and panel variants; verified true RGBA output and exact dimensions (buttons 360x104; panels/frames 440x190). States are materially differentiated: primary emerald, secondary sapphire, disabled pearl/sand, locked sapphire with lock medallion, danger coral, small amber.
- Blockers: none.
- Commit/push: pending batch publication.

## Batch 004 — island-map progression UI

- Timestamp: 2026-09-21 23:10:16 +03:00.
- Tasks: VA-007 through VA-023.
- Outputs: all 17 `assets/ui_assets/campaign/island_map/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct crown, panel, connector, node, decoration, chest marker and star asset; V04 `world_map_master.png` was the direct authority.
- Technical cleanup: transparent padding and exact master-list resizing only.
- Rejected/regenerated attempts: none.
- QA: compared locked/unlocked/current/completed/milestone/finale node states, normal/completed connectors, empty/filled stars and top/bottom decorations; verified RGBA output and exact dimensions.
- Blockers: none.
- Commit/push: pending batch publication.

## Batch 003 — reward and star-track states

- Timestamp: 2026-09-21 23:10:16 +03:00.
- Tasks: VA-377 through VA-398.
- Outputs: all `ui/rewards/**` and `ui/star_track/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct chest, currency, star, frame, glow and star-track asset; V04 `main_menu_master.png` was the direct authority.
- Technical cleanup: transparent padding and exact master-list resizing only.
- Rejected/regenerated attempts: none.
- QA: verified open/closed chest distinction, empty/filled star distinction, large/small frame distinction, claimed/checkpoint/marker/fill/panel distinction, RGBA output and exact dimensions.
- Blockers: none.
- Commit/push: pending batch publication.

## Batch 002 — global navigation and utility icons

- Timestamp: 2026-09-21 23:10:16 +03:00.
- Tasks: VA-338, VA-341, VA-346, VA-347, VA-353, VA-354, VA-355, VA-356, VA-357, VA-361, VA-366, VA-369.
- Outputs: `back_arrow.png`, `button_icon_round.png`, `check_icon.png`, `close_x.png`, `help_icon.png`, `home_icon.png`, `info_icon.png`, `lock_icon.png`, `map_icon.png`, `next_arrow.png`, `pause_icon.png`, `previous_arrow.png` under `assets/ui_assets/ui/global/`.
- Generation: one separate built-in image-generation operation per icon; V04 `main_menu_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: transparent padding and exact master-list resizing only.
- Rejected/regenerated attempts: none.
- QA: verified isolated RGBA outputs and exact dimensions; utility semantics were checked at mobile icon scale, including directional distinction between back/previous and next arrows, and explicit lock/check/pause symbols.
- Blockers: none.
- Commit/push: pending batch publication.

## Batch 005 — Sunny Cove island pack

- Timestamp: 2026-09-22 00:15:46 +03:00.
- Tasks: VA-102 through VA-114.
- Outputs: all 13 `assets/ui_assets/campaign/islands/sunny_cove/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct complete badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `sunny_cove_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; representative gameplay background, table material and map title visually inspected; `gameplay_table.png` alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 017 publication record

- Implementation commit: `579cd4c7fb873347825bac628bbff9d455cb4c06`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `579cd4c7fb873347825bac628bbff9d455cb4c06`.
- Remote canonical paths verified: 19/19 Brand and Effects targets present.
- Worktree remained clean after push.

## Batch 016 publication record

- Implementation commit: `6b35260bbe513275499341418cb53ccfc0bab067`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `6b35260bbe513275499341418cb53ccfc0bab067`.
- Remote canonical paths verified: 22/22 World Map targets present.
- Worktree remained clean after push.

## Batch 017 — Brand derivatives and effects

- Timestamp: 2026-09-22 03:31:00 +03:00.
- Tasks: VA-001 through VA-004, VA-006, and VA-183 through VA-196.
- Brand outputs: five role-specific, non-destructive crop/pad/resize derivatives from the protected canonical owner logo; the owner logo itself was not modified.
- Effects outputs: 14 independently generated, purpose-specific transparent effects using the approved Main Menu V04 master and both approved style boards; each was visually reviewed in a technical contact preview before canonical promotion.
- Technical cleanup: exact master-list resizing and RGBA conversion only; no gameplay or protected source files changed.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 19 outputs; effect roles remain visually distinct in the preview.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 005 publication record

- Implementation commit: `0aefcddbc74543a0f9e72f8c30b74b5453394b90`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `0aefcddbc74543a0f9e72f8c30b74b5453394b90`.
- Worktree remained clean after push.

## Batch 006 — Azure Bay island pack

- Timestamp: 2026-09-22 00:29:22 +03:00.
- Tasks: VA-024 through VA-036.
- Outputs: all 13 `assets/ui_assets/campaign/islands/azure_bay/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct complete badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `azure_bay_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; representative Azure Bay gameplay background, table material and map title visually inspected; `gameplay_table.png` alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 006 publication record

- Implementation commit: `7645f0741bd18e1c4eba3bcce98ccb7a94585c00`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `7645f0741bd18e1c4eba3bcce98ccb7a94585c00`.
- Worktree remained clean after push.

## Batch 007 — Billionaire Island island pack

- Timestamp: 2026-09-22 00:42:15 +03:00.
- Tasks: VA-037 through VA-049.
- Outputs: all 13 `assets/ui_assets/campaign/islands/billionaire_island/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct complete badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `billionaire_island_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; representative Billionaire Island gameplay background, table material and world icon visually inspected; `gameplay_table.png` alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 007 publication record

- Implementation commit: `949db59473f992f4ad314c706a7ccd05969bfda4`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `949db59473f992f4ad314c706a7ccd05969bfda4`.
- Worktree remained clean after push.

## Batch 008 — Coconut Beach island pack

- Timestamp: 2026-09-22 00:54:15 +03:00.
- Tasks: VA-050 through VA-062.
- Outputs: all 13 `assets/ui_assets/campaign/islands/coconut_beach/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct complete badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `coconut_beach_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; representative target dimensions and frozen-table geometry verified; `gameplay_table.png` alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 008 publication record

- Implementation commit: `f9597e9e9a9de45bc97bea44d3907c64ffdeee46`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `f9597e9e9a9de45bc97bea44d3907c64ffdeee46`.
- Worktree remained clean after push.

## Batch 009 — Final Island generation blocked

- Timestamp: 2026-09-22 01:03:29 +03:00.
- Attempted tasks: VA-063 through VA-075.
- Result: blocked by the image-generation service returning HTTP 429 `usage_limit_reached` before a complete per-asset result set was returned. Some unlabelled raw outputs were left in the generator-managed output directory, but none were promoted to canonical repository paths because their asset-role mapping could not be safely established.
- Style authority: V04 `final_island_master.png` only; no V05 art or atlas slicing used.
- Repository impact: no Final Island canonical assets or task checkboxes were changed.
- Blocker: service response reported a reset in approximately two hours; continuing requires the generator limit to reset or explicit user-authorized reset-credit consumption.

## Batch 010 — Final Island island pack resumed

- Timestamp: 2026-09-22 01:34:48 +03:00.
- Tasks: VA-063 through VA-075.
- Outputs: all 13 `assets/ui_assets/campaign/islands/final_island/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct completion badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `final_island_master.png` was the direct authority. No ambiguous Batch 009 output was promoted; no V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none in the resumed batch.
- QA: exact dimensions and RGBA verified for all 13 outputs; representative completion badge, gameplay background, table material, map title and world icon visually inspected; `gameplay_table.png` alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 010 publication record

- Implementation commit: `f54391fb84c6057d60f5232f83a8507085df494e`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `f54391fb84c6057d60f5232f83a8507085df494e`.
- Worktree remained clean after push.

## Batch 011 — Frozen Paradise island pack

- Timestamp: 2026-09-22 01:50:46 +03:00.
- Tasks: VA-076 through VA-088.
- Outputs: all 13 `assets/ui_assets/campaign/islands/frozen_paradise/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct completion badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `frozen_paradise_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; gameplay-table alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 011 publication record

- Implementation commit: `b6a2574034e78c7fe5a110b09504d64b3b2f3850`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `b6a2574034e78c7fe5a110b09504d64b3b2f3850`.
- Remote canonical paths verified: 13/13 Frozen Paradise targets present.
- Worktree remained clean after push.

## Batch 012 — Party Beach island pack

- Timestamp: 2026-09-22 02:05:31 +03:00.
- Tasks: VA-089 through VA-101.
- Outputs: all 13 `assets/ui_assets/campaign/islands/party_beach/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct completion badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `party_beach_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; gameplay-table alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 012 publication record

- Implementation commit: `2b8bce47fd9d452624205ff3f1f4c9bc1a8655fc`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `2b8bce47fd9d452624205ff3f1f4c9bc1a8655fc`.
- Remote canonical paths verified: 13/13 Party Beach targets present.
- Worktree remained clean after push.

## Batch 013 — Sunset Island island pack

- Timestamp: 2026-09-22 02:19:38 +03:00.
- Tasks: VA-115 through VA-127.
- Outputs: all 13 `assets/ui_assets/campaign/islands/sunset_island/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct completion badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `sunset_island_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; gameplay-table alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 013 publication record

- Implementation commit: `fd2304dc6b104001e82794f24814438f7f90665c`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `fd2304dc6b104001e82794f24814438f7f90665c`.
- Remote canonical paths verified: 13/13 Sunset Island targets present.
- Worktree remained clean after push.

## Batch 014 — Tiki Island island pack

- Timestamp: 2026-09-22 02:34:03 +03:00.
- Tasks: VA-128 through VA-140.
- Outputs: all 13 `assets/ui_assets/campaign/islands/tiki_island/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct completion badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `tiki_island_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; gameplay-table alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 014 publication record

- Implementation commit: `49bd3e58fcc935610dcb99bda2ba9b4e277e752d`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `49bd3e58fcc935610dcb99bda2ba9b4e277e752d`.
- Remote canonical paths verified: 13/13 Tiki Island targets present.
- Worktree remained clean after push.

## Batch 015 — Volcano Bay island pack

- Timestamp: 2026-09-22 02:48:52 +03:00.
- Tasks: VA-141 through VA-153.
- Outputs: all 13 `assets/ui_assets/campaign/islands/volcano_bay/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct completion badge, decorative element, gameplay background, table material, table shadow, launch zone, map background, map title, table-edge overlay, theme badge and world icon; V04 `volcano_bay_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing, transparent compositing and frozen table-mask application only. `gameplay_table.png` uses the canonical `table_silhouette_mask.png` alpha without changing the protected geometry.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 13 outputs; gameplay-table alpha compared against the canonical mask with zero differing pixels.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 015 publication record

- Implementation commit: `f70c7a419eaeb3ecb8332aa0887731eaeea7467c`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `f70c7a419eaeb3ecb8332aa0887731eaeea7467c`.
- Remote canonical paths verified: 13/13 Volcano Bay targets present.
- Worktree remained clean after push.

## Batch 016 — World Map family

- Timestamp: 2026-09-22 03:14:30 +03:00.
- Tasks: VA-154 through VA-175.
- Outputs: all 22 `assets/ui_assets/campaign/world_map/**` targets in the master list.
- Generation: one separate built-in image-generation operation per distinct island icon, lock/name treatment, route element, cloud layer, map background, boat, compass and title panel; V04 `world_map_master.png` was the direct authority. No V05 art or atlas slicing used.
- Technical cleanup: exact master-list resizing and RGBA conversion only; no protected asset or frozen geometry was modified.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 22 outputs.
- Blockers: none.
- Commit/push: published in commit recorded below.
