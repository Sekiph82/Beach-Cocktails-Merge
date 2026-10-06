# project.godot reconciliation — R03

At the synchronized starting revision, the only tracked local difference was the GameFeelFlow autoload path:

- Canonical `origin/main`: `GameFeelFlow="*res://addons/game_feel_flow/core/game_feel_flow.gd"`
- Local normalization: `GameFeelFlow="*uid://ckhnfaf1odnpl"`
- `addons/game_feel_flow/core/game_feel_flow.gd.uid` contains `uid://ckhnfaf1odnpl` and resolves to the same script.

No semantic plugin/autoload difference was present. The canonical file was restored byte-for-byte; `git diff -- project.godot` is empty and the tracked file SHA-256 is `15A168304D729108313BE58563592D50DA1F99BF`. A subsequent editor import normalized the path again; that generated normalization was restored a second time after confirming the same UID sidecar mapping. Final `project.godot` remains canonical.

The safe-sync preservation stash `owner-local-safe-sync-b213fbd` was applied without dropping it as required by the standing safe-sync procedure. Its original owner-local UID-only edit is no longer present in the working tree.
