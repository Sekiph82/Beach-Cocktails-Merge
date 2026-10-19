-- Forward-only store ledger preparation. The Worker has no trusted store
-- verifier yet, so these tables are not writable through production routes.
CREATE TABLE IF NOT EXISTS store_verification_attempts (
    attempt_id TEXT PRIMARY KEY,
    platform TEXT NOT NULL CHECK (platform IN ('apple', 'google')),
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    product_kind TEXT NOT NULL CHECK (product_kind IN ('consumable', 'non_consumable')),
    application_id TEXT NOT NULL,
    environment TEXT NOT NULL CHECK (environment IN ('sandbox', 'production', 'unknown')),
    outcome TEXT NOT NULL CHECK (outcome IN ('pending', 'verified', 'rejected', 'unavailable')),
    token_sha256 TEXT,
    created_at INTEGER NOT NULL,
    verified_at INTEGER,
    CHECK (token_sha256 IS NULL OR length(token_sha256) = 64)
);

-- The unique provider transaction binding prevents a verified purchase from
-- being claimed by a second authenticated app account.
CREATE TABLE IF NOT EXISTS store_purchase_history (
    platform TEXT NOT NULL CHECK (platform IN ('apple', 'google')),
    transaction_id TEXT NOT NULL,
    original_transaction_id TEXT,
    provider_order_id TEXT,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    product_kind TEXT NOT NULL CHECK (product_kind IN ('consumable', 'non_consumable')),
    application_id TEXT NOT NULL,
    environment TEXT NOT NULL CHECK (environment IN ('sandbox', 'production')),
    state TEXT NOT NULL CHECK (state IN ('verified', 'refunded', 'revoked', 'expired')),
    purchased_at INTEGER NOT NULL,
    expires_at INTEGER,
    checked_at INTEGER NOT NULL,
    PRIMARY KEY (platform, transaction_id)
);

CREATE INDEX IF NOT EXISTS store_purchase_history_user_product_idx
    ON store_purchase_history(user_id, product_id, state);
CREATE UNIQUE INDEX IF NOT EXISTS store_purchase_history_provider_order_idx
    ON store_purchase_history(platform, provider_order_id)
    WHERE provider_order_id IS NOT NULL;

-- A verified transaction may create exactly one durable grant intent. Applying
-- it is a future game-economy operation and is not currently exposed by API.
CREATE TABLE IF NOT EXISTS store_grant_journal (
    platform TEXT NOT NULL,
    transaction_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    product_kind TEXT NOT NULL CHECK (product_kind IN ('consumable', 'non_consumable')),
    state TEXT NOT NULL CHECK (state IN ('pending', 'applied', 'reversed')),
    grant_payload_json TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    applied_at INTEGER,
    PRIMARY KEY (platform, transaction_id),
    FOREIGN KEY (platform, transaction_id)
      REFERENCES store_purchase_history(platform, transaction_id)
);

CREATE INDEX IF NOT EXISTS store_grant_journal_user_state_idx
    ON store_grant_journal(user_id, state, created_at);

CREATE TRIGGER IF NOT EXISTS store_grant_journal_verified_insert
BEFORE INSERT ON store_grant_journal
WHEN NOT EXISTS (
    SELECT 1 FROM store_purchase_history p
    WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
      AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
      AND p.product_kind = NEW.product_kind AND p.state = 'verified'
)
BEGIN
    SELECT RAISE(ABORT, 'store grant requires matching verified purchase');
END;

-- Restore is entitlement-only. Consumable products are intentionally excluded.
CREATE TABLE IF NOT EXISTS store_entitlements (
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('apple', 'google')),
    transaction_id TEXT NOT NULL,
    state TEXT NOT NULL CHECK (state IN ('active', 'revoked', 'expired')),
    granted_at INTEGER NOT NULL,
    expires_at INTEGER,
    updated_at INTEGER NOT NULL,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (platform, transaction_id)
      REFERENCES store_purchase_history(platform, transaction_id)
);

CREATE TRIGGER IF NOT EXISTS store_entitlements_verified_nonconsumable_insert
BEFORE INSERT ON store_entitlements
WHEN NOT EXISTS (
    SELECT 1 FROM store_purchase_history p
    WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
      AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
      AND p.product_kind = 'non_consumable' AND p.state = 'verified'
)
BEGIN
    SELECT RAISE(ABORT, 'restore requires matching verified non-consumable');
END;

CREATE TRIGGER IF NOT EXISTS store_entitlements_verified_nonconsumable_update
BEFORE UPDATE OF user_id, product_id, platform, transaction_id ON store_entitlements
WHEN NOT EXISTS (
    SELECT 1 FROM store_purchase_history p
    WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
      AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
      AND p.product_kind = 'non_consumable' AND p.state = 'verified'
)
BEGIN
    SELECT RAISE(ABORT, 'restore requires matching verified non-consumable');
END;

-- Preserve an audit trail when a trusted later provider check reverses a
-- purchase. This marks server entitlement/journal state; it never mutates the
-- game's currency balance or silently claws back already-spent consumables.
CREATE TRIGGER IF NOT EXISTS store_purchase_reversal_propagation
AFTER UPDATE OF state ON store_purchase_history
WHEN OLD.state = 'verified' AND NEW.state IN ('refunded', 'revoked', 'expired')
BEGIN
    UPDATE store_grant_journal SET state = 'reversed'
      WHERE platform = NEW.platform AND transaction_id = NEW.transaction_id;
    UPDATE store_entitlements SET state = CASE WHEN NEW.state = 'expired' THEN 'expired' ELSE 'revoked' END,
      updated_at = NEW.checked_at
      WHERE platform = NEW.platform AND transaction_id = NEW.transaction_id;
END;
