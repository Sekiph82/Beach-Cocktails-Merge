const GOOGLE_SSV_KEYS_URL = "https://www.gstatic.com/admob/reward/verifier-keys.json";
const MAX_SSV_QUERY_BYTES = 8192;
const CLAIM_TTL_MS = 15 * 60 * 1000;
const MAX_CALLBACK_AGE_MS = 24 * 60 * 60 * 1000;
const MAX_FUTURE_SKEW_MS = 5 * 60 * 1000;
const GOOGLE_KEY_CACHE_MS = 24 * 60 * 60 * 1000;

let cachedGoogleKeys = null;
let cachedGoogleKeysAt = 0;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" },
  });
}

function decodeBase64Url(value) {
  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
  const binary = atob(padded);
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

function decodeBase64(value) {
  const binary = atob(value);
  return Uint8Array.from(binary, (character) => character.charCodeAt(0));
}

function parseRawQuery(rawQuery) {
  const pieces = rawQuery.split("&");
  if (pieces.length < 3 || pieces.at(-2)?.startsWith("signature=") !== true || pieces.at(-1)?.startsWith("key_id=") !== true) {
    throw new Error("SIGNATURE_FIELDS_ORDER");
  }
  const fields = new Map();
  for (const piece of pieces) {
    const split = piece.indexOf("=");
    if (split <= 0) throw new Error("MALFORMED_QUERY");
    const rawName = piece.slice(0, split);
    if (fields.has(rawName)) throw new Error("DUPLICATE_PARAMETER");
    fields.set(rawName, piece.slice(split + 1));
  }
  const decode = (name) => {
    const raw = fields.get(name);
    if (raw === undefined) return "";
    try {
      return decodeURIComponent(raw.replace(/\+/g, "%20"));
    } catch {
      throw new Error("MALFORMED_ENCODING");
    }
  };
  return {
    signedBytes: new TextEncoder().encode(pieces.slice(0, -2).join("&")),
    signature: decode("signature"),
    keyId: decode("key_id"),
    get: decode,
  };
}

function derEcdsaToP1363(der, coordinateBytes = 32) {
  if (der.length < 8 || der[0] !== 0x30) throw new Error("INVALID_DER_SIGNATURE");
  let offset = 2;
  if (der[1] & 0x80) {
    const lengthBytes = der[1] & 0x7f;
    if (lengthBytes < 1 || lengthBytes > 2 || der.length < 2 + lengthBytes) throw new Error("INVALID_DER_SIGNATURE");
    offset = 2 + lengthBytes;
  }
  const readInteger = () => {
    if (der[offset++] !== 0x02 || offset >= der.length) throw new Error("INVALID_DER_SIGNATURE");
    const length = der[offset++];
    if (length < 1 || offset + length > der.length) throw new Error("INVALID_DER_SIGNATURE");
    let value = der.slice(offset, offset + length);
    offset += length;
    while (value.length > coordinateBytes && value[0] === 0) value = value.slice(1);
    if (value.length > coordinateBytes) throw new Error("INVALID_DER_SIGNATURE");
    const padded = new Uint8Array(coordinateBytes);
    padded.set(value, coordinateBytes - value.length);
    return padded;
  };
  const r = readInteger();
  const s = readInteger();
  if (offset !== der.length) throw new Error("INVALID_DER_SIGNATURE");
  const raw = new Uint8Array(coordinateBytes * 2);
  raw.set(r, 0);
  raw.set(s, coordinateBytes);
  return raw;
}

async function verifySsvWithKeys(rawQuery, keys) {
  const parsed = parseRawQuery(rawQuery);
  const keyId = parsed.keyId;
  if (!/^\d{1,20}$/.test(keyId)) throw new Error("INVALID_KEY_ID");
  const row = keys.find((entry) => String(entry.keyId) === keyId && typeof entry.base64 === "string");
  if (!row) throw new Error("UNKNOWN_KEY_ID");
  const key = await crypto.subtle.importKey(
    "spki",
    decodeBase64(row.base64),
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["verify"],
  );
  const der = decodeBase64Url(parsed.signature);
  const signature = derEcdsaToP1363(der);
  const valid = await crypto.subtle.verify({ name: "ECDSA", hash: "SHA-256" }, key, signature, parsed.signedBytes);
  if (!valid) throw new Error("INVALID_SIGNATURE");
  return parsed;
}

async function getGoogleKeys(fetcher = fetch, now = Date.now()) {
  if (cachedGoogleKeys && now - cachedGoogleKeysAt < GOOGLE_KEY_CACHE_MS) return cachedGoogleKeys;
  const response = await fetcher(GOOGLE_SSV_KEYS_URL, { cf: { cacheTtl: 0 } });
  if (!response.ok) throw new Error("GOOGLE_KEYS_UNAVAILABLE");
  const payload = await response.json();
  if (!Array.isArray(payload.keys) || payload.keys.length === 0) throw new Error("GOOGLE_KEYS_INVALID");
  cachedGoogleKeys = payload.keys;
  cachedGoogleKeysAt = now;
  return cachedGoogleKeys;
}

async function verifySsv(rawQuery, fetcher = fetch, now = Date.now()) {
  let keys = await getGoogleKeys(fetcher, now);
  try {
    return await verifySsvWithKeys(rawQuery, keys);
  } catch (error) {
    if (error.message !== "UNKNOWN_KEY_ID") throw error;
    // A new Google key may have rotated in. Force one refresh, but never cache
    // verifier keys for longer than Google's documented 24-hour maximum.
    cachedGoogleKeysAt = 0;
    keys = await getGoogleKeys(fetcher, now);
    return verifySsvWithKeys(rawQuery, keys);
  }
}

function decodeJsonPart(value) {
  return JSON.parse(new TextDecoder().decode(decodeBase64Url(value)));
}

async function authenticate(request, env, now = Date.now()) {
  const header = request.headers.get("authorization") || "";
  const match = /^Bearer ([A-Za-z0-9._~-]+)$/.exec(header);
  if (!match || !env.APP_JWT_SECRET || !env.APP_JWT_ISSUER || !env.APP_JWT_AUDIENCE) return null;
  const [encodedHeader, encodedPayload, encodedSignature, extra] = match[1].split(".");
  if (!encodedHeader || !encodedPayload || !encodedSignature || extra !== undefined) return null;
  try {
    const jwtHeader = decodeJsonPart(encodedHeader);
    const claims = decodeJsonPart(encodedPayload);
    if (jwtHeader.alg !== "HS256" || typeof claims.sub !== "string" || claims.sub.length < 1 || claims.sub.length > 128) return null;
    if (claims.iss !== env.APP_JWT_ISSUER || claims.aud !== env.APP_JWT_AUDIENCE) return null;
    if (!Number.isInteger(claims.iat) || !Number.isInteger(claims.exp) || claims.exp * 1000 <= now
      || claims.exp <= claims.iat || claims.exp - claims.iat > 60 * 60) return null;
    if (claims.nbf !== undefined && (!Number.isInteger(claims.nbf) || claims.nbf * 1000 > now + MAX_FUTURE_SKEW_MS)) return null;
    if (claims.iat * 1000 > now + MAX_FUTURE_SKEW_MS || now - claims.iat * 1000 > 60 * 60 * 1000) return null;
    const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(env.APP_JWT_SECRET), { name: "HMAC", hash: "SHA-256" }, false, ["verify"]);
    const data = new TextEncoder().encode(`${encodedHeader}.${encodedPayload}`);
    const valid = await crypto.subtle.verify("HMAC", key, decodeBase64Url(encodedSignature), data);
    return valid ? claims : null;
  } catch {
    return null;
  }
}

