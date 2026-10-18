CREATE TABLE IF NOT EXISTS ad_claims (
    nonce TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    placement_id TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
    ad_unit TEXT NOT NULL,
    reward_item TEXT NOT NULL,
    reward_amount INTEGER NOT NULL CHECK (reward_amount > 0),
    state TEXT NOT NULL CHECK (state IN ('pending', 'settled', 'expired')) DEFAULT 'pending',
    expires_at INTEGER NOT NULL,
    transaction_id TEXT UNIQUE,
    created_at INTEGER NOT NULL,
    settled_at INTEGER
);

CREATE INDEX IF NOT EXISTS ad_claims_user_state_idx
    ON ad_claims(user_id, state, created_at);

CREATE TABLE IF NOT EXISTS reward_ledger (
    transaction_id TEXT PRIMARY KEY,
    nonce TEXT NOT NULL UNIQUE REFERENCES ad_claims(nonce),
    user_id TEXT NOT NULL,
    placement_id TEXT NOT NULL,
    reward_item TEXT NOT NULL,
    reward_amount INTEGER NOT NULL CHECK (reward_amount > 0),
    granted_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS reward_ledger_user_idx ON reward_ledger(user_id, granted_at);

CREATE TABLE IF NOT EXISTS store_transactions (
    platform TEXT NOT NULL CHECK (platform IN ('apple', 'google')),
    transaction_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    product_kind TEXT NOT NULL CHECK (product_kind IN ('non_consumable', 'consumable', 'subscription')),
    state TEXT NOT NULL CHECK (state IN ('verified', 'revoked', 'refunded')),
    environment TEXT NOT NULL,
    verified_at INTEGER NOT NULL,
    PRIMARY KEY (platform, transaction_id)
);

CREATE INDEX IF NOT EXISTS store_transactions_user_product_idx
    ON store_transactions(user_id, product_id, state);
