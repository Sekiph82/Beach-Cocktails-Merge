import test from "node:test";
import assert from "node:assert/strict";
import { createHmac, generateKeyPairSync, sign } from "node:crypto";
import { __test, handleRequest } from "../src/index.js";

const NOW = 1_800_000_000_000;
const KEY_ID = "947321";
const AD_UNIT = "ca-app-pub-1234567890123456/1234567890";
const SSV_AD_UNIT = "1234567890";
const MAX_QUEUE = 50;
const NONCE = "d78a40f3-4c8f-4c7d-a5b3-3a12ed43a471";
const USER = "account-subject-1";
const { privateKey, publicKey } = generateKeyPairSync("ec", { namedCurve: "prime256v1" });
const publicKeyBase64 = publicKey.export({ type: "spki", format: "der" }).toString("base64");

function row(placement = "energy_20", adUnit = AD_UNIT) {
  return {
    nonce: NONCE, user_id: USER, placement_id: placement, platform: "android",
    ad_unit: adUnit, ssv_ad_unit: SSV_AD_UNIT, reward_item: "energy", reward_amount: 20, client_transaction_id: "",
    state: "pending", expires_at: NOW + 900_000, transaction_id: null,
  };
}

class FakeD1 {
  constructor(initialClaim = row()) {
    this.claims = new Map(initialClaim ? [[initialClaim.nonce, structuredClone(initialClaim)]] : []);
    this.ledger = new Map();
    this.deliveryAcks = new Map();
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
    if (this.sql.includes("FROM reward_delivery_ack")) {
      const [transactionId, userId] = this.values;
      const ack = this.db.deliveryAcks.get(transactionId);
      return ack?.user_id === userId ? { transaction_id: transactionId } : null;
    }
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
      const [nonce, userId, placement, platform, adUnit, ssvAdUnit, item, amount, clientTransactionId, expiresAt, createdAt] = this.values;
      if (this.db.claims.has(nonce)) throw new Error("UNIQUE_CONSTRAINT");
      const pendingLedger = [...this.db.ledger.values()].filter((entry) => entry.user_id === userId && !this.db.deliveryAcks.has(entry.transaction_id)).length;
      const activeClaims = [...this.db.claims.values()].filter((entry) => entry.user_id === userId && entry.state === "pending" && entry.expires_at >= this.values[14]).length;
      if (pendingLedger + activeClaims >= MAX_QUEUE) return { meta: { changes: 0 } };
      this.db.claims.set(nonce, { nonce, user_id: userId, placement_id: placement, platform,
        ad_unit: adUnit, ssv_ad_unit: ssvAdUnit, reward_item: item, reward_amount: amount, client_transaction_id: clientTransactionId, state: "pending",
        expires_at: expiresAt, created_at: createdAt, transaction_id: null });
      return { meta: { changes: 1 } };
    } else if (this.sql.includes("INSERT INTO reward_delivery_ack")) {
      const [acknowledgedAt, transactionId, userId] = this.values;
      const ledger = this.db.ledger.get(transactionId);
      if (ledger?.user_id === userId && !this.db.deliveryAcks.has(transactionId)) {
        this.db.deliveryAcks.set(transactionId, { transaction_id: transactionId, user_id: userId, acknowledged_at: acknowledgedAt });
        return { meta: { changes: 1 } };
      }
      return { meta: { changes: 0 } };
    } else if (this.sql.includes("INSERT INTO reward_ledger")) {
      const [transactionId, grantedAt, nonce, userId, placement, platform, adUnit, ssvAdUnit, item, amount, now] = this.values;
      const claim = this.db.claims.get(nonce);
      if (claim && claim.user_id === userId && claim.placement_id === placement && claim.platform === platform
        && claim.ad_unit === adUnit && claim.ssv_ad_unit === ssvAdUnit && claim.reward_item === item && claim.reward_amount === amount
        && claim.state === "pending" && claim.expires_at >= now && !this.db.ledger.has(transactionId)
        && (!claim.client_transaction_id || ![...this.db.ledger.values()].some((entry) => entry.user_id === userId && entry.client_transaction_id === claim.client_transaction_id))
        && ![...this.db.ledger.values()].some((entry) => entry.nonce === nonce)) {
        this.db.ledger.set(transactionId, { transaction_id: transactionId, nonce, user_id: userId,
          placement_id: placement, client_transaction_id: claim.client_transaction_id, reward_item: item, reward_amount: amount, granted_at: grantedAt });
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
  async all() {
    if (!this.sql.includes("FROM reward_ledger")) return { results: [] };
    const [userId] = this.values;
    return { results: [...this.db.ledger.values()]
      .filter((entry) => entry.user_id === userId && !this.db.deliveryAcks.has(entry.transaction_id))
      .map((entry) => structuredClone(entry)) };
  }
}

function env(db = new FakeD1(), placement = "energy_20") {
  return {
    DB: db,
    AD_REWARD_POLICY_JSON: JSON.stringify({
      [placement]: { android: { ad_unit: AD_UNIT, ssv_ad_unit: SSV_AD_UNIT, reward_item: "energy", reward_amount: 20 } },
    }),
  };
}

function signedUrl({ nonce = NONCE, userId = USER, includeUserId = true, transactionId = "transaction-001", adUnit = SSV_AD_UNIT,
  rewardItem = "energy", rewardAmount = "20", timestamp = NOW } = {}) {
  const entries = [
    ["ad_network", "test-network"], ["ad_unit", adUnit], ["custom_data", nonce],
    ["reward_amount", rewardAmount], ["reward_item", rewardItem], ["timestamp", String(timestamp)],
    ["transaction_id", transactionId],
  ];
  if (includeUserId) entries.push(["user_id", userId]);
  const signed = entries.map(([key, value]) => `${key}=${encodeURIComponent(value)}`).join("&");
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

test("signed callback missing user_id is rejected; matching subject and nonce settle into that user's ledger", async () => {
  __test.clearGoogleKeyCache();
  const missingDb = new FakeD1();
  const missing = await handleRequest(new Request(signedUrl({ includeUserId: false })), env(missingDb), { now: NOW, fetcher: keyFetcher() });
  assert.equal(missing.status, 400);
  assert.equal((await missing.json()).error, "SSV_REQUIRED_FIELDS_MISSING");
  assert.equal(missingDb.ledger.size, 0);

  __test.clearGoogleKeyCache();
  const validDb = new FakeD1();
  const valid = await handleRequest(new Request(signedUrl()), env(validDb), { now: NOW, fetcher: keyFetcher() });
  assert.equal(valid.status, 200);
  assert.equal(validDb.ledger.get("transaction-001").user_id, USER);
  assert.equal(validDb.ledger.get("transaction-001").nonce, NONCE);
  assert.equal(validDb.ledger.get("transaction-001").client_transaction_id, "");
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
    ["wrong numeric SSV unit", () => signedUrl({ adUnit: "9999999999" }), () => new FakeD1()],
    ["full client ad-unit string is not the documented SSV callback value", () => signedUrl({ adUnit: AD_UNIT }), () => new FakeD1()],
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
    body: JSON.stringify({ placement: "energy_20", platform: "android", reward_amount: 999999, consent_granted: true, consent_state: "UMP_OBTAINED" }),
  }), configuration, { now: NOW });
  assert.equal(created.status, 200);
  const claim = await created.json();
  assert.equal(claim.user_id, USER);
  assert.equal(claim.ad_unit, AD_UNIT);
  assert.equal(claim.reward_item, "energy");
  assert.equal(claim.reward_amount, 20, "client-supplied reward amount must be ignored");
  assert.equal(claim.client_transaction_id, "");
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
      body: JSON.stringify({ placement: "energy_20", platform: "android", consent_granted: true, consent_state: "UMP_OBTAINED" }),
    }), configuration, { now: NOW });
    assert.equal(response.status, 401);
  }
  assert.equal(db.claims.size, 0);
});

