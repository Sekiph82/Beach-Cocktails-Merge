# BCM-M21 R04 Repository Hygiene — Owner Ruling V01

Date: 2026-10-04
Canonical task: BCM-M21-007
Owner decision: **AUTHORIZED CLEANUP**

## Owner-approved current visual authority

The owner has personally reviewed and approved the current gameplay background/playable-area design for all ten islands.

For every island under:

`assets/ui_assets/campaign/islands/<island>/`

the current R04 gameplay authority is:

- `gameplay_surface_v07_r04.png`
- `gameplay_surface.png`
- `playable_geometry_r04.json`

These files are protected during cleanup.

The five retained island map/completion assets are also protected:

- `complete_badge.png`
- `map_background.png`
- `map_title.png`
- `theme_badge.png`
- `world_icon.png`

## Cleanup authorization

The owner explicitly authorizes Codex to find, validate, and remove repository files that are obsolete, orphaned, superseded, unused, and not planned for future use.

This includes tracked and untracked cleanup candidates such as:

- orphaned/generated `*.import` sidecars;
- deleted-image `.import` sidecars;
- superseded visual evidence and screenshots;
- rejected candidate images;
- obsolete gameplay-background/table/split-layer assets;
- obsolete masks, overlays, shadows, fit proofs, contact sheets, debug renders;
- obsolete provenance/calibration/measurement JSON;
- stale asset manifests/catalog entries;
- tests and fixtures that assert retired paths;
- helper scripts used only for retired assets/evidence;
- historical visual coordination evidence that is no longer part of the current acceptance chain;
- any other file proven to have no current runtime/config/test/current-contract/future-roadmap use.

## Do not delete

Do not delete:
- any current owner-approved R04 island asset listed above;
- L01-L12 cocktail art currently used by runtime;
- current HUD assets used by runtime;
- current World Map / Island Map assets in active data;
- current campaign/level/economy/save data;
- active gameplay/source/scenes;
- current R04 surface/profile validation;
- any file needed by M22-M27 future work;
- owner-local plugin directories or owner-local project.godot changes;
- any ambiguous path.

If a file might be useful later, classify it KEEP unless current repository truth proves otherwise.

## game_board_background.png

The owner's local deletion of `assets/environment/game_board_background.png` is intentional cleanup input, not a reason to restore it automatically.

Codex must inspect the remaining `data/campaign/islands.json` reference and the actual consumer. If the field/path is obsolete under the current R04 + island-map architecture, update the data/schema/tests and preserve the deletion. If a current accepted screen genuinely still needs the file, stop and report the conflict.

## External deletion-policy note

This ruling removes repo-level restrictions on deletion for BCM-M21-007.

It cannot alter Codex's external command-execution policy. If `git rm` / shell deletion is blocked by the environment, use an ordinary file-delete/edit mechanism that the environment itself permits. Do not attempt to bypass platform safeguards.

Required end state:
- current R04 assets remain intact;
- obsolete files are gone;
- no broken current references;
- tests/contracts/manifests describe current R04 truth only;
- full validation passes.
