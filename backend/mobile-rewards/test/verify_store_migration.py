"""SQLite compatibility/security checks for the D1 store ledger migrations."""
from pathlib import Path
import sqlite3
import unittest


ROOT = Path(__file__).resolve().parents[1]


class StoreMigrationTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.execute("PRAGMA foreign_keys=ON")
        self.apply_migrations(self.db)

    @staticmethod
    def apply_migrations(db, through="0004"):
        for migration in sorted((ROOT / "migrations").glob("*.sql")):
            if migration.stem[:4] <= through:
                db.executescript(migration.read_text(encoding="utf-8"))

    @staticmethod
    def add_purchase_to(db, transaction, user, kind="non_consumable", state="verified"):
        product = "remove.ads" if kind == "non_consumable" else "coins.1"
        db.execute("""INSERT INTO store_purchase_history
            (platform,transaction_id,user_id,product_id,product_kind,application_id,environment,state,purchased_at,checked_at)
            VALUES ('google',?,?,?,?,'com.example.game','production',?,100,100)""",
            (transaction, user, product, kind, state))

    @staticmethod
    def add_journal(db, transaction, user, product="remove.ads", kind="non_consumable", payload='{"units":1}'):
        db.execute("""INSERT INTO store_grant_journal
            (platform,transaction_id,user_id,product_id,product_kind,state,grant_payload_json,created_at)
            VALUES ('google',?,?,?,?,'pending',?,100)""", (transaction, user, product, kind, payload))

    @staticmethod
    def add_entitlement(db, transaction, user, product="remove.ads"):
        db.execute("""INSERT INTO store_entitlements
            (user_id,product_id,platform,transaction_id,state,granted_at,updated_at)
            VALUES (?,?,'google',?,'active',100,100)""", (user, product, transaction))

    def add_purchase(self, transaction, user, kind="non_consumable", state="verified"):
        self.add_purchase_to(self.db, transaction, user, kind, state)

    def tearDown(self):
        self.db.close()

    def test_pre_0004_vulnerable_updates_are_reproduced(self):
        db = sqlite3.connect(":memory:")
        db.execute("PRAGMA foreign_keys=ON")
        self.apply_migrations(db, through="0003")
        self.add_purchase_to(db, "legacy-journal", "account-A")
        self.add_journal(db, "legacy-journal", "account-A")
        db.execute("""UPDATE store_grant_journal SET user_id='account-B', product_id='coins.1',
            product_kind='consumable', grant_payload_json='{"units":999}' WHERE transaction_id='legacy-journal'""")
        self.assertEqual(db.execute("SELECT user_id,product_id,product_kind,grant_payload_json FROM store_grant_journal").fetchone(),
            ("account-B", "coins.1", "consumable", '{"units":999}'))

        self.add_purchase_to(db, "legacy-restore", "account-A")
        self.add_entitlement(db, "legacy-restore", "account-A")
        db.execute("UPDATE store_purchase_history SET state='refunded',checked_at=200 WHERE transaction_id='legacy-restore'")
        db.execute("UPDATE store_entitlements SET state='active' WHERE transaction_id='legacy-restore'")
        self.assertEqual(db.execute("SELECT state FROM store_entitlements WHERE transaction_id='legacy-restore'").fetchone()[0], "active")
        db.execute("UPDATE store_purchase_history SET user_id='account-B',product_id='fake.sku',application_id='attacker.app' WHERE transaction_id='legacy-restore'")
        db.execute("UPDATE store_purchase_history SET state='verified' WHERE transaction_id='legacy-restore'")
        self.assertEqual(db.execute("SELECT user_id,product_id,application_id,state FROM store_purchase_history WHERE transaction_id='legacy-restore'").fetchone(),
            ("account-B", "fake.sku", "attacker.app", "verified"))
        db.close()

    def test_grant_journal_updates_cannot_mutate_identity_or_payload(self):
        self.add_purchase("journal", "account-A")
        self.add_journal(self.db, "journal", "account-A")
        for sql in (
            "UPDATE store_grant_journal SET user_id='account-B' WHERE transaction_id='journal'",
            "UPDATE store_grant_journal SET product_id='fake.sku' WHERE transaction_id='journal'",
            "UPDATE store_grant_journal SET product_kind='consumable' WHERE transaction_id='journal'",
            "UPDATE store_grant_journal SET grant_payload_json='{}' WHERE transaction_id='journal'",
            "UPDATE store_grant_journal SET platform='apple' WHERE transaction_id='journal'",
            "UPDATE store_grant_journal SET transaction_id='new-tx' WHERE transaction_id='journal'",
        ):
            with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(sql)

    def test_grant_journal_allows_verified_apply_and_terminal_reversal_only(self):
        self.add_purchase("journal", "account-A")
        self.add_journal(self.db, "journal", "account-A")
        self.db.execute("UPDATE store_grant_journal SET state='applied',applied_at=150 WHERE transaction_id='journal'")
        self.db.execute("UPDATE store_grant_journal SET state='applied',applied_at=150 WHERE transaction_id='journal'")
        self.db.execute("UPDATE store_purchase_history SET state='refunded',checked_at=200 WHERE transaction_id='journal'")
        self.assertEqual(self.db.execute("SELECT state FROM store_grant_journal WHERE transaction_id='journal'").fetchone()[0], "reversed")
        self.db.execute("UPDATE store_grant_journal SET state='reversed' WHERE transaction_id='journal'")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_grant_journal SET state='applied' WHERE transaction_id='journal'")
        self.add_purchase("never-apply", "account-A")
        self.add_journal(self.db, "never-apply", "account-A")
        self.db.execute("UPDATE store_purchase_history SET state='refunded',checked_at=201 WHERE transaction_id='never-apply'")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_grant_journal SET state='applied',applied_at=202 WHERE transaction_id='never-apply'")

    def test_entitlement_cannot_reactivate_same_reversed_purchase_but_can_bind_new_verified_one(self):
        self.add_purchase("restore-old", "account-A")
        self.add_entitlement(self.db, "restore-old", "account-A")
        self.db.execute("UPDATE store_purchase_history SET state='refunded',checked_at=200 WHERE transaction_id='restore-old'")
        self.assertEqual(self.db.execute("SELECT state FROM store_entitlements").fetchone()[0], "revoked")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_entitlements SET state='active' WHERE transaction_id='restore-old'")
        self.db.execute("UPDATE store_entitlements SET state='revoked',updated_at=201 WHERE transaction_id='restore-old'")
        self.add_purchase("restore-new", "account-A")
        self.db.execute("""UPDATE store_entitlements SET transaction_id='restore-new',state='active',granted_at=300,updated_at=300
            WHERE user_id='account-A' AND product_id='remove.ads'""")
        self.assertEqual(self.db.execute("SELECT transaction_id,state FROM store_entitlements").fetchone(), ("restore-new", "active"))
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_entitlements SET user_id='account-B' WHERE transaction_id='restore-new'")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_entitlements SET expires_at=9223372036854775807 WHERE transaction_id='restore-new'")

    def test_purchase_identity_is_immutable_and_terminal_states_cannot_reopen(self):
        self.add_purchase("identity", "account-A")
        for sql in (
            "UPDATE store_purchase_history SET user_id='account-B' WHERE transaction_id='identity'",
            "UPDATE store_purchase_history SET product_id='fake.sku' WHERE transaction_id='identity'",
            "UPDATE store_purchase_history SET product_kind='consumable' WHERE transaction_id='identity'",
            "UPDATE store_purchase_history SET application_id='attacker.app' WHERE transaction_id='identity'",
            "UPDATE store_purchase_history SET environment='sandbox' WHERE transaction_id='identity'",
            "UPDATE store_purchase_history SET transaction_id='new-identity' WHERE transaction_id='identity'",
            "UPDATE store_purchase_history SET provider_order_id='fake-order' WHERE transaction_id='identity'",
        ):
            with self.subTest(sql=sql), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(sql)
        self.db.execute("UPDATE store_purchase_history SET state='revoked',checked_at=200 WHERE transaction_id='identity'")
        self.db.execute("UPDATE store_purchase_history SET state='revoked',checked_at=201 WHERE transaction_id='identity'")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_purchase_history SET state='verified' WHERE transaction_id='identity'")

    def test_expiry_cascade_is_allowed_idempotent_and_cannot_reactivate(self):
        self.add_purchase("expires", "account-A")
        self.add_entitlement(self.db, "expires", "account-A")
        self.db.execute("UPDATE store_purchase_history SET state='expired',checked_at=200 WHERE transaction_id='expires'")
        self.db.execute("UPDATE store_purchase_history SET state='expired',checked_at=201 WHERE transaction_id='expires'")
        self.assertEqual(self.db.execute("SELECT state FROM store_entitlements").fetchone()[0], "expired")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_entitlements SET state='active' WHERE transaction_id='expires'")

    def test_revocation_cascade_is_allowed_and_idempotent(self):
        self.add_purchase("revoked", "account-A")
        self.add_entitlement(self.db, "revoked", "account-A")
        self.db.execute("UPDATE store_purchase_history SET state='revoked',checked_at=200 WHERE transaction_id='revoked'")
        self.db.execute("UPDATE store_purchase_history SET state='revoked',checked_at=201 WHERE transaction_id='revoked'")
        self.assertEqual(self.db.execute("SELECT state FROM store_entitlements").fetchone()[0], "revoked")
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("UPDATE store_entitlements SET state='active' WHERE transaction_id='revoked'")

    def test_migrations_apply_and_unique_transaction_binding_rejects_other_owner(self):
        self.add_purchase("tx-1", "account-A")
        with self.assertRaises(sqlite3.IntegrityError):
            self.add_purchase("tx-1", "account-B")

    def test_journal_requires_matching_verified_purchase_and_is_idempotent(self):
        self.add_purchase("tx-1", "account-A")
        with self.assertRaises(sqlite3.IntegrityError):
            self.add_journal(self.db, "tx-1", "account-B")
        self.add_journal(self.db, "tx-1", "account-A")
        with self.assertRaises(sqlite3.IntegrityError):
            self.add_journal(self.db, "tx-1", "account-A")

    def test_entitlement_restore_requires_verified_nonconsumable(self):
        self.add_purchase("remove-tx", "account-A")
        self.add_purchase("coins-tx", "account-A", kind="consumable")
        self.add_purchase("pending-tx", "account-A", state="refunded")
        self.add_entitlement(self.db, "remove-tx", "account-A")
        for transaction, product in (("coins-tx", "coins.1"), ("pending-tx", "remove.ads")):
            with self.subTest(transaction=transaction), self.assertRaises(sqlite3.IntegrityError):
                self.add_entitlement(self.db, transaction, "account-A", product)

    def test_later_reversal_marks_journal_and_entitlement_without_economy_debit(self):
        self.add_purchase("remove-tx", "account-A")
        self.add_entitlement(self.db, "remove-tx", "account-A")
        self.add_journal(self.db, "remove-tx", "account-A", payload="{}")
        self.db.execute("UPDATE store_purchase_history SET state='refunded',checked_at=200 WHERE transaction_id='remove-tx'")
        self.assertEqual(self.db.execute("SELECT state FROM store_entitlements").fetchone()[0], "revoked")
        self.assertEqual(self.db.execute("SELECT state FROM store_grant_journal").fetchone()[0], "reversed")


if __name__ == "__main__":
    unittest.main(verbosity=2)
