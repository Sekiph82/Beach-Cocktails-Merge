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

## Batch 019 publication record

- Implementation commit: `faa6bddfd60ef9629bfc1a7cbd6e042207400110`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `faa6bddfd60ef9629bfc1a7cbd6e042207400110`.
- Remote canonical paths verified: 12/12 Main Menu targets present.
- Worktree remained clean after push.

## Batch 020 — Blocked Milestones/Pause generation

- Timestamp: 2026-09-22 04:00:00 +03:00.
- Attempted tasks: VA-218 through VA-234 (Milestones and Pause families).
- Blocker: the shared image-generation service returned HTTP 429 `usage_limit_reached` during the batch. No reset credit was consumed, no partial/ambiguous candidates were promoted, and all affected tasks remain unchecked.
- Protected reconciliation: VA-319, VA-320 and VA-322 were verified unchanged and marked PRESERVE in the dedicated tracker; no protected source was regenerated.
- Blocker state: remaining generation cannot continue until the service limit resets or the user explicitly authorizes a different action.

## Batch 018 publication record

- Implementation commit: `73bdfa755e85c76d1388db20376660682f99a6d3`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `73bdfa755e85c76d1388db20376660682f99a6d3`.
- Remote canonical paths verified: 9/9 Daily Reward targets present.
- Worktree remained clean after push.

## Batch 019 — Main Menu screen family

- Timestamp: 2026-09-22 03:49:31 +03:00.
- Tasks: VA-206 through VA-217.
- Outputs: all 12 `assets/ui_assets/screens/main_menu/**` targets in the master list.
- Generation: one separate purpose-specific image-generation operation per counter panel, portrait background, button, decoration, logo frame and profile frame using the approved Main Menu V04/style authorities.
- Technical cleanup: exact master-list resizing and RGBA conversion only; no protected logo or runtime code changed.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all 12 outputs.
- Blockers: none.
- Commit/push: published in commit recorded below.

## Batch 017 publication record

- Implementation commit: `579cd4c7fb873347825bac628bbff9d455cb4c06`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `579cd4c7fb873347825bac628bbff9d455cb4c06`.
- Remote canonical paths verified: 19/19 Brand and Effects targets present.
- Worktree remained clean after push.

## Batch 018 — Daily Reward screen family

- Timestamp: 2026-09-22 03:40:06 +03:00.
- Tasks: VA-197 through VA-205.
- Outputs: all nine `assets/ui_assets/screens/daily_reward/**` targets in the master list.
- Generation: one separate purpose-specific image-generation operation per daily reward button, chest, state tile, slot, portrait background, panel and streak badge using the approved Main Menu V04/style authorities.
- Technical cleanup: exact master-list resizing and RGBA conversion only; no runtime code or protected assets changed.
- Rejected/regenerated attempts: none.
- QA: exact dimensions and RGBA verified for all nine outputs.
- Blockers: none.
- Commit/push: published in commit recorded below.

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

## Batch 021 — Milestones screen family

- Timestamp: 2026-09-22 07:49:57 +03:00.
- Tasks: VA-218 through VA-228.
- Outputs: `assets/ui_assets/screens/milestones/button_claim.png`, `button_continue.png`, `island_complete_panel.png`, `island_complete_ribbon.png`, `milestone_banner.png`, `milestone_chest_closed.png`, `milestone_chest_open.png`, `milestone_glow.png`, `milestone_reward_panel.png`, `next_island_unlock_frame.png`, and `reward_slot.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; no text, logo or runtime copy baked into the UI frames.
- Rejected/regenerated attempts: one extra unpromoted draft was generated while confirming the built-in output-path contract; it was not used for any canonical target. No promoted candidate required regeneration.
- QA: every output visually inspected; claim/continue buttons are materially distinct; closed/open chest states are materially distinct; all 11 outputs are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: published in commit `f83bc247a9c1151b1373efaaa630936b59e660a5`.

## Batch 021 publication record

- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `f83bc247a9c1151b1373efaaa630936b59e660a5`.
- Remote canonical paths verified: 11/11 Milestones targets present.
- Worktree was clean before this publication-record append.

## Batch 022 — Pause screen family

- Timestamp: 2026-09-22 08:06:40 +03:00.
- Tasks: VA-229 through VA-234.
- Outputs: `assets/ui_assets/screens/pause/button_quit.png`, `button_restart.png`, `button_resume.png`, `button_settings.png`, `button_world_map.png`, and `pause_panel.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime labels and copy remain unbaked.
- Rejected/regenerated attempts: the first VA-229 candidate was rejected because it produced a decorative landscape plaque instead of a compact quit button; one targeted regeneration was promoted. No other promoted candidate required regeneration.
- QA: all six outputs visually inspected after normalization; quit/resume/settings/world-map buttons are distinct role surfaces, restart is a clear circular-arrow icon, and the pause panel has a clean runtime copy area. All six are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: published in commit `01918704e42da3d2de76dd298e62a49d78006d9d`.

