// Non-shipping protocol model. It is deliberately independent of production
// AdsService and uses only ephemeral keys and in-memory state.
const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');

const { publicKey, privateKey } = crypto.generateKeyPairSync('ec', {
  namedCurve: 'prime256v1',
});
const KEY_ID = 'test-key-1';
const now = 1_800_000_000_000;

function signQuery(fields) {
  const signed = new URLSearchParams(fields).toString();
  const signature = crypto.sign('sha256', Buffer.from(signed, 'utf8'), privateKey).toString('base64');
  return `${signed}&signature=${encodeURIComponent(signature)}&key_id=${KEY_ID}`;
}

function parseUnique(raw) {
  const out = new Map();
  for (const part of raw.split('&')) {
    const i = part.indexOf('=');
    if (i < 1) throw new Error('MALFORMED_QUERY');
    const key = part.slice(0, i);
    if (out.has(key)) throw new Error('DUPLICATE_PARAMETER');
    out.set(key, part.slice(i + 1));
  }
  return out;
}

class MockVerifier {
  constructor(clock = () => now) {
    this.clock = clock;
    this.transactions = new Map(); // durable production equivalent: unique DB constraint
    this.claims = new Map();
    this.adUnitPlacements = new Map([['ca-app-pub/test/rewarded', 'daily_energy']]);
  }

  issueClaim({ userId, nonce, placement, expiresAt, amount = '10', item = 'Coins' }) {
    this.claims.set(nonce, { userId, nonce, placement, expiresAt, amount, item, consumed: false });
  }

  handle(raw, { adUnit = 'ca-app-pub/test/rewarded' } = {}) {
    try {
      const sigPos = raw.lastIndexOf('&signature=');
      const keyPos = raw.lastIndexOf('&key_id=');
      if (sigPos < 0 || keyPos < 0 || keyPos <= sigPos || keyPos + 1 === raw.length) return { status: 400, reason: 'SIGNATURE_FIELDS_ORDER' };
      const signedBytes = raw.slice(0, sigPos);
      const params = parseUnique(raw);
      if ([...params.keys()].at(-2) !== 'signature' || [...params.keys()].at(-1) !== 'key_id') return { status: 400, reason: 'SIGNATURE_FIELDS_ORDER' };
      if (params.get('key_id') !== KEY_ID) return { status: 400, reason: 'UNKNOWN_KEY' };
      const signature = Buffer.from(decodeURIComponent(params.get('signature')), 'base64');
      if (!crypto.verify('sha256', Buffer.from(signedBytes, 'utf8'), publicKey, signature)) return { status: 400, reason: 'INVALID_SIGNATURE' };

      const value = (key) => params.has(key) ? decodeURIComponent(params.get(key)) : '';
      const tx = value('transaction_id');
      if (!tx) return { status: 400, reason: 'MISSING_TRANSACTION' };
      if (this.transactions.has(tx)) return { status: 200, duplicate: true };
      if (value('ad_unit') !== adUnit || !this.adUnitPlacements.has(adUnit)) return { status: 400, reason: 'AD_UNIT_MISMATCH' };
      if (value('reward_amount') !== '10' || value('reward_item') !== 'Coins') return { status: 400, reason: 'REWARD_MISMATCH' };
      const timestamp = Number(value('timestamp'));
      if (!Number.isSafeInteger(timestamp) || timestamp > this.clock() + 300_000 || this.clock() - timestamp > 86_400_000) return { status: 400, reason: 'STALE_CALLBACK' };
      const claim = this.claims.get(value('custom_data'));
      if (!claim || claim.consumed || claim.expiresAt < this.clock()) return { status: 400, reason: 'CLAIM_INVALID_OR_EXPIRED' };
      if (value('user_id') !== claim.userId || value('custom_data') !== claim.nonce || claim.placement !== this.adUnitPlacements.get(adUnit)) return { status: 400, reason: 'CLAIM_BINDING_MISMATCH' };
      // Production must atomically insert transaction + consume nonce + ledger grant.
      claim.consumed = true;
      this.transactions.set(tx, { userId: claim.userId, amount: claim.amount, item: claim.item });
      return { status: 200, settled: true, userId: claim.userId, amount: claim.amount };
    } catch (error) {
      return { status: 400, reason: error.message };
    }
  }
}

function callback({ tx = 'tx-1', nonce = 'opaque-nonce', user = 'user-1', timestamp = now, amount = '10', item = 'Coins', unit = 'ca-app-pub/test/rewarded' } = {}) {
  return signQuery([
    ['ad_network', 'test-network'], ['ad_unit', unit], ['custom_data', nonce],
    ['reward_amount', amount], ['reward_item', item], ['timestamp', String(timestamp)],
    ['transaction_id', tx], ['user_id', user],
  ]);
}

function verifierWithClaim(options = {}) {
  const verifier = new MockVerifier();
  verifier.issueClaim({ userId: 'user-1', nonce: 'opaque-nonce', placement: 'daily_energy', expiresAt: now + 86_400_000, ...options });
  return verifier;
}

test('rejects altered callback bytes and signature', () => {
  const verifier = verifierWithClaim();
  const changed = callback().replace('reward_amount=10', 'reward_amount=11');
  assert.equal(verifier.handle(changed).reason, 'INVALID_SIGNATURE');
});

test('verified duplicate transaction is idempotent and returns success', () => {
  const verifier = verifierWithClaim();
  const signed = callback();
  assert.equal(verifier.handle(signed).settled, true);
  assert.deepEqual(verifier.handle(signed), { status: 200, duplicate: true });
  assert.equal(verifier.transactions.size, 1);
});

test('rejects stale signed callback', () => {
  const verifier = verifierWithClaim();
  assert.equal(verifier.handle(callback({ timestamp: now - 86_400_001 })).reason, 'STALE_CALLBACK');
});

test('settles an SSV event before any client earned callback arrives', () => {
  const verifier = verifierWithClaim();
  const result = verifier.handle(callback());
  assert.equal(result.settled, true);
  assert.equal(verifier.transactions.has('tx-1'), true);
});

test('rejects callback replayed across another user claim', () => {
  const verifier = new MockVerifier();
  verifier.issueClaim({ userId: 'user-2', nonce: 'opaque-nonce', placement: 'daily_energy', expiresAt: now + 100_000 });
  assert.equal(verifier.handle(callback()).reason, 'CLAIM_BINDING_MISMATCH');
  assert.equal(verifier.transactions.size, 0);
});

test('rejects amount or reward item mismatch after signature verification', () => {
  const verifier = verifierWithClaim();
  assert.equal(verifier.handle(callback({ amount: '11' })).reason, 'REWARD_MISMATCH');
  assert.equal(verifier.transactions.size, 0);
});

test('rejects reordered callback parameters even when old signature is retained', () => {
  const verifier = verifierWithClaim();
  const signed = callback();
  const pieces = signed.split('&');
  [pieces[0], pieces[1]] = [pieces[1], pieces[0]];
  assert.equal(verifier.handle(pieces.join('&')).reason, 'INVALID_SIGNATURE');
});

test('rejects future callback outside bounded clock skew', () => {
  const verifier = verifierWithClaim();
  assert.equal(verifier.handle(callback({ timestamp: now + 300_001 })).reason, 'STALE_CALLBACK');
});
