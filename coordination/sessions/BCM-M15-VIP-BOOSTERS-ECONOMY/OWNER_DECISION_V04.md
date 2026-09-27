# BCM-M15 Owner Decision V04 — VIP Overlay Visual Gate

Status: **OWNER DECISION RECORDED / VISUAL GATE FAILED**

Decision date: 2026-09-27
Decision source: Beach Cocktails Merge SEF chat
Decision scope: committed M15 V03 Windows/OpenGL evidence only

## Authority

This artifact records the direct owner decision supplied after the independent
technical V03 audit. It does not change the V03 target-policy, payout,
economy, score, bridge, or regression findings.

Evidence reviewed:

- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/vip_pending.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/vip_partial.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/vip_completed.png`
- `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v03/non_vip.png`

## Exact owner decision

The owner decision is preserved verbatim:

> VIP Pending: FAIL
> Cocktail üzerine metin biniyor, VIP hedef görseli yok, 2X kayboluyor.
>
> VIP Partial: FAIL
> 1/2 değişiyor ama bilgi mimarisi değişmediği için ilerleme yeterince görünür değil.
>
> VIP Completed: FAIL
> COMPLETED uzunluğu paneli daha da bozuyor; completion için metin yerine görsel state gerekir.
>
> Non-VIP: görsel baseline olarak PASS.
> Çünkü VIP overlay ortadan kalkınca To-Go paneli tekrar nefes alıyor. Bu da problemin panel asset’inde değil, VIP overlay tasarımında olduğunu oldukça net gösteriyor.

## Controlled interpretation

| State | Owner result | Recorded requirement |
| --- | --- | --- |
| VIP pending | **FAIL** | Keep the VIP target cocktail image visible, prevent overlay text from covering it, and keep the `2X` indication visible. |
| VIP partial | **FAIL** | Make progress materially visible through the VIP visual information architecture; changing only `1/2` text is insufficient. |
| VIP completed | **FAIL** | Use a bounded visual completion state rather than the long `COMPLETED` text. |
| Non-VIP | **PASS** | Preserve the current non-VIP baseline; the normal To-Go panel asset is not the remediation target. |

## Lifecycle consequence

M15 remains open. The V03 technical implementation is not rejected outside
the VIP overlay visual gate. A bounded CODEX remediation is required for the
VIP overlay states only. M16 remains blocked until the remediation is
independently audited and the owner visual gate is closed.

No additional product requirement is inferred from this decision.