## Batch 022 publication record

- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `01918704e42da3d2de76dd298e62a49d78006d9d`.
- Remote canonical paths verified: 6/6 Pause targets present.
- Worktree was clean before this publication-record append.

## Batch 023 — Pre-level screen family

- Timestamp: 2026-09-22 08:23:47 +03:00.
- Tasks: VA-235 through VA-244.
- Outputs: `assets/ui_assets/screens/prelevel/booster_selector_panel.png`, `button_close_prelevel.png`, `button_play_level.png`, `level_number_badge.png`, `order_slot.png`, `prelevel_panel.png`, `timer_icon.png`, `timer_panel_small.png`, `vip_badge.png`, and `vip_reward_slot.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime labels, level numbers, timer values and reward copy remain unbaked.
- Rejected/regenerated attempts: the first VA-236 candidate was rejected because it produced a circular medallion instead of a compact close button; one targeted regeneration was promoted. No other promoted candidate required regeneration.
- QA: all ten outputs visually inspected after normalization; selector spaces, level badge, timer icon/panel, normal order slot, VIP badge and distinct VIP reward slot semantics are preserved. All ten are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 031 publication record

- Implementation commit: `1ded733d589da61945bbb6eeb2356a6a313ce9ce`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `1ded733d589da61945bbb6eeb2356a6a313ce9ce`.
- Remote canonical paths verified: 9/9 Tutorial targets present.
- Worktree was clean before this publication-record append.

## Batch 032 — Table edge overlay

- Timestamp: 2026-09-22 13:24:52 +03:00.
- Tasks: VA-321 only.
- Output: `assets/ui_assets/tables/table_edge_overlay_master.png`.
- Generation: one separate built-in image-generation operation for this distinct non-protected production target; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. VA-322 protected silhouette mask was not used as a generated source or modified.
- Technical cleanup: transparent RGBA conversion and exact 720x1280 canvas normalization only.
- Geometry QA: transparent playable interior preserved; rear edge, perspective side rails and front edge visually follow the frozen table geometry contract around rear points `(130,398)` and `(590,398)` and front corners `(0,1280)` and `(720,1280)`.
- Rejected/regenerated attempts: none.
- QA: exact-size RGBA PNG with alpha extrema `(0, 255)`; protected VA-322 remains unchanged.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 030 publication record

- Implementation commit: `e0eefcfa745ed0b127e163537dd0dc6bdf82fd20`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `e0eefcfa745ed0b127e163537dd0dc6bdf82fd20`.
- Remote canonical paths verified: 6/6 Splash targets present.
- Worktree was clean before this publication-record append.

## Batch 031 — Tutorial screen family

- Timestamp: 2026-09-22 13:21:37 +03:00.
- Tasks: VA-310 through VA-318.
- Outputs: `assets/ui_assets/screens/tutorial/tutorial_arrow.png`, `tutorial_hand.png`, `tutorial_highlight_ring.png`, `tutorial_merge_icon.png`, `tutorial_order_icon.png`, `tutorial_panel.png`, `tutorial_skip_button.png`, `tutorial_timer_icon.png`, and `tutorial_vip_badge.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime tutorial copy, levels and order/timer values remain unbaked.
- Rejected/regenerated attempts: none.
- QA: all nine outputs visually inspected after normalization; arrow/hand/ring, merge/order cues, panel, skip, timer and VIP semantics are materially distinct. All nine are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 029 publication record

- Implementation commit: `73d426fd30e3ebaa617f7ca7bcd2c7004a94a295`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `73d426fd30e3ebaa617f7ca7bcd2c7004a94a295`.
- Remote canonical paths verified: 7/7 Social targets present.
- Worktree was clean before this publication-record append.

