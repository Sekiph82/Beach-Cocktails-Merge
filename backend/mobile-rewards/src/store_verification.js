// Store purchase verification is intentionally sealed until provider trust,
// owner-approved product policy, and native identity configuration exist.
// Never replace these rejecting adapters with decoded client assertions.

const PLATFORMS = new Set(["apple", "google"]);
const PRODUCT_KINDS = new Set(["consumable", "non_consumable"]);
const MAX_TOKEN_LENGTH = 16_384;
export const MAX_STORE_BODY_BYTES = 32_768;
const STORE_INPUT_KEYS = {
  google: new Set(["platform", "product_id", "purchase_token"]),
  apple: new Set(["platform", "product_id", "signed_transaction"]),
};

function scanUniqueJsonKeys(source) {
  let offset = 0;
  const whitespace = () => { while (/[\u0009\u000a\u000d\u0020]/.test(source[offset] || "")) offset++; };
  const string = () => {
    const start = offset++;
    while (offset < source.length) {
      const char = source[offset++];
      if (char === "\\") { offset++; continue; }
      if (char === '"') return JSON.parse(source.slice(start, offset));
    }
    throw new Error("INVALID_JSON_STRING");
  };
  const value = (depth) => {
    if (depth > 32) throw new Error("JSON_DEPTH_EXCEEDED");
    whitespace();
    if (source[offset] === "{") {
      offset++;
      const keys = new Set();
      whitespace();
      if (source[offset] === "}") { offset++; return; }
      while (offset < source.length) {
        whitespace();
        if (source[offset] !== '"') throw new Error("INVALID_JSON_OBJECT_KEY");
        const key = string();
        if (keys.has(key)) throw new Error("DUPLICATE_JSON_KEY");
        keys.add(key);
        whitespace();
        if (source[offset++] !== ":") throw new Error("INVALID_JSON_COLON");
        value(depth + 1);
        whitespace();
        const separator = source[offset++];
        if (separator === "}") return;
        if (separator !== ",") throw new Error("INVALID_JSON_OBJECT_SEPARATOR");
      }
      throw new Error("UNCLOSED_JSON_OBJECT");
    }
    if (source[offset] === "[") {
      offset++;
      whitespace();
      if (source[offset] === "]") { offset++; return; }
      while (offset < source.length) {
        value(depth + 1);
        whitespace();
        const separator = source[offset++];
        if (separator === "]") return;
        if (separator !== ",") throw new Error("INVALID_JSON_ARRAY_SEPARATOR");
      }
      throw new Error("UNCLOSED_JSON_ARRAY");
    }
    if (source[offset] === '"') { string(); return; }
    const start = offset;
    while (offset < source.length && !/[\u0009\u000a\u000d\u0020,\]}]/.test(source[offset])) offset++;
    if (start === offset) throw new Error("INVALID_JSON_VALUE");
  };

  value(0);
  whitespace();
  if (offset !== source.length) throw new Error("TRAILING_JSON_DATA");
}

export function parseStoreRequestBody(source) {
  if (typeof source !== "string" || source.length === 0
    || new TextEncoder().encode(source).byteLength > MAX_STORE_BODY_BYTES) return null;
  try {
    scanUniqueJsonKeys(source);
    const body = JSON.parse(source);
    return body && typeof body === "object" && !Array.isArray(body) ? body : null;
  } catch {
    return null;
  }
}

export function parseStorePolicy(raw) {
  if (typeof raw !== "string" || raw.length === 0) return null;
  let policy;
  try { policy = JSON.parse(raw); } catch { return null; }
  if (!policy || typeof policy !== "object" || Array.isArray(policy)) return null;
  const normalized = Object.create(null);
  for (const platform of PLATFORMS) {
    const entry = policy[platform];
    if (!entry || typeof entry !== "object" || Array.isArray(entry)
      || typeof entry.application_id !== "string" || entry.application_id.length < 3
      || !entry.products || typeof entry.products !== "object" || Array.isArray(entry.products)) return null;
    const products = Object.create(null);
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
  const allowedKeys = STORE_INPUT_KEYS[body.platform];
  if (Object.keys(body).some((key) => !allowedKeys.has(key))) return null;
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