function parseRewardPolicy(env) {
  try {
    const policy = JSON.parse(env.AD_REWARD_POLICY_JSON || "{}");
    return policy && typeof policy === "object" && !Array.isArray(policy) ? policy : {};
  } catch {
    return {};
  }
}

class D1RewardRepository {
  constructor(db) { this.db = db; }

  async createClaim(claim) {
    await this.db.prepare(`INSERT INTO ad_claims
      (nonce,user_id,placement_id,platform,ad_unit,reward_item,reward_amount,state,expires_at,created_at)
      VALUES(?,?,?,?,?,?,?,'pending',?,?)`)
      .bind(claim.nonce, claim.userId, claim.placement, claim.platform, claim.adUnit,
        claim.rewardItem, claim.rewardAmount, claim.expiresAt, claim.createdAt).run();
  }

  async getClaim(nonce) {
    return this.db.prepare(`SELECT nonce,user_id,placement_id,platform,ad_unit,reward_item,reward_amount,state,expires_at,transaction_id
      FROM ad_claims WHERE nonce=?`).bind(nonce).first();
  }

  async getLedger(transactionId) {
    return this.db.prepare(`SELECT transaction_id,nonce,user_id,placement_id,reward_item,reward_amount
      FROM reward_ledger WHERE transaction_id=?`).bind(transactionId).first();
  }

