# Actual game capture set — V03

Nine images in `captures_v03/` were captured from the visible Godot 4.7.2 production game window using the production `ApplicationShellScene.tscn`. The capture script read the live viewport texture; no screenshot was painted, synthesized, or composed. Each JSON sidecar records capture time, viewport size, scene/view metadata, source revision, and the required `DESKTOP_GAMEPLAY_CANDIDATE` / `DEVICE_REVIEW_PENDING` labels.

The game was launched with a unique isolated Godot user-data profile under ignored project-local `.godot/bcm_sandboxes/bcm_m34_v03_20261020_01/`. No owner `user://` save was read or changed. Interactions used the visible game UI and real gameplay input. The capture runner writes PNGs at the native 720×1280 viewport resolution. These are genuine desktop game captures, not final Apple or Google device screenshots.

| File | Captured content |
|---|---|
| `desktop_candidate_01_main_menu.png` | Production Home/main menu |
| `desktop_candidate_02_campaign.png` | Production World Map with actual island lock/unlock state |
| `desktop_candidate_03_campaign.png` | Sunny Cove Island Map |
| `desktop_candidate_04_campaign.png` | Gameplay board with actual To-Go orders |
| `desktop_candidate_05_campaign.png`–`07_campaign.png` | Real gameplay progression after player launches |
| `desktop_candidate_08_campaign.png` | Actual L3 merge; live log showed `MERGE L3 +50`, HUD score 50 |
| `desktop_candidate_09_daily_rewards.png` | Daily Rewards screen; viewed without claiming a reward |

**Not produced:** Level Won screen (no level was completed); Boosters screen (the captured level has boosters disabled); physical iOS/Android device screenshots; approved store icon. These states were not faked. The existing Play feature graphic is a separate marketing asset, not a gameplay capture.

Before store upload, capture exact release UI on supported physical devices at current Console-accepted dimensions, localize captions, visually review safe areas and legibility, and replace candidate files only with traceable device captures. Keep all nine candidates labeled pending until then.

## Captioned marketing compositions

`compositions_v03/` contains six 1080×1920 PNG compositions made from the real screenshots above. Each uses an English heading in a separate frame band, the untouched game viewport scaled proportionally, and an explicit `REAL GAME CAPTURE • DESKTOP CANDIDATE • DEVICE REVIEW PENDING` footer. The live game image was not painted or state-edited. These are owner-review marketing compositions only; their desktop-origin viewport and added frame do not make them captured or approved Android/iOS device screenshots.
