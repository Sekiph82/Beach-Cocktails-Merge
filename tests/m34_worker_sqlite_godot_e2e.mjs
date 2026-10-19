import { DatabaseSync } from "node:sqlite";
import { createHmac, generateKeyPairSync, sign } from "node:crypto";
import { createServer } from "node:http";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";
import fs from "node:fs";
import os from "node:os";
import { handleRequest, __test } from "../backend/mobile-rewards/src/index.js";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const db = new DatabaseSync(":memory:");
for (const migration of ["0001_mobile_rewards.sql", "0002_admob_ssv_unit_binding.sql"]) {
  db.exec(fs.readFileSync(path.join(projectRoot, "backend/mobile-rewards/migrations", migration), "utf8"));
}

class LocalD1Statement {
  constructor(sql) { this.sql = sql; this.values = []; }
  bind(...values) { this.values = values; return this; }
  async first() { return db.prepare(this.sql).get(...this.values) ?? null; }
  async all() { return { results: db.prepare(this.sql).all(...this.values) }; }
  async run() {
    const result = db.prepare(this.sql).run(...this.values);
    return { meta: { changes: Number(result.changes) } };
  }
}
const d1 = {
  prepare(sql) { return new LocalD1Statement(sql); },
  async batch(statements) {
    db.exec("BEGIN");
    try {
      for (const statement of statements) await statement.run();
      db.exec("COMMIT");
    } catch (error) {
      db.exec("ROLLBACK");
      throw error;
    }
  },
};

const user = "bcm-v07-isolated-e2e-user";
const secret = "local-nonshipping-e2e-secret";
const issuer = "bcm-local-test";
const audience = "bcm-local-game";
const adUnit = "ca-app-pub-1234567890123456/1234567890";
const ssvAdUnit = "1234567890";
const { privateKey, publicKey } = generateKeyPairSync("ec", { namedCurve: "prime256v1" });
const publicKeyBase64 = publicKey.export({ type: "spki", format: "der" }).toString("base64");
const env = {
  DB: d1,
  APP_JWT_SECRET: secret,
  APP_JWT_ISSUER: issuer,
  APP_JWT_AUDIENCE: audience,
  AD_REWARD_POLICY_JSON: JSON.stringify({ daily_slot_3: { android: {
    ad_unit: adUnit, ssv_ad_unit: ssvAdUnit, reward_item: "coins", reward_amount: 40,
  } } }),
};
const keyFetcher = async (url) => {
  if (url !== "https://www.gstatic.com/admob/reward/verifier-keys.json") throw new Error("unexpected key URL");
  return new Response(JSON.stringify({ keys: [{ keyId: 947321, base64: publicKeyBase64 }] }), { status: 200 });
};
const server = createServer(async (incoming, outgoing) => {
  try {
    const chunks = [];
    for await (const chunk of incoming) chunks.push(chunk);
    const body = Buffer.concat(chunks);
    const init = { method: incoming.method, headers: incoming.headers };
    if (incoming.method !== "GET" && incoming.method !== "HEAD") init.body = body;
    const request = new Request(`http://127.0.0.1:${server.address().port}${incoming.url}`, init);
    const response = await handleRequest(request, env, { now: Date.now(), fetcher: keyFetcher });
    outgoing.writeHead(response.status, Object.fromEntries(response.headers.entries()));
    outgoing.end(Buffer.from(await response.arrayBuffer()));
  } catch (error) {
    outgoing.writeHead(500, { "content-type": "application/json" });
    outgoing.end(JSON.stringify({ error: String(error) }));
  }
});

function makeToken(nowSeconds) {
  const encode = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
  const header = encode({ alg: "HS256", typ: "JWT" });
  const payload = encode({ sub: user, iss: issuer, aud: audience, iat: nowSeconds, exp: nowSeconds + 600 });
  return `${header}.${payload}.${createHmac("sha256", secret).update(`${header}.${payload}`).digest("base64url")}`;
}

