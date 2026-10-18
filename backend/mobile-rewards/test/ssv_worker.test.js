import test from "node:test";
import assert from "node:assert/strict";
import { createHmac, generateKeyPairSync, sign } from "node:crypto";
import { __test, handleRequest } from "../src/index.js";

const NOW = 1_800_000_000_000;
const KEY_ID = "947321";
const AD_UNIT = "ca-app-pub-1234567890123456/1234567890";
const NONCE = "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a471";
const USER = "account-subject-1";
const { privateKey, publicKey } = generateKeyPairSync("ec", { namedCurve: "prime256v1" });
const publicKeyBase64 = publicKey.export({ type: "spki", format: "der" }).toString("base64");

function row(placement = "energy_20", adUnit = AD_UNIT) {
  return {
    nonce: NONCE, user_id: USER, placement_id: placement, platform: "android",
    ad_unit: adUnit, reward_item: "energy", reward_amount: 20,
    state: "pending", expires_at: NOW + 900_000, transaction_id: null,
  };
}

class FakeD1 {
  constructor(initialClaim = row()) {
    this.claims = new Map(initialClaim ? [[initialClaim.nonce, structuredClone(initialClaim)]] : []);
    this.ledger = new Map();
  }
  prepare(sql) { return new FakeStatement(this, sql); }
  async batch(statements) {
    const claims = structuredClone([...this.claims.entries()]);
    const ledger = structuredClone([...this.ledger.entries()]);
    try {
      for (const statement of statements) await statement.run();
    } catch (error) {
      this.claims = new Map(claims);
      this.ledger = new Map(ledger);
      throw error;
    }
  }
}

class FakeStatement {
  constructor(db, sql) { this.db = db; this.sql = sql; this.values = []; }
  bind(...values) { this.values = values; return this; }
  async first() {
    if (this.sql.includes("FROM reward_ledger")) return structuredClone(this.db.ledger.get(this.values[0]) || null);
    if (this.sql.includes("FROM ad_claims WHERE nonce=? AND user_id=?")) {
      const [nonce, userId, now] = this.values;
      const item = this.db.claims.get(nonce);
      return item && item.user_id === userId && item.expires_at >= now
        ? { nonce, placement_id: item.placement_id, state: item.state, expires_at: item.expires_at, transaction_id: item.transaction_id }
        : null;
    }
    if (this.sql.includes("FROM ad_claims WHERE nonce=?")) return structuredClone(this.db.claims.get(this.values[0]) || null);
    return null;
  }
  async run() {
    if (this.sql.includes("INSERT INTO ad_claims")) {
      const [nonce, userId, placement, platform, adUnit, item, amount, expiresAt, createdAt] = this.values;
      if (this.db.claims.has(nonce)) throw new Error("UNIQUE_CONSTRAINT");
      this.db.claims.set(nonce, { nonce, user_id: userId, placement_id: placement, platform,
        ad_unit: adUnit, reward_item: item, reward_amount: amount, state: "pending",
        expires_at: expiresAt, created_at: createdAt, transaction_id: null });
    } else if (this.sql.includes("INSERT INTO reward_ledger")) {
      const [transactionId, grantedAt, nonce, userId, placement, platform, adUnit, item, amount, now] = this.values;
      const claim = this.db.claims.get(nonce);
      if (claim && claim.user_id === userId && claim.placement_id === placement && claim.platform === platform
        && claim.ad_unit === adUnit && claim.reward_item === item && claim.reward_amount === amount
        && claim.state === "pending" && claim.expires_at >= now && !this.db.ledger.has(transactionId)
        && ![...this.db.ledger.values()].some((entry) => entry.nonce === nonce)) {
        this.db.ledger.set(transactionId, { transaction_id: transactionId, nonce, user_id: userId,
          placement_id: placement, reward_item: item, reward_amount: amount, granted_at: grantedAt });
      }
    } else if (this.sql.includes("UPDATE ad_claims SET state='settled'")) {
      const [transactionId, settledAt, nonce, userId, ledgerTransaction, ledgerNonce] = this.values;
      const claim = this.db.claims.get(nonce);
      const ledger = this.db.ledger.get(ledgerTransaction);
      if (claim && claim.user_id === userId && claim.state === "pending" && ledger?.nonce === ledgerNonce) {
        claim.state = "settled";
        claim.transaction_id = transactionId;
        claim.settled_at = settledAt;
      }
    }
  }
}

function env(db = new FakeD1(), placement = "energy_20") {
  return {
    DB: db,
    AD_REWARD_POLICY_JSON: JSON.stringify({
      [placement]: { android: { ad_unit: AD_UNIT, reward_item: "energy", reward_amount: 20 } },
    }),
  };
}

