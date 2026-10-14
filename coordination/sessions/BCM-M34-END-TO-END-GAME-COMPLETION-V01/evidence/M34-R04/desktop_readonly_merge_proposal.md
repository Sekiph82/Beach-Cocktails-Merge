# BCM-M34-R04-005 — Canonical Desktop read-only reconciliation

Inspection used the current synchronized `origin/main` blob set from the isolated R04 worktree. The canonical Desktop checkout was not fetched, synchronized, staged, or edited during this analysis.

## Observed refs and working state

- Desktop: `main`, HEAD `5cff38a7b360b917739616aaebf79c13987b8d8c`, `origin/main` `2d0d84b91e75459d5ca0c7a3166f4eafb46424b3`, reported `0 ahead / 44 behind`.
- Isolated R04 worktree after safe fast-forward: HEAD `2d0d84b91e75459d5ca0c7a3166f4eafb46424b3`.
- Incoming path comparison from Desktop HEAD to current `origin/main`: zero of seven modified tracked Desktop paths are touched; six are JSON files and one is `project.godot`.
- For every modified tracked path, the `HEAD` blob equals the current `origin/main` blob. Thus each owner edit is a worktree-only delta against a shared unchanged base; there is no incoming side of a three-way content conflict for these paths.
- Desktop also has untracked owner evidence/images and an M23 log/evidence tree. They remain untouched and are excluded from the tracked-only comparison.

## Read-only three-way rows

| Path | Shared base blob | Owner worktree blob | Current origin blob | Proposal |
|---|---|---|---|---|
| `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/mobile_qa/M21-001_MOBILE_LAYOUT_TOUCH_QA.json` | `5287968c936a38595e2d1cb31a848b794cda4dd7` | `cc50185a33040a9ec5bc2abdcd3c9329b5ed0d5f` | same as base | Preserve owner blob verbatim. |
| `coordination/sessions/BCM-M21-RELEASE-CLOSURE/evidence/progression/M21-003_FULL_PROGRESSION.json` | `51131f32f6a910690c7b78e8b56e05a65f1856d3` | `d130af11718d558b67e9c4019b92897831fd680f` | same as base | Preserve owner blob verbatim. |
| `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-001/plugin_runtime_inventory.json` | `2493e55410b4d53b9ce109fb88f9947447e4035c` | `aba3ecfd814ddb6e682e9052d59bb8809054a513` | same as base | Preserve owner blob verbatim. |
| `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-002/semantic_bridge_probe.json` | `142082b5597ae2be5c30078c0c4747e17da0c74e` | `383888ce5520b634b782ec60fe982a59f08705e0` | same as base | Preserve owner blob verbatim. |
| `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-003/policy_validation.json` | `9da70a2738fd806bfcd5be4a43cbec92fc0e1ada` | `b2c028c96ac1e951706ac934c04c5f516059aee6` | same as base | Preserve owner blob verbatim. |
| `coordination/sessions/BCM-M22-MASTER-V01/evidence/M22-003/state_hash_parity_report.json` | `344078d66129f65a2bf768be487933b80e868e85` | `e41d9184f28eff709598ea30cd572a20f0576c28` | same as base | Preserve owner blob verbatim. |
| `project.godot` | `15a168304d729108313be58563592d50da1f99bf` | `9121d5008a528c6cc8b620c5194b9b5cb82916f9` | same as base | Preserve owner blob verbatim. |

## Discrepancy and safe proposal

The R04 prompt describes “2 owner-dirty overlapping JSONs,” but live path and blob comparison found zero incoming overlaps and six dirty JSONs, all with unchanged origin blobs. No pair can be truthfully labeled as the two overlapping files from the current refs. The safe proposal is to preserve all seven modified tracked blobs and every untracked path exactly as found, then have the owner reconcile the Desktop checkout separately. No stash, merge, or file write was performed there. Do not infer that the R04 investigation authorizes committing these owner-local evidence changes.