test("daily-slot claims bind the business UTC slot transaction before an ad is requested", async () => {
  const db = new FakeD1(null);
  const dailyPolicy = { daily_slot_2: { android: { ad_unit: AD_UNIT, ssv_ad_unit: SSV_AD_UNIT, reward_item: "energy", reward_amount: 20 } } };
  const configuration = { ...env(db), AD_REWARD_POLICY_JSON: JSON.stringify(dailyPolicy), APP_JWT_SECRET: "test-secret", APP_JWT_ISSUER: "beach-cocktails", APP_JWT_AUDIENCE: "mobile-app" };
  const today = new Date(NOW).toISOString().slice(0, 10);
  const send = (clientTransactionId) => handleRequest(new Request("https://worker.test/v1/ads/claims", {
    method: "POST", headers: { authorization: `Bearer ${jwt()}`, "content-type": "application/json" },
    body: JSON.stringify({ placement: "daily_slot_2", platform: "android", consent_granted: true,
      consent_state: "UMP_OBTAINED", ...(clientTransactionId ? { client_transaction_id: clientTransactionId } : {}) }),
  }), configuration, { now: NOW });
  assert.equal((await send("")).status, 400);
  assert.equal((await send(`daily:${today}:3`)).status, 400);
  const response = await send(`daily:${today}:2`);
  assert.equal(response.status, 200);
  const claim = await response.json();
  assert.equal(claim.client_transaction_id, `daily:${today}:2`);
  assert.equal(claim.placement_id, "daily_slot_2");
  assert.equal(db.claims.get(claim.nonce).client_transaction_id, `daily:${today}:2`);
});

