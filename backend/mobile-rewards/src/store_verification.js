// Store purchase verification is intentionally sealed until provider trust,
// owner-approved product policy, and native identity configuration exist.
// Never replace these rejecting adapters with decoded client assertions.

const PLATFORMS = new Set(["apple", "google"]);
const PRODUCT_KINDS = new Set(["consumable", "non_consumable"]);
const MAX_TOKEN_LENGTH = 16_384;
const CLIENT_AUTHORITY_FIELDS = new Set(["user_id", "transaction_id", "original_transaction_id", "application_id",
  "environment", "kind", "verified", "grant", "purchase_state", "state", "expires_at"]);

export function parseStorePolicy(raw) {
  if (typeof raw !== "string" || raw.length === 0) return null;
  let policy;
  try { policy = JSON.parse(raw); } catch { return null; }
  if (!policy || typeof policy !== "object" || Array.isArray(policy)) return null;
  const normalized = {};
  for (const platform of PLATFORMS) {
    const entry = policy[platform];
    if (!entry || typeof entry !== "object" || Array.isArray(entry)
      || typeof entry.application_id !== "string" || entry.application_id.length < 3
      || !entry.products || typeof entry.products !== "object" || Array.isArray(entry.products)) return null;
    const products = {};
    for (const [productId, product] of Object.entries(entry.products)) {
      if (!/^[A-Za-z0-9._-]{1,128}$/.test(productId) || !product || typeof product !== "object"
        || !PRODUCT_KINDS.has(product.kind) || product.enabled !== true) return null;
      products[productId] = { kind: product.kind, enabled: true };
    }
    if (Object.keys(products).length === 0) return null;
    normalized[platform] = { application_id: entry.application_id, products };
  }
  return normalized;
}

export function validateStoreSubmission(body, policy) {
  if (!body || typeof body !== "object" || Array.isArray(body) || !policy
    || !PLATFORMS.has(body.platform) || typeof body.product_id !== "string") return null;
  if (Object.keys(body).some((key) => CLIENT_AUTHORITY_FIELDS.has(key))) return null;
  const platformPolicy = policy[body.platform];
  const product = platformPolicy?.products?.[body.product_id];
  if (!product?.enabled) return null;
  if (body.platform === "google") {
    if (typeof body.purchase_token !== "string" || body.purchase_token.length < 8
      || body.purchase_token.length > MAX_TOKEN_LENGTH) return null;
    return { platform: "google", applicationId: platformPolicy.application_id,
      productId: body.product_id, kind: product.kind, purchaseToken: body.purchase_token };
  }
  if (typeof body.signed_transaction !== "string" || body.signed_transaction.length < 16
    || body.signed_transaction.length > MAX_TOKEN_LENGTH) return null;
  return { platform: "apple", applicationId: platformPolicy.application_id,
    productId: body.product_id, kind: product.kind, signedTransaction: body.signed_transaction };
}

// Deliberately no network call, JWT decode, or synthetic signature acceptance.
// A future implementation must validate Google's authenticated Developer API
// response or Apple's JWS certificate chain and signed server transaction.
export async function verifyGooglePurchase(_submission, _env) {
  return { verified: false, reason: "GOOGLE_TRUSTED_VERIFIER_UNAVAILABLE" };
}

export async function verifyApplePurchase(_submission, _env) {
  return { verified: false, reason: "APPLE_JWS_TRUST_CHAIN_VERIFIER_UNAVAILABLE" };
}

export async function verifyStorePurchase(submission, env) {
  if (!submission || env?.STORE_VERIFICATION_ENABLED !== "true") {
    return { verified: false, reason: "STORE_VERIFICATION_DISABLED" };
  }
  if (!PLATFORMS.has(submission.platform)) return { verified: false, reason: "STORE_PLATFORM_UNSUPPORTED" };
  // An operator flag is necessary but never sufficient. These sealed providers
  // reject until real provider verification is implemented and independently reviewed.
  return submission.platform === "google"
    ? verifyGooglePurchase(submission, env)
    : verifyApplePurchase(submission, env);
}