function signedUrl({ nonce = NONCE, userId = USER, transactionId = "transaction-001", adUnit = AD_UNIT,
  rewardItem = "energy", rewardAmount = "20", timestamp = NOW } = {}) {
  const signed = [
    ["ad_network", "test-network"], ["ad_unit", adUnit], ["custom_data", nonce],
    ["reward_amount", rewardAmount], ["reward_item", rewardItem], ["timestamp", String(timestamp)],
    ["transaction_id", transactionId], ["user_id", userId],
  ].map(([key, value]) => `${key}=${encodeURIComponent(value)}`).join("&");
  const signature = sign("sha256", Buffer.from(signed, "utf8"), { key: privateKey, dsaEncoding: "der" }).toString("base64url");
  return `https://worker.test/v1/ads/ssv?${signed}&signature=${signature}&key_id=${KEY_ID}`;
}

function keyFetcher() {
  return async (url) => {
    assert.equal(url, "https://www.gstatic.com/admob/reward/verifier-keys.json");
    return new Response(JSON.stringify({ keys: [{ keyId: Number(KEY_ID), base64: publicKeyBase64 }] }), { status: 200 });
  };
}

function jwt({ secret = "test-secret", sub = USER, iss = "beach-cocktails", aud = "mobile-app", iat = NOW / 1000, exp = NOW / 1000 + 600 } = {}) {
  const encode = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
  const header = encode({ alg: "HS256", typ: "JWT" });
  const payload = encode({ sub, iss, aud, iat, exp });
  const signature = createHmac("sha256", secret).update(`${header}.${payload}`).digest("base64url");
  return `${header}.${payload}.${signature}`;
}

test("verifies a genuine ECDSA signature and settles an expected placement once", async () => {
  __test.clearGoogleKeyCache();
  const db = new FakeD1();
  const response = await handleRequest(new Request(signedUrl()), env(db), { now: NOW, fetcher: keyFetcher() });
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { ok: true, duplicate: false, transaction_id: "transaction-001" });
  assert.equal(db.ledger.size, 1);
  assert.equal(db.claims.get(NONCE).state, "settled");
});

test("Google retries of the same signed transaction are idempotent", async () => {
  __test.clearGoogleKeyCache();
  const db = new FakeD1();
  const url = signedUrl();
  await handleRequest(new Request(url), env(db), { now: NOW, fetcher: keyFetcher() });
  const response = await handleRequest(new Request(url), env(db), { now: NOW, fetcher: keyFetcher() });
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { ok: true, duplicate: true, transaction_id: "transaction-001" });
  assert.equal(db.ledger.size, 1);
});

test("rejects altered signed bytes and invalid signatures", async () => {
  __test.clearGoogleKeyCache();
  const db = new FakeD1();
  const altered = signedUrl().replace("reward_amount=20", "reward_amount=21");
  const response = await handleRequest(new Request(altered), env(db), { now: NOW, fetcher: keyFetcher() });
  assert.equal(response.status, 400);
  assert.equal((await response.json()).reason, "INVALID_SIGNATURE");
  assert.equal(db.ledger.size, 0);
});

test("rejects a validly signed callback for the wrong user, unit, reward, or expired claim", async (t) => {
  const scenarios = [
    ["wrong account", () => signedUrl({ userId: "another-user" }), () => new FakeD1()],
    ["wrong unit", () => signedUrl({ adUnit: "ca-app-pub-1234567890123456/9999999999" }), () => new FakeD1()],
    ["wrong reward", () => signedUrl({ rewardItem: "coins" }), () => new FakeD1()],
    ["expired claim", () => signedUrl(), () => new FakeD1({ ...row(), expires_at: NOW - 1 })],
  ];
  for (const [name, url, makeDb] of scenarios) await t.test(name, async () => {
    __test.clearGoogleKeyCache();
    const db = makeDb();
    const response = await handleRequest(new Request(url()), env(db), { now: NOW, fetcher: keyFetcher() });
    assert.equal(response.status, 400);
    assert.equal(db.ledger.size, 0);
  });
});

test("rejects transaction replay bound to a second claim and never double-grants", async () => {
  __test.clearGoogleKeyCache();
  const db = new FakeD1();
  const first = signedUrl();
  await handleRequest(new Request(first), env(db), { now: NOW, fetcher: keyFetcher() });
  const otherNonce = "53f8b44f-70b7-4e9e-b40b-11cf28c4714b";
  db.claims.set(otherNonce, { ...row(), nonce: otherNonce, state: "pending" });
  __test.clearGoogleKeyCache();
  const replay = await handleRequest(new Request(signedUrl({ nonce: otherNonce })), env(db), { now: NOW, fetcher: keyFetcher() });
  assert.equal(replay.status, 400);
  assert.equal((await replay.json()).error, "SSV_TRANSACTION_REPLAYED");
  assert.equal(db.ledger.size, 1);
});

