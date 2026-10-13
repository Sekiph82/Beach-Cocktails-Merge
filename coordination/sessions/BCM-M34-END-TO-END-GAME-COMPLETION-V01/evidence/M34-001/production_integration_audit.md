# M34-001 Production Integration Audit

Audit baseline: isolated worktree at `9c3ceaedb2e6c54edbad42fead670a5ab2c37e53`; Godot 4.7.2; canonical data loaded in `ValidationMode.FULL`. This is builder evidence, not the independent acceptance audit.

| Area | Status | Evidence / boundary |
|---|---|---|
| Home, onboarding, Settings, accessibility | PASS / PARTIAL | `ApplicationShell` owns the screens and saved presentation preferences. Existing tutorial/mobile probes cover scripted menu paths; live-device touch, assistive technology, and human visual acceptance remain unverified. |
| World Map → Island Map → level selection across 10 islands | PASS / PARTIAL | `m33_campaign_navigation_probe.gd` exercises all 10 maps, 100 level nodes, and controller selection. `m34_production_routes_probe.gd` activates visible production island and level buttons through their `pressed` signals across all ten islands; it is not physical pointer/device input. |
| Ten islands / 1,000 canonical level records | PASS (data validation) | `m33_campaign_content_probe.gd`: 1,000 rows, ten islands × 100 levels, ordered IDs 1–1,000; M32 Tiki seed preserved. This is not proof that every level is human-solvable. |
| Gameplay To-Go, VIP, moves, untimed session | PASS / PARTIAL | Production session bridge retains normal objectives, optional VIP score path, and move limit. Synthetic objective-delivery probes are not physical play or human duration evidence. Existing M33-004 physical reachability and fairness qualification remains open. |
| WIN/LOSE, Results, Retry / Next | PASS / PARTIAL | Production bridge/navigation probes cover terminal results, retry, and progression. All-island human completion and owner-visible acceptance are not claimed. |
| Energy and free economy | PASS (bounded implementation) | Schema 3 save, actual-start attempt charge, natural regen, 25-Gem refill, approved star/island awards and reward/transaction ledgers; see M34-008 probe. Cross-install/cloud restore is not implemented. |
| Focus removal / old save migration | PASS (code and probe) | No gameplay Focus action/button or Shop offer; schema 1/2 migration moves existing Focus count to `retired_focus_inventory` without conversion or deletion and keeps other inventory, balances, and ledgers. The stored retired value is inert. |
| Daily rewards | PARTIAL / OWNER DECISION REQUIRED | Five slots/data retained; slot 3 has no reward and reset policy is undecided. Claims are disabled; no daily currency or ad reward is granted. |
| Ads / consent | PARTIAL / BLOCKED DEVICE INTEGRATION | Fail-closed provider abstraction and verified-reward receipt boundary implemented. No native provider is vendored/configured, no consent/age policy is approved, and Android/iOS builds/devices were not available in this bounded run. |
| IAP / store | BLOCKED LIVE PAYMENT VERIFICATION | Placeholder catalog has blank IDs and `buyable:false`; service rejects purchase/restore without provider and trusted verifier. No catalog/prices, native adapter, backend verifier, receipt validation, or store test account is configured. |
| Local data isolation | PASS (probe boundary) | Godot used a task-owned `APPDATA` under this isolated worktree for all import/test `user://` writes. The canonical Desktop checkout was not used for execution or edits. |
| Export, store, signing, physical devices | UNVERIFIED | No export presets, package signing, account access, paid purchases, Android/iOS device run, or store upload was performed. |

## Scope notes

- The production game retains accepted gameplay physics, the current M33 campaign content, tutorial, To-Go/VIP, star thresholds, and no-timer behavior.
- The only changed gameplay HUD treatment is the requested framed MOVES element; Focus has no frame or replacement booster.
- The campaign data contains 100 legacy Sunny Cove rows without `global_level_id`; the builder implementation resolves those through the canonical island order, while newer generated rows retain explicit IDs.
- A test assertion requiring 100 unique Tiki objective signatures was corrected to a diversity threshold. The authoritative data contains 33 distinct signatures across its 100 levels; test evidence does not imply every level is unique.
- The final owner review of screenshots and the separate ChatGPT audit are pending.
