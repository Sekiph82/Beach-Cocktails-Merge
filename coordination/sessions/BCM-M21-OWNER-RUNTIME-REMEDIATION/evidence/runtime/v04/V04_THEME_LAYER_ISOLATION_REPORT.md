# V04 Sunny Cove Theme Layer Isolation

Status: **BUILDER EVIDENCE — OWNER F5 REVIEW PENDING**

Runtime screenshot: `04_sunny_cove_gameplay_shifted_720x1280.png`
Machine-readable inventory: `V04_THEME_LAYER_ISOLATION.json`

## Runtime layer inventory

| Theme layer | Source | Runtime state | Contribution / placement |
|---|---|---|---|
| `gameplay_background` | `assets/ui_assets/campaign/islands/sunny_cove/gameplay_background.png` | Visible as `GameBoardBackground`, z -100 | Fixed full-screen Sunny Cove beach, palms, cove and bar scene. |
| `gameplay_table_shadow` | `assets/ui_assets/campaign/islands/sunny_cove/gameplay_table_shadow.png` | Visible as `CampaignTableShadow`, z -90 | Contact shadow; shifted with the table by +150 canonical px Y. |
| `gameplay_table` | `assets/ui_assets/campaign/islands/sunny_cove/gameplay_table.png` | Visible as `CampaignTable`, z -10 | Wooden tabletop, apron, two legs and attached tropical trim; shifted by +150 canonical px Y. |
| `table_edge_overlay` | `assets/ui_assets/campaign/islands/sunny_cove/table_edge_overlay.png` | Visible as `CampaignTableEdgeOverlay`, z 5 | Table rail highlights and edge finish; shifted by +150 canonical px Y. |
| `launch_zone` | `assets/ui_assets/campaign/islands/sunny_cove/launch_zone.png` | Not instantiated or rendered | Full-screen pool and decor art is excluded. `LaunchIndicator` draws only a 3 px programmatic line at the translated launch Y. |

## Residual decor source

The runtime inventory contains no `decor_left.png`, `decor_right.png`, `decor_back.png`, or `launch_zone.png` texture node. The remaining visible foliage is baked into two canonical sources: the palms/bar scene in `gameplay_background.png` and the leaves/flowers attached to the accepted wooden table in `gameplay_table.png`. The edge highlights belong to `table_edge_overlay.png`. There is no separate foreground decoration node left to remove. No canonical PNG was edited and no derivative PNG was created.

The contact evidence is the clean gameplay capture above plus the five-layer path/state inventory in `V04_THEME_LAYER_ISOLATION.json`. Owner review remains the authority on whether any foliage baked into the background or table is still unwanted.