function makeSignedSsv(claim, nowMs) {
  const fields = [
    ["ad_network", "test-network"], ["ad_unit", ssvAdUnit], ["custom_data", claim.nonce],
    ["reward_amount", "40"], ["reward_item", "coins"], ["timestamp", String(nowMs)],
    ["transaction_id", "bcm-v07-e2e-transaction"], ["user_id", user],
  ];
  const signed = fields.map(([key, value]) => `${key}=${encodeURIComponent(value)}`).join("&");
  const signature = sign("sha256", Buffer.from(signed), { key: privateKey, dsaEncoding: "der" }).toString("base64url");
  return `${signed}&signature=${signature}&key_id=947321`;
}

async function expectJson(response, expectedStatus, label) {
  const text = await response.text();
  if (response.status !== expectedStatus) throw new Error(`${label}: expected ${expectedStatus}, got ${response.status}: ${text}`);
  return text ? JSON.parse(text) : {};
}

function runGodot(executable, envVars, timeoutMs = 20000) {
  return new Promise((resolve, reject) => {
    const child = spawn(executable, ["--headless", "--path", projectRoot, "--script", "res://tests/m34_worker_sqlite_godot_e2e_probe.gd"], {
      cwd: projectRoot, env: { ...process.env, ...envVars }, windowsHide: true, stdio: ["ignore", "pipe", "pipe"],
    });
    let output = "";
    const timer = setTimeout(() => { child.kill(); reject(new Error(`Godot E2E timeout after ${timeoutMs}ms\n${output}`)); }, timeoutMs);
    child.stdout.setEncoding("utf8").on("data", (chunk) => { output += chunk; });
    child.stderr.setEncoding("utf8").on("data", (chunk) => { output += chunk; });
    child.on("error", (error) => { clearTimeout(timer); reject(error); });
    child.on("exit", (code) => {
      clearTimeout(timer);
      if (code !== 0) reject(new Error(`Godot E2E exit=${code}\n${output}`));
      else resolve(output);
    });
  });
}

server.listen(0, "127.0.0.1");
await new Promise((resolve, reject) => { server.once("listening", resolve); server.once("error", reject); });
__test.clearGoogleKeyCache();
const endpoint = `http://127.0.0.1:${server.address().port}`;
const token = makeToken(Math.floor(Date.now() / 1000));
const auth = { authorization: `Bearer ${token}`, "content-type": "application/json" };
const root = path.join(projectRoot, ".godot", "bcm_sandboxes", `worker_e2e_${process.pid}_${Date.now()}`);
const appData = path.join(root, "r");
const localAppData = path.join(root, "l");
const userData = path.join(appData, "Godot", "app_userdata", "CocktailMerge");
fs.mkdirSync(userData, { recursive: true });
fs.mkdirSync(localAppData, { recursive: true });
const primaryPath = path.join(userData, "campaign_save.json");
const backupPath = `${primaryPath}.bak`;
if (fs.existsSync(primaryPath) || fs.existsSync(backupPath)) throw new Error("Refusing to reuse a test profile with existing campaign save state.");

