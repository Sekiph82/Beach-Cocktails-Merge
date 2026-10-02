# M21 World Map Hotspot Calibration — V04

Status: **BUILDER VISUAL CALIBRATION — OWNER F5 REVIEW PENDING**

Reference capture: `../runtime/v04/01_world_map_calibrated_720x1280.png`
Machine-readable centers: `../runtime/v04/V04_HOTSPOT_CENTERS.json`

The ten owner seed coordinates were refined against the baked island bodies visible in the 720×1280 World Map capture. The `MapCanvas` is 720×962 at screen origin `(0,142)`. The table lists each normalized owner seed, final data value, its adjustment, the selected painted land-body anchor, and the resulting canonical screen center. Residual is the Euclidean screen-pixel distance from the runtime marker center to the selected anchor. All normalized adjustments are within the owner limit of ±0.025 and every residual is below the 20 px target. Anchors are builder visual estimates from the capture; owner F5 review remains required.

| Island | Owner seed | Final `map_position` | Adjustment | Painted body anchor (screen px) | Marker center (screen px) | Residual |
|---|---:|---:|---:|---:|---:|---:|
| Sunny Cove | `[0.15, 0.88]` | `[0.17, 0.88]` | `[+0.020, 0.000]` | `(132, 985)` | `(122.4, 988.6)` | `10.2 px` |
| Tiki Island | `[0.12, 0.65]` | `[0.14, 0.665]` | `[+0.020, +0.015]` | `(98, 785)` | `(100.8, 781.7)` | `4.3 px` |
| Azure Bay | `[0.64, 0.80]` | `[0.665, 0.82]` | `[+0.025, +0.020]` | `(484, 927)` | `(478.8, 930.8)` | `6.5 px` |
| Coconut Beach | `[0.28, 0.52]` | `[0.305, 0.54]` | `[+0.025, +0.020]` | `(218, 672)` | `(219.6, 661.5)` | `10.6 px` |
| Sunset Island | `[0.50, 0.52]` | `[0.50, 0.52]` | `[0.000, 0.000]` | `(359, 650)` | `(360.0, 642.2)` | `7.8 px` |
| Party Beach | `[0.81, 0.59]` | `[0.835, 0.615]` | `[+0.025, +0.025]` | `(606, 739)` | `(601.2, 733.6)` | `7.2 px` |
| Frozen Paradise | `[0.75, 0.03]` | `[0.775, 0.02]` | `[+0.025, -0.010]` | `(558, 165)` | `(558.0, 161.2)` | `3.8 px` |
| Volcano Bay | `[0.23, 0.04]` | `[0.23, 0.015]` | `[0.000, -0.025]` | `(162, 161)` | `(165.6, 156.4)` | `5.8 px` |
| Billionaire Island | `[0.61, 0.19]` | `[0.61, 0.19]` | `[0.000, 0.000]` | `(440, 331)` | `(439.2, 324.8)` | `6.3 px` |
| Final Island | `[0.82, 0.36]` | `[0.795, 0.347]` | `[-0.025, -0.013]` | `(574, 477)` | `(572.4, 475.8)` | `2.0 px` |

Each entry's ring, lock state and click rectangle use the same screen center. Both the per-island thumbnail node and the locked-overlay thumbnail texture are hidden; state remains visible through the ring and label. The runtime `IslandRoute` line is absent.