  async getUserClaim(nonce, userId, now) {
    return this.db.prepare(`SELECT nonce,placement_id,state,expires_at,transaction_id
      FROM ad_claims WHERE nonce=? AND user_id=? AND expires_at>=?`).bind(nonce, userId, now).first();
  }

  async expireClaim(nonce, now) {
    await this.db.prepare(`UPDATE ad_claims SET state='expired' WHERE nonce=? AND state='pending' AND expires_at<?`).bind(nonce, now).run();
  }

  async settleAtomically(fields, now) {
    await this.db.batch([
      this.db.prepare(`INSERT INTO reward_ledger(transaction_id,nonce,user_id,placement_id,reward_item,reward_amount,granted_at)
        SELECT ?,nonce,user_id,placement_id,reward_item,reward_amount,?
        FROM ad_claims WHERE nonce=? AND user_id=? AND placement_id=? AND platform=? AND ad_unit=?
          AND reward_item=? AND reward_amount=? AND state='pending' AND expires_at>=?
        ON CONFLICT DO NOTHING`)
        .bind(fields.transactionId, now, fields.nonce, fields.userId, fields.placement,
          fields.platform, fields.adUnit, fields.rewardItem, fields.rewardAmount, now),
      this.db.prepare(`UPDATE ad_claims SET state='settled',transaction_id=?,settled_at=?
        WHERE nonce=? AND user_id=? AND state='pending' AND EXISTS
          (SELECT 1 FROM reward_ledger WHERE transaction_id=? AND nonce=?)`)
        .bind(fields.transactionId, now, fields.nonce, fields.userId, fields.transactionId, fields.nonce),
    ]);
    return this.db.prepare(`SELECT transaction_id,nonce,user_id,placement_id,reward_item,reward_amount
      FROM reward_ledger WHERE transaction_id=?`).bind(fields.transactionId).first();
  }
}

function buildAdUnitMap(policy) {
  const result = new Map();
  for (const [placement, platformMap] of Object.entries(policy)) {
    if (!platformMap || typeof platformMap !== "object") continue;
    for (const platform of ["android", "ios"]) {
      const row = platformMap[platform];
      if (!row || typeof row !== "object") continue;
      if (typeof row.ad_unit === "string" && /^ca-app-pub-\d{16}\/\d{10}$/.test(row.ad_unit)
        && typeof row.reward_item === "string" && row.reward_item.length > 0
        && Number.isSafeInteger(row.reward_amount) && row.reward_amount > 0) {
        result.set(`${platform}:${row.ad_unit}`, { placement, platform, ...row });
      }
    }
  }
  return result;
}

