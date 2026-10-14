# R04-005 — Desktop overlap review and regression

Result: **Regression probes pass; Desktop remains read-only and unreconciled.**

Daily Rewards, economy closure, and M33 campaign navigation all returned exit 0. The full navigation probe exercised 1,000 ordered completions and ten island routes. See `regression_summary.json` and captured stdout files. The known `WorldMapScene.tscn` and `main.tscn` invalid external script UIDs reproduced; both fallback text paths resolve. Source inspection confirms no production Focus booster/currency UI was restored; retired legacy inventory/migration remains inert. Accepted MOVES/tutorial work was not touched.

Read-only Desktop comparison found seven dirty tracked paths (six JSON files and `project.godot`), all with identical origin/main and local-HEAD base blobs, so zero incoming path overlaps were confirmed. The prompt's stated count of two overlapping JSONs does not match the live refs. The detailed per-path preservation proposal is in `desktop_readonly_merge_proposal.md`. All dirty and untracked Desktop data remain untouched.