## Batch 030 — Splash screen family

- Timestamp: 2026-09-22 13:10:19 +03:00.
- Tasks: VA-304 through VA-309.
- Outputs: `assets/ui_assets/screens/splash/loading_bar_fill.png`, `loading_bar_frame.png`, `loading_cocktail_icon.png`, `loading_spinner.png`, `loading_tip_panel.png`, and `splash_background.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime logo, progress values and tip copy remain unbaked.
- Rejected/regenerated attempts: none.
- QA: all six outputs visually inspected after normalization; fill/frame, cocktail, spinner, tip panel and transparent-center beach-bar splash backdrop are materially distinct. All six are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 026 publication record

- Implementation commit: `f38cf9ce509916f8fd65d1f7da0be27c889d69be`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `f38cf9ce509916f8fd65d1f7da0be27c889d69be`.
- Remote canonical paths verified: 13/13 Settings targets present.
- Worktree was clean before this publication-record append.

## Batch 027 — Shop partial batch and usage-limit blocker

- Timestamp: 2026-09-22 09:10:54 +03:00.
- Tasks completed: VA-280 through VA-283 only: `assets/ui_assets/screens/shop/best_value_badge.png`, `button_buy.png`, `coin_pack_icon_large.png`, and `coin_pack_icon_medium.png`.
- Generation: one separate built-in image-generation operation completed for each of the four promoted assets; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime shop labels, prices and quantities remain unbaked.
- QA: all four completed outputs visually inspected after normalization and verified as exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blocker: the next generation request, for VA-284, returned HTTP 429 `usage_limit_reached` with no usable output. No reset credit was consumed. VA-284 through VA-296 remain unchecked; no ambiguous or partial candidate was promoted.
- Commit/push: pending publication and remote verification.

## Batch 027 publication record

- Implementation commit: `7f7ad82503a154f27eb5d454a1dfd2050fae15b7`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `7f7ad82503a154f27eb5d454a1dfd2050fae15b7`.
- Remote canonical paths verified: 4/4 promoted Shop targets present.
- Usage-limit blocker preserved: VA-284 through VA-296 remain unchecked; no reset credit was consumed.
- Worktree was clean before this publication-record append.

## Batch 028 — Shop completion after usage-limit resume

- Timestamp: 2026-09-22 12:49:14 +03:00.
- Tasks: VA-284 through VA-296, completing the Shop family after the Batch 027 usage-limit interruption.
- Outputs: `assets/ui_assets/screens/shop/coin_pack_icon_small.png`, `gem_pack_icon_large.png`, `gem_pack_icon_medium.png`, `gem_pack_icon_small.png`, `sale_badge.png`, `shop_background.png`, `shop_header.png`, `shop_item_card.png`, `shop_item_card_featured.png`, `shop_tab_boosters.png`, `shop_tab_currency.png`, `shop_tab_special.png`, and `starter_pack_badge.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime shop labels, prices, quantities and tabs remain unbaked.
- Rejected/regenerated attempts: none after the usage-limit resume.
- QA: all 13 resumed outputs visually inspected after normalization; gem/coin scale variants, standard/featured cards, sale/starter badges, shop backdrop/header and three tabs are materially distinct. All 13 resumed outputs plus the four previously published Shop outputs are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none after resume.
- Commit/push: pending publication and remote verification.

## Batch 028 publication record

- Implementation commit: `3e466a50b9adcb3aa460d92b1dd1c8ec00e73e25`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `3e466a50b9adcb3aa460d92b1dd1c8ec00e73e25`.
- Remote canonical paths verified: 17/17 Shop targets present.
- Worktree was clean before this publication-record append.

## Batch 029 — Social screen family

