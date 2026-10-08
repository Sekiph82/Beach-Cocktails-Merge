# M21 PLAY Route Diagnosis

Classification: `STALE_PROBE`.

The 720x1440 failure was caused by the old mobile probe expecting Home PLAY to enter World Map. That expectation is superseded by the owner-approved R08 Home frontier contract. R08 directs normal Home PLAY to launch the current unlocked frontier and keep explicit old-level replay inside Island Map. The later R09 owner acceptance confirms the separate World Map route and its navigation behavior.

Current production source confirms the distinction:

- `ApplicationShell.press_play_continue()` calls `CampaignNavigationController.continue_campaign()` in `scripts/campaign/application_shell.gd`.
- `CampaignNavigationController.continue_campaign()` resolves `CampaignManager.get_frontier_level_id()` and launches the unlocked frontier in `scripts/campaign/campaign_navigation_controller.gd`.
- `ApplicationShell.press_world_map()` calls `CampaignNavigationController.show_world_map()` as its separate route.

The previous diagnostic `evidence/M23-R03/m21_tall_navigation_diagnostic.json` records the fresh-session 720x1440 state after PLAY as `shell_view=CAMPAIGN`, `navigation_view=GAMEPLAY`, with configured campaign/navigation. The old probe recorded zero headless captures, so it did not establish image acceptance.

The corrected `tests/m21_mobile_qa_probe.gd` now checks both routes at 720x1280 and 720x1440: PLAY enters gameplay with exactly one gameplay instance and does not enter World Map; WORLD MAP enters World Map with zero gameplay instances. The final GL Compatibility run exited 0 with zero failed checks and saved 16 real-renderer captures (12 at 720x1280 and 4 at 720x1440). World Map, lower Island Map, and gameplay captures were visually inspected. Physical-device acceptance remains outside this headless/desktop builder evidence.

No production navigation, map geometry, or gameplay code changed for this finding.