test("client callbacks cannot mint rewards or call the SSV settlement endpoint", async () => {
  const db = new FakeD1();
  const forged = await handleRequest(new Request("https://worker.test/v1/ads/reward", {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ nonce: NONCE, transaction_id: "fake", verified: true, reward_amount: 20 }),
  }), env(db), { now: NOW, fetcher: keyFetcher() });
  const wrongMethod = await handleRequest(new Request("https://worker.test/v1/ads/ssv", { method: "POST" }), env(db), { now: NOW, fetcher: keyFetcher() });
  assert.equal(forged.status, 404);
  assert.equal(wrongMethod.status, 404);
  assert.equal(db.ledger.size, 0);
});

test("authenticated claims reject missing authentication and unconfigured reward policies", async () => {
  const db = new FakeD1(null);
  const request = new Request("https://worker.test/v1/ads/claims", {
    method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ placement: "energy_20", platform: "android" }),
  });
  const unauthenticated = await handleRequest(request, env(db), { now: NOW });
  assert.equal(unauthenticated.status, 401);
  const invalidPolicy = await handleRequest(new Request(request.url, {
    method: "POST", headers: request.headers, body: request.clone ? await request.clone().text() : "{}",
  }), { ...env(db), APP_JWT_SECRET: "secret", APP_JWT_ISSUER: "issuer", APP_JWT_AUDIENCE: "audience" }, { now: NOW });
  assert.equal(invalidPolicy.status, 401);
});

test("valid app JWT creates an account-bound server reward claim and status is private", async () => {
  const db = new FakeD1(null);
  const configuration = { ...env(db), APP_JWT_SECRET: "test-secret", APP_JWT_ISSUER: "beach-cocktails", APP_JWT_AUDIENCE: "mobile-app" };
  const created = await handleRequest(new Request("https://worker.test/v1/ads/claims", {
    method: "POST", headers: { authorization: `Bearer ${jwt()}`, "content-type": "application/json" },
    body: JSON.stringify({ placement: "energy_20", platform: "android", reward_amount: 999999 }),
  }), configuration, { now: NOW });
  assert.equal(created.status, 200);
  const claim = await created.json();
  assert.equal(claim.user_id, USER);
  assert.equal(claim.ad_unit, AD_UNIT);
  assert.equal(claim.reward_item, "energy");
  assert.equal(claim.reward_amount, 20, "client-supplied reward amount must be ignored");
  assert.equal(db.claims.get(claim.nonce).state, "pending");
  const status = await handleRequest(new Request(`https://worker.test/v1/ads/claims/${claim.nonce}`, {
    headers: { authorization: `Bearer ${jwt()}` },
  }), configuration, { now: NOW });
  assert.equal(status.status, 200);
  assert.equal((await status.json()).state, "pending");
  const privateStatus = await handleRequest(new Request(`https://worker.test/v1/ads/claims/${claim.nonce}`, {
    headers: { authorization: `Bearer ${jwt({ sub: "different-user" })}` },
  }), configuration, { now: NOW });
  assert.equal(privateStatus.status, 404);
});

test("expired and incorrectly signed app JWTs cannot create reward claims", async () => {
  const db = new FakeD1(null);
  const configuration = { ...env(db), APP_JWT_SECRET: "test-secret", APP_JWT_ISSUER: "beach-cocktails", APP_JWT_AUDIENCE: "mobile-app" };
  for (const token of [jwt({ exp: NOW / 1000 - 1 }), jwt({ secret: "wrong-secret" }),
    jwt({ exp: NOW / 1000 + 3_600 + 1 }), jwt({ iat: null })]) {
    const response = await handleRequest(new Request("https://worker.test/v1/ads/claims", {
      method: "POST", headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
      body: JSON.stringify({ placement: "energy_20", platform: "android" }),
    }), configuration, { now: NOW });
    assert.equal(response.status, 401);
  }
  assert.equal(db.claims.size, 0);
});

test("store purchase and restore assertions remain no-grant without a trusted verifier", async () => {
  for (const [method, path] of [["POST", "/v1/store/verify"], ["GET", "/v1/store/restore"]]) {
    const response = await handleRequest(new Request(`https://worker.test${path}`, { method }), {});
    assert.equal(response.status, 503);
    assert.deepEqual(await response.json(), { error: "TRUSTED_STORE_VERIFIER_NOT_CONFIGURED", grant: false });
  }
});

test("signature parser rejects duplicates and key ordering violations", () => {
  assert.throws(() => __test.parseRawQuery("a=b&signature=abc&signature=def&key_id=1"), /DUPLICATE_PARAMETER/);
  assert.throws(() => __test.parseRawQuery("a=b&key_id=1&signature=abc"), /SIGNATURE_FIELDS_ORDER/);
});