- Timestamp: 2026-09-22 13:02:57 +03:00.
- Tasks: VA-297 through VA-303.
- Outputs: `assets/ui_assets/screens/social/friend_icon.png`, `leaderboard_panel.png`, `player_avatar_frame.png`, `rank_badge_1.png`, `rank_badge_2.png`, `rank_badge_3.png`, and `share_icon.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime names, scores, rank numerals and share copy remain unbaked.
- Rejected/regenerated attempts: none.
- QA: all seven outputs visually inspected after normalization; friend, leaderboard, avatar, first/second/third rank and share semantics are materially distinct. All seven are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 025 publication record

- Implementation commit: `8e6fc54cf6b4111a89e640fcdd8f4ddc71e05713`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `8e6fc54cf6b4111a89e640fcdd8f4ddc71e05713`.
- Remote canonical paths verified: 6/6 Rewarded Ad targets present.
- Worktree was clean before this publication-record append.

## Batch 026 — Settings screen family

- Timestamp: 2026-09-22 09:04:25 +03:00.
- Tasks: VA-267 through VA-279.
- Outputs: `assets/ui_assets/screens/settings/accessibility_icon.png`, `button_close_settings.png`, `haptic_icon.png`, `language_icon.png`, `music_icon.png`, `privacy_icon.png`, `restore_purchase_icon.png`, `settings_panel.png`, `slider_handle.png`, `slider_track.png`, `sound_icon.png`, `toggle_off.png`, and `toggle_on.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime setting labels and values remain unbaked.
- Rejected/regenerated attempts: none.
- QA: all 13 outputs visually inspected after normalization; accessibility, haptic, language, music, privacy, restore, sound, panel, close-button, slider and explicit toggle-state semantics are materially distinct. All 13 are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 024 publication record

- Implementation commit: `c0bdcd41afa09aeff20293a11bebca9c90b4539a`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `c0bdcd41afa09aeff20293a11bebca9c90b4539a`.
- Remote canonical paths verified: 16/16 Results targets present.
- Worktree was clean before this publication-record append.

## Batch 025 — Rewarded Ad screen family

- Timestamp: 2026-09-22 08:48:56 +03:00.
- Tasks: VA-261 through VA-266.
- Outputs: `assets/ui_assets/screens/rewarded_ad/button_no_thanks.png`, `button_watch_ad.png`, `reward_ad_double_icon.png`, `reward_ad_time_icon.png`, `rewarded_ad_panel.png`, and `video_ad_icon.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime labels, quantities, multipliers and ad copy remain unbaked.
- Rejected/regenerated attempts: none.
- QA: all six outputs visually inspected after normalization; no-thanks/watch-ad roles, double/time reward semantics, dialog copy area and video-ad icon are materially distinct. All six are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.

## Batch 023 publication record

- Implementation commit: `1f98046da5042513c632f9b837d18a73ee57d9df`.
- Remote branch: `codex/visual-assets-production`.
- Remote verification: local HEAD, `origin/codex/visual-assets-production`, and `git ls-remote` all resolved to `1f98046da5042513c632f9b837d18a73ee57d9df`.
- Remote canonical paths verified: 10/10 Pre-level targets present.
- Worktree was clean before this publication-record append.

## Batch 024 — Results screen family

- Timestamp: 2026-09-22 08:40:36 +03:00.
- Tasks: VA-245 through VA-260.
- Outputs: `assets/ui_assets/screens/results/button_add_time.png`, `button_island_map.png`, `button_next_level.png`, `button_replay.png`, `button_retry.png`, `button_world_map_fail.png`, `fail_timer_icon.png`, `level_complete_panel.png`, `level_complete_title.png`, `level_failed_panel.png`, `remaining_order_slot.png`, `reward_slot.png`, `score_summary_panel.png`, `time_up_title.png`, `video_ad_icon.png`, and `vip_complete_badge.png`.
- Generation: one separate built-in image-generation operation per distinct non-protected asset; the approved V04 `main_menu_master.png` was the direct primary authority and both approved style boards were secondary references. No V05 art or atlas slicing used.
- Technical cleanup: transparent RGBA conversion and exact master-list canvas normalization only; runtime labels, scores, timers, quantities and reward copy remain unbaked.
- Rejected/regenerated attempts: one extra unpromoted VA-245 draft was generated while confirming the output-path contract and was not used. No promoted Results candidate required regeneration.
- QA: all 16 outputs visually inspected after normalization; complete/failed/time-up states, normal/VIP reward semantics, timer/video-ad icons and replay/retry/navigation buttons are materially distinct. All 16 are exact-size RGBA PNGs with alpha extrema `(0, 255)`.
- Blockers: none.
- Commit/push: pending publication and remote verification.