try {
  const godot = process.env.GODOT_CONSOLE || "godot_console.exe";
  const claim = await expectJson(await fetch(`${endpoint}/v1/ads/claims`, {
    method: "POST", headers: auth,
    body: JSON.stringify({ placement: "daily_slot_3", platform: "android", client_transaction_id: `daily:${new Date().toISOString().slice(0, 10)}:3`, consent_granted: true, consent_state: "UMP_NOT_REQUIRED" }),
  }), 200, "claim creation");
  if (claim.user_id !== user || claim.reward_item !== "coins" || claim.reward_amount !== 40) throw new Error("Worker claim binding mismatch.");
  const ssv = await expectJson(await fetch(`${endpoint}/v1/ads/ssv?${makeSignedSsv(claim, Date.now())}`), 200, "signed SSV settlement");
  if (ssv.duplicate || ssv.transaction_id !== "bcm-v07-e2e-transaction") throw new Error("Worker did not settle the synthetic SSV transaction exactly once.");
  const ledgerBefore = db.prepare("SELECT COUNT(*) AS count FROM reward_ledger WHERE nonce=? AND user_id=?").get(claim.nonce, user);
  if (ledgerBefore.count !== 1) throw new Error("SQLite settlement ledger did not contain exactly one reward.");
  const pendingBefore = await expectJson(await fetch(`${endpoint}/v1/ads/rewards/pending`, { headers: { authorization: `Bearer ${token}` } }), 200, "pending rewards");
  if (pendingBefore.rewards.length !== 1 || pendingBefore.rewards[0].transaction_id !== ssv.transaction_id) throw new Error("Pending HTTP response does not match signed ledger row.");

  const godotEnv = {
    APPDATA: appData, LOCALAPPDATA: localAppData,
    BCM_TEST_MODE: "1", BCM_TEST_SANDBOX_ROOT: root, BCM_TEST_BUILD_MARKER: "NONSHIPPING_LOCAL_TEST",
    BCM_E2E_WORKER_ENDPOINT: endpoint, BCM_E2E_AUTH_TOKEN: token, BCM_E2E_USER_ID: user,
  };
  const output = await runGodot(godot, godotEnv);
  const pendingAfter = await expectJson(await fetch(`${endpoint}/v1/ads/rewards/pending`, { headers: { authorization: `Bearer ${token}` } }), 200, "post-ACK pending rewards");
  const ack = db.prepare("SELECT COUNT(*) AS count FROM reward_delivery_ack WHERE transaction_id=? AND user_id=?").get(ssv.transaction_id, user);
  const finalLedger = db.prepare("SELECT COUNT(*) AS count FROM reward_ledger WHERE nonce=? AND user_id=?").get(claim.nonce, user);
  if (pendingAfter.rewards.length !== 0 || ack.count !== 1 || finalLedger.count !== 1) throw new Error("Godot asynchronous ACK did not leave one durable ledger row and an empty pending queue.");
  const replayOutput = await runGodot(godot, { ...godotEnv, BCM_E2E_REPLAY_ONLY: "1" });

  const hashes = {
    campaign_save_sha256: fs.existsSync(primaryPath) ? (await import("node:crypto")).createHash("sha256").update(fs.readFileSync(primaryPath)).digest("hex") : null,
    campaign_save_backup_sha256: fs.existsSync(backupPath) ? (await import("node:crypto")).createHash("sha256").update(fs.readFileSync(backupPath)).digest("hex") : null,
  };
  if (!hashes.campaign_save_sha256 || !hashes.campaign_save_backup_sha256) throw new Error("Expected separately materialized isolated primary and backup save files.");
  const report = {
    result: "PASS", evidence: "LOCAL_TEST_ONLY",
    flow: ["authenticated claim", "ECDSA signed synthetic SSV", "SQLite reward ledger", "pending HTTP", "Godot GameEconomy and SaveManager", "asynchronous ACK", "controller recreation", "separate Godot process restart/replay dedupe"],
    sandbox_root: root, user_data_root: userData,
    claim_nonce: claim.nonce, transaction_id: ssv.transaction_id,
    sqlite_ledger_rows: finalLedger.count, sqlite_ack_rows: ack.count, pending_rows_after_ack: pendingAfter.rewards.length,
    godot_output_tail: output.split(/\r?\n/).filter(Boolean).slice(-10), godot_restart_output_tail: replayOutput.split(/\r?\n/).filter(Boolean).slice(-6), ...hashes,
  };
  fs.writeFileSync(path.join(root, "integration_result.json"), `${JSON.stringify(report, null, 2)}\n`);
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
} finally {
  await new Promise((resolve) => server.close(resolve));
  db.close();
}
