# R04-003 — Rewarded-ad adapter gate

Result: **NOT INTEGRATED; reward path remains fail-closed.**

The current `AdsService` requires explicit consent, an adapter, a matching active transaction, a nonempty provider receipt, and duplicate-receipt rejection before emitting `verified_rewarded`. The plugin callback inspected is `rewarded_ad_user_earned_reward(ad_info, reward_data)` where the reward item contains amount/type; it exposes no unique server-verifiable receipt in that signal contract. The current reward ledger therefore cannot safely treat the client callback alone as its required provider receipt. With no Android export toolchain, no native adapter/build proof is possible.

No app source, IDs, consent policy, or provider configuration was changed. Production IDs, banner, and interstitial remain disabled. Energy +20 and Daily slots 2–5 remain unavailable without the existing verified-provider path; no fake product reward was introduced.
