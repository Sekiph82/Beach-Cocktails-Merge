# BCM-M33 Content Delivery Design V01

Status: `BUNDLED_APP_UPDATE_DEFAULT; REMOTE_CONTENT_NOT_ENABLED`.

## Default delivery

Ship campaign JSON, the read-only content manifest, scripts, and any required imported art in a versioned Android APK/AAB or iOS IPA/App Store app update. This keeps the complete content set atomic with the runtime that validates and consumes it. The existing private APK/IPA and owner-gated release workflows remain unchanged; M33 does not trigger, sign, upload, or submit a build.

At launch, validate the packaged manifest, supported game compatibility line, island IDs/counts/paths, and each level JSON SHA-256 before reading or writing campaign saves. A missing, incompatible, malformed, or mismatched package fails closed to a visible content-unavailable state with gameplay/map launch disabled. It must not reset, migrate, or write `user://` saves on that failure path.

M33 does not need a forward-only save format. Keep the current schema version and fields, preserve old campaign completion/economy/booster data, and keep migrations deterministic. The previous M32 schema-two runtime ignores unknown optional fields, so an old app can still read compatible saves after rollback. New imported image assets, scenes, scripts, plugin changes, and other Godot-imported resources require a bundled app update.

The existing Android private APK workflow generates `0.1.<run>` names while the iOS workflow accepts an owner-selected marketing version. Since those packaging labels are not one shared release version, the manifest records the supported runtime compatibility line explicitly rather than changing either workflow. Future release owners must update that line only with a compatible app release.

## Future data-only option

Do not download or execute arbitrary remote code, scenes, plugins, or resources. A future data-only update could use HTTPS-delivered declarative campaign JSON only, with owner approval for the service, account, and cost. Before implementation it would require a signed/versioned manifest, compatibility checks, cryptographic verification, atomic validation and activation, offline last-known-good cache, rollback, stale/missing-network handling, and store-policy review. Content that adds images needing Godot import or changes executable behavior remains an app-update requirement.

## Player safety

- Content manifests are packaged and read-only at runtime.
- Save migrations preserve completion records, highest unlocked levels, currency, booster inventory, and transaction/reward ledgers.
- Unsupported future save schemas remain untouched and must use the existing recovery/error path; never replace them with a fresh save automatically.
- A failed content check must happen before campaign save I/O.
- Rollback tests must prove that M33 writes remain readable by the prior schema-two runtime contract.

## M33 packaged authority

`data/campaign/content_manifest_m33.json` is the single read-only package manifest. It records `BCM-M33.2`, Godot compatibility `4.7.x`, the canonical ten-island order, each level-data path/count/SHA-256, and the 1,000-level contract. Startup checks the manifest and every packaged JSON hash before loading the strict `FULL` database or creating the campaign save manager. Runtime consumes the M33 Tiki file at `data/campaign/levels/tiki_island_full.json`; the staged M32 source `tiki_island.json` remains byte-identical.

The M33 Tiki runtime file preserves the M32 Tiki L1–L12 gameplay fields and local IDs. M33 adds only the global IDs and derived theoretical-shot/move-budget metadata needed by the 1,000-level package. Their overlap with some Sunny Cove introduction templates is an explicit owner-directed continuity exception; generated Tiki L13–L100 and the other 800 records avoid those templates. The package therefore contains 900 levels: 12 preserved M32 records and 888 newly generated records.

## Rebuild versus data-only boundary

- A bundled app update is required for changes to Godot scripts, scenes, plugins, imported art, island themes, or content-validation behavior.
- A future data-only release could carry declarative level JSON only. It remains disabled and would need an owner-approved HTTPS service, signed/versioned manifests, compatibility and hash/signature checks, atomic activation, offline last-known-good cache, rollback, and store-policy review before implementation.
- No remotely supplied scripts, scenes, or plugins may execute. Do not use another project's credentials or endpoints.

## Save and rollback evidence boundary

M33 keeps `SaveManager.SCHEMA_VERSION` at 2 and changes no save fields. Builder probes cover v1 migration, backup recovery, future-schema non-destructive behavior, schema-two roundtrip with unknown optional data, and corrupt-manifest fallback before campaign save-manager creation. `save_manager.gd` is unchanged from task-start HEAD. These checks establish the source-level compatibility contract; the previous installed Android/iOS binary was not launched, so binary rollback remains unverified.