test("consent-gated claim and verified reward delivery survive a game crash before server acknowledgement", async () => {
  __test.clearGoogleKeyCache();
  const db = new FakeD1();
  const configuration = { ...env(db), APP_JWT_SECRET: "test-secret", APP_JWT_ISSUER: "beach-cocktails", APP_JWT_AUDIENCE: "mobile-app" };
  const missingConsent = await handleRequest(new Request("https://worker.test/v1/ads/claims", {
    method: "POST", headers: { authorization: `Bearer ${jwt()}`, "content-type": "application/json" },
    body: JSON.stringify({ placement: "energy_20", platform: "android" }),
  }), configuration, { now: NOW });
  assert.equal(missingConsent.status, 400);
  const denied = await handleRequest(new Request("https://worker.test/v1/ads/claims", {
    method: "POST", headers: { authorization: `Bearer ${jwt()}`, "content-type": "application/json" },
    body: JSON.stringify({ placement: "energy_20", platform: "android", consent_granted: false }),
  }), configuration, { now: NOW });
  assert.equal(denied.status, 400);

  const ssv = await handleRequest(new Request(signedUrl()), configuration, { now: NOW, fetcher: keyFetcher() });
  assert.equal(ssv.status, 200);
  const auth = { authorization: `Bearer ${jwt()}` };
  const pendingRequest = () => new Request("https://worker.test/v1/ads/rewards/pending", { headers: auth });
  const pending = await handleRequest(pendingRequest(), configuration, { now: NOW });
  const { rewards } = await pending.json();
  assert.equal(rewards.length, 1);
  const reward = rewards[0];
  assert.equal(reward.user_id, USER, "pending delivery binds the verified reward row to the authenticated subject");
  assert.equal(reward.client_transaction_id, "");

  // Explicit TEST-ONLY durable game-economy fixture: transaction IDs are its
  // grant_reward keys, and save data survives recreation of the process object.
  let save = { balance: 0, transactions: new Set() };
  const applyReward = (snapshot, entry) => {
    if (!snapshot.transactions.has(entry.transaction_id)) {
      snapshot.balance += entry.reward_amount;
      snapshot.transactions.add(entry.transaction_id);
    }
  };
  applyReward(save, reward);
  const reopenedGame = save;
  applyReward(reopenedGame, reward); // crash before ACK; retry after reopen.
  assert.equal(reopenedGame.balance, 20);
  assert.equal(reopenedGame.transactions.size, 1);

  const wrongUserAck = await handleRequest(new Request(`https://worker.test/v1/ads/rewards/${reward.transaction_id}/ack`, {
    method: "POST", headers: { authorization: `Bearer ${jwt({ sub: "different-user" })}` },
  }), configuration, { now: NOW });
  assert.equal(wrongUserAck.status, 404);
  assert.equal(db.deliveryAcks.size, 0);
  const ack = await handleRequest(new Request(`https://worker.test/v1/ads/rewards/${reward.transaction_id}/ack`, {
    method: "POST", headers: auth,
  }), configuration, { now: NOW });
  assert.equal(ack.status, 200);
  const duplicateAck = await handleRequest(new Request(`https://worker.test/v1/ads/rewards/${reward.transaction_id}/ack`, {
    method: "POST", headers: auth,
  }), configuration, { now: NOW });
  assert.deepEqual(await duplicateAck.json(), { ok: true, transaction_id: reward.transaction_id, duplicate: true });
  const afterAck = await handleRequest(pendingRequest(), configuration, { now: NOW });
  assert.deepEqual((await afterAck.json()).rewards, []);
  assert.equal(db.deliveryAcks.size, 1);
  assert.equal(reopenedGame.balance, 20);
});

test("worker caps active claims plus unacknowledged rewards to prevent an unbounded pending queue", async () => {
  const db = new FakeD1(null);
  for (let i = 0; i < 50; i++) {
    db.ledger.set(`queued-${i}`, { transaction_id: `queued-${i}`, user_id: USER, client_transaction_id: "", nonce: `n-${i}` });
  }
  const configuration = { ...env(db), APP_JWT_SECRET: "test-secret", APP_JWT_ISSUER: "beach-cocktails", APP_JWT_AUDIENCE: "mobile-app" };
  const response = await handleRequest(new Request("https://worker.test/v1/ads/claims", {
    method: "POST", headers: { authorization: `Bearer ${jwt()}`, "content-type": "application/json" },
    body: JSON.stringify({ placement: "energy_20", platform: "android", consent_granted: true, consent_state: "UMP_OBTAINED" }),
  }), configuration, { now: NOW });
  assert.equal(response.status, 429);
  assert.equal((await response.json()).error, "REWARD_QUEUE_FULL");
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