async function handleCreateClaim(request, env, user, now) {
  if (!env.DB || typeof env.DB.prepare !== "function") return json({ error: "REWARD_BACKEND_UNAVAILABLE" }, 503);
  const body = await request.json().catch(() => null);
  if (!body || typeof body.placement !== "string" || !["android", "ios"].includes(body.platform)) return json({ error: "INVALID_CLAIM_REQUEST" }, 400);
  const policy = parseRewardPolicy(env);
  const row = policy[body.placement]?.[body.platform];
  if (!row || !/^ca-app-pub-\d{16}\/\d{10}$/.test(row.ad_unit || "")
    || typeof row.reward_item !== "string" || !Number.isSafeInteger(row.reward_amount) || row.reward_amount <= 0) {
    return json({ error: "PLACEMENT_NOT_CONFIGURED" }, 503);
  }
  const claim = {
    nonce: crypto.randomUUID(), userId: user.sub, placement: body.placement,
    platform: body.platform, adUnit: row.ad_unit, rewardItem: row.reward_item,
    rewardAmount: row.reward_amount, createdAt: now, expiresAt: now + CLAIM_TTL_MS,
  };
  try {
    await new D1RewardRepository(env.DB).createClaim(claim);
    return json({ nonce: claim.nonce, user_id: claim.userId, ad_unit: claim.adUnit,
      reward_item: claim.rewardItem, reward_amount: claim.rewardAmount, expires_at: claim.expiresAt });
  } catch {
    return json({ error: "CLAIM_CREATE_FAILED" }, 503);
  }
}

async function handleClaimStatus(request, env, user, nonce, now) {
  if (!env.DB || typeof env.DB.prepare !== "function") return json({ error: "REWARD_BACKEND_UNAVAILABLE" }, 503);
  if (!/^[0-9a-f-]{36}$/i.test(nonce)) return json({ error: "CLAIM_NOT_FOUND" }, 404);
  try {
    const repo = new D1RewardRepository(env.DB);
    let claim = await repo.getUserClaim(nonce, user.sub, now);
    if (!claim) {
      await repo.expireClaim(nonce, now);
      return json({ error: "CLAIM_NOT_FOUND_OR_EXPIRED" }, 404);
    }
    return json({ state: claim.state, expires_at: claim.expires_at,
      transaction_id: claim.state === "settled" ? claim.transaction_id : null });
  } catch {
    return json({ error: "CLAIM_STATUS_UNAVAILABLE" }, 503);
  }
}

