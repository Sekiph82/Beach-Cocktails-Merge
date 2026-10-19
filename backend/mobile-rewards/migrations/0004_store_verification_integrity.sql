-- Forward-only hardening for store ledger UPDATEs. No provider or Worker path
-- writes this schema yet; these guards make future writes obey immutable
-- provider/account identity and explicit transaction/entitlement lifecycles.

-- Keep purchase identity and verified metadata immutable. The only mutable
-- history fields are state (verified -> terminal) and a nondecreasing recheck
-- timestamp. Terminal states cannot be reopened by editing the same record.
CREATE TRIGGER IF NOT EXISTS store_purchase_history_identity_immutable
BEFORE UPDATE ON store_purchase_history
WHEN NEW.platform IS NOT OLD.platform
  OR NEW.transaction_id IS NOT OLD.transaction_id
  OR NEW.original_transaction_id IS NOT OLD.original_transaction_id
  OR NEW.provider_order_id IS NOT OLD.provider_order_id
  OR NEW.user_id IS NOT OLD.user_id
  OR NEW.product_id IS NOT OLD.product_id
  OR NEW.product_kind IS NOT OLD.product_kind
  OR NEW.application_id IS NOT OLD.application_id
  OR NEW.environment IS NOT OLD.environment
  OR NEW.purchased_at IS NOT OLD.purchased_at
  OR NEW.expires_at IS NOT OLD.expires_at
  OR NEW.checked_at < OLD.checked_at
BEGIN
    SELECT RAISE(ABORT, 'verified store purchase identity is immutable');
END;

CREATE TRIGGER IF NOT EXISTS store_purchase_history_state_transition
BEFORE UPDATE OF state ON store_purchase_history
WHEN NEW.state IS NOT OLD.state
  AND NOT (OLD.state = 'verified' AND NEW.state IN ('refunded', 'revoked', 'expired'))
BEGIN
    SELECT RAISE(ABORT, 'invalid store purchase state transition');
END;

-- Journal identity, grant payload, and creation time are write-once. Apply is
-- allowed only while the exact same owner/product purchase remains verified.
-- Reverse is allowed only after provider history reached a terminal state.
CREATE TRIGGER IF NOT EXISTS store_grant_journal_update_integrity
BEFORE UPDATE ON store_grant_journal
WHEN NEW.platform IS NOT OLD.platform
  OR NEW.transaction_id IS NOT OLD.transaction_id
  OR NEW.user_id IS NOT OLD.user_id
  OR NEW.product_id IS NOT OLD.product_id
  OR NEW.product_kind IS NOT OLD.product_kind
  OR NEW.grant_payload_json IS NOT OLD.grant_payload_json
  OR NEW.created_at IS NOT OLD.created_at
  OR NOT (
    (OLD.state = 'pending' AND NEW.state = 'pending' AND NEW.applied_at IS OLD.applied_at)
    OR (OLD.state = 'pending' AND NEW.state = 'applied' AND NEW.applied_at IS NOT NULL AND EXISTS (
      SELECT 1 FROM store_purchase_history p
      WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
        AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
        AND p.product_kind = NEW.product_kind AND p.state = 'verified'
    ))
    OR (OLD.state = 'applied' AND NEW.state = 'applied' AND NEW.applied_at IS OLD.applied_at AND EXISTS (
      SELECT 1 FROM store_purchase_history p
      WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
        AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
        AND p.product_kind = NEW.product_kind AND p.state = 'verified'
    ))
    OR (OLD.state IN ('pending', 'applied') AND NEW.state = 'reversed'
      AND NEW.applied_at IS OLD.applied_at AND EXISTS (
        SELECT 1 FROM store_purchase_history p
        WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
          AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
          AND p.product_kind = NEW.product_kind AND p.state IN ('refunded', 'revoked', 'expired')
      ))
    OR (OLD.state = 'reversed' AND NEW.state = 'reversed' AND NEW.applied_at IS OLD.applied_at AND EXISTS (
      SELECT 1 FROM store_purchase_history p
      WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
        AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
        AND p.product_kind = NEW.product_kind AND p.state IN ('refunded', 'revoked', 'expired')
    ))
  )
BEGIN
    SELECT RAISE(ABORT, 'invalid store grant journal update');
END;

-- Entitlement identity cannot move between users/products/platforms. The sole
-- transaction rebinding is a revoked/expired entitlement moving to a distinct
-- matching verified non-consumable transaction for the same owner/product.
-- No same-transaction reactivation is permitted after terminal revocation.
CREATE TRIGGER IF NOT EXISTS store_entitlements_update_integrity
BEFORE UPDATE ON store_entitlements
WHEN NEW.user_id IS NOT OLD.user_id
  OR NEW.product_id IS NOT OLD.product_id
  OR NEW.platform IS NOT OLD.platform
  OR NEW.updated_at < OLD.updated_at
  OR NOT (
    (OLD.state = 'active' AND NEW.state = 'active' AND NEW.transaction_id IS OLD.transaction_id
      AND NEW.granted_at IS OLD.granted_at AND NEW.expires_at IS OLD.expires_at AND EXISTS (
        SELECT 1 FROM store_purchase_history p
        WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
          AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
          AND p.product_kind = 'non_consumable' AND p.state = 'verified'
      ))
    OR (OLD.state = 'active' AND NEW.state IN ('revoked', 'expired')
      AND NEW.transaction_id IS OLD.transaction_id AND NEW.granted_at IS OLD.granted_at
      AND NEW.expires_at IS OLD.expires_at AND EXISTS (
        SELECT 1 FROM store_purchase_history p
        WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
          AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
          AND p.product_kind = 'non_consumable'
          AND ((NEW.state = 'expired' AND p.state = 'expired')
            OR (NEW.state = 'revoked' AND p.state IN ('refunded', 'revoked')))
      ))
    OR (OLD.state = NEW.state AND OLD.state IN ('revoked', 'expired')
      AND NEW.transaction_id IS OLD.transaction_id AND NEW.granted_at IS OLD.granted_at
      AND NEW.expires_at IS OLD.expires_at AND EXISTS (
        SELECT 1 FROM store_purchase_history p
        WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
          AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
          AND p.product_kind = 'non_consumable'
          AND ((NEW.state = 'expired' AND p.state = 'expired')
            OR (NEW.state = 'revoked' AND p.state IN ('refunded', 'revoked')))
      ))
    OR (OLD.state IN ('revoked', 'expired') AND NEW.state = 'active'
      AND NEW.transaction_id IS NOT OLD.transaction_id AND NEW.granted_at > OLD.granted_at
      AND NEW.expires_at IS NULL AND EXISTS (
        SELECT 1 FROM store_purchase_history p
        WHERE p.platform = NEW.platform AND p.transaction_id = NEW.transaction_id
          AND p.user_id = NEW.user_id AND p.product_id = NEW.product_id
          AND p.product_kind = 'non_consumable' AND p.state = 'verified'
      ))
  )
BEGIN
    SELECT RAISE(ABORT, 'invalid store entitlement update');
END;
