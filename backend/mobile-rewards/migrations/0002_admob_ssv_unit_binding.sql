-- Google documents the signed SSV `ad_unit` as the numeric AdMob unit ID,
-- while the app requests ads with the full ca-app-pub-.../... unit string.
-- Store the explicitly approved callback value on each claim so policy changes
-- cannot silently rebind an already-issued nonce.
ALTER TABLE ad_claims ADD COLUMN ssv_ad_unit TEXT NOT NULL DEFAULT '';