async function handleSsv(request, env, fetcher, now) {
  if (!env.DB || typeof env.DB.prepare !== "function") return json({ error: "REWARD_BACKEND_UNAVAILABLE" }, 503);
  const rawQuery = new URL(request.url).search.slice(1);
  if (!rawQuery || new TextEncoder().encode(rawQuery).byteLength > MAX_SSV_QUERY_BYTES) return json({ error: "INVALID_SSV_QUERY" }, 400);
  let fields;
  try { fields = await verifySsv(rawQuery, fetcher, now); }
  catch (error) {
    if (["GOOGLE_KEYS_UNAVAILABLE", "GOOGLE_KEYS_INVALID"].includes(error.message)) return json({ error: "SIGNATURE_VERIFIER_UNAVAILABLE" }, 503);
    return json({ error: "SSV_REJECTED", reason: error.message }, 400);
  }
  const nonce = fields.get("custom_data");
  const transactionId = fields.get("transaction_id");
  const userId = fields.get("user_id");
  const adUnit = fields.get("ad_unit");
  const timestamp = Number(fields.get("timestamp"));
  if (!nonce || !transactionId || !userId || !adUnit || !Number.isSafeInteger(timestamp)) return json({ error: "SSV_REQUIRED_FIELDS_MISSING" }, 400);
  if (timestamp > now + MAX_FUTURE_SKEW_MS || now - timestamp > MAX_CALLBACK_AGE_MS) return json({ error: "SSV_CALLBACK_STALE" }, 400);
  try {
    const repo = new D1RewardRepository(env.DB);
    const existingLedger = await repo.getLedger(transactionId);
    if (existingLedger) {
      if (existingLedger.nonce === nonce && existingLedger.user_id === userId
        && existingLedger.reward_item === fields.get("reward_item")
        && String(existingLedger.reward_amount) === fields.get("reward_amount")) {
        return json({ ok: true, duplicate: true, transaction_id: transactionId });
      }
      return json({ error: "SSV_TRANSACTION_REPLAYED" }, 400);
    }
    const claim = await repo.getClaim(nonce);
    if (!claim || claim.state !== "pending" || claim.expires_at < now) return json({ error: "CLAIM_INVALID_OR_EXPIRED" }, 400);
    const configured = parseRewardPolicy(env)[claim.placement_id]?.[claim.platform];
    if (!configured || configured.ad_unit !== adUnit || claim.ad_unit !== adUnit
      || userId !== claim.user_id || userId !== fields.get("user_id")
      || fields.get("reward_item") !== claim.reward_item
      || fields.get("reward_amount") !== String(claim.reward_amount)
      || configured.reward_item !== claim.reward_item || configured.reward_amount !== claim.reward_amount) {
      return json({ error: "SSV_CLAIM_BINDING_MISMATCH" }, 400);
    }
    const ledger = await repo.settleAtomically({
      nonce, transactionId, userId, placement: claim.placement_id, platform: claim.platform,
      adUnit, rewardItem: claim.reward_item, rewardAmount: claim.reward_amount,
    }, now);
    if (!ledger || ledger.nonce !== nonce || ledger.user_id !== userId) return json({ error: "SSV_REPLAY_OR_RACE_REJECTED" }, 400);
    return json({ ok: true, duplicate: claim.state === "settled", transaction_id: transactionId });
  } catch {
    // A non-2xx response lets Google's SSV delivery retry after transient D1 issues.
    return json({ error: "SSV_SETTLEMENT_UNAVAILABLE" }, 503);
  }
}

export async function handleRequest(request, env, dependencies = {}) {
  const now = dependencies.now ?? Date.now();
  const fetcher = dependencies.fetcher ?? fetch;
  const url = new URL(request.url);
  if (request.method === "GET" && url.pathname === "/health") return json({ ok: true, service: "mobile-rewards", store_verification: "not_configured" });
  if (request.method === "GET" && url.pathname === "/v1/ads/ssv") return handleSsv(request, env, fetcher, now);
  if ((request.method === "GET" || request.method === "POST") && (url.pathname === "/v1/store/verify" || url.pathname === "/v1/store/restore")) {
    return json({ error: "TRUSTED_STORE_VERIFIER_NOT_CONFIGURED", grant: false }, 503);
  }
  if (request.method === "POST" && url.pathname === "/v1/ads/claims") {
    const user = await authenticate(request, env, now);
    return user ? handleCreateClaim(request, env, user, now) : json({ error: "AUTHENTICATION_REQUIRED" }, 401);
  }
  const match = /^\/v1\/ads\/claims\/([^/]+)$/.exec(url.pathname);
  if (request.method === "GET" && match) {
    const user = await authenticate(request, env, now);
    return user ? handleClaimStatus(request, env, user, match[1], now) : json({ error: "AUTHENTICATION_REQUIRED" }, 401);
  }
  return json({ error: "NOT_FOUND" }, 404);
}

export const __test = { parseRawQuery, derEcdsaToP1363, verifySsvWithKeys, authenticate, D1RewardRepository, buildAdUnitMap, clearGoogleKeyCache() { cachedGoogleKeys = null; cachedGoogleKeysAt = 0; } };

export default { fetch: handleRequest };
