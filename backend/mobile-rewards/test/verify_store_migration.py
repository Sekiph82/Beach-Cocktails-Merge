"""SQLite compatibility/security checks for the D1 store ledger migration."""
from pathlib import Path
import sqlite3
import unittest


ROOT = Path(__file__).resolve().parents[1]


class StoreMigrationTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.execute("PRAGMA foreign_keys=ON")
        for migration in sorted((ROOT / "migrations").glob("*.sql")):
            self.db.executescript(migration.read_text(encoding="utf-8"))

    def tearDown(self):
        self.db.close()

    def add_purchase(self, transaction, user, kind="non_consumable", state="verified"):
        self.db.execute("""INSERT INTO store_purchase_history
            (platform,transaction_id,user_id,product_id,product_kind,application_id,environment,state,purchased_at,checked_at)
            VALUES ('google',?,?,?,?,'com.example.game','production',?,100,100)""",
            (transaction, user, "remove.ads" if kind == "non_consumable" else "coins.1", kind, state))

    def test_migrations_apply_and_unique_transaction_binding_rejects_other_owner(self):
        self.add_purchase("tx-1", "account-A")
        with self.assertRaises(sqlite3.IntegrityError):
            self.add_purchase("tx-1", "account-B")

    def test_journal_requires_matching_verified_purchase_and_is_idempotent(self):
        self.add_purchase("tx-1", "account-A")
        journal = """INSERT INTO store_grant_journal
          (platform,transaction_id,user_id,product_id,product_kind,state,grant_payload_json,created_at)
          VALUES ('google',? ,? ,'remove.ads','non_consumable','pending','{}',100)"""
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(journal, ("tx-1", "account-B"))
        self.db.execute(journal, ("tx-1", "account-A"))
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(journal, ("tx-1", "account-A"))

    def test_entitlement_restore_requires_verified_nonconsumable(self):
        self.add_purchase("remove-tx", "account-A")
        self.add_purchase("coins-tx", "account-A", kind="consumable")
        self.add_purchase("pending-tx", "account-A", state="refunded")
        entitlement = """INSERT INTO store_entitlements
          (user_id,product_id,platform,transaction_id,state,granted_at,updated_at)
          VALUES ('account-A',?,'google',?,'active',100,100)"""
        self.db.execute(entitlement, ("remove.ads", "remove-tx"))
        for product, transaction in (("coins.1", "coins-tx"), ("remove.ads", "pending-tx")):
            with self.subTest(transaction=transaction), self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(entitlement, (product, transaction))

    def test_later_reversal_marks_journal_and_entitlement_without_economy_debit(self):
        self.add_purchase("remove-tx", "account-A")
        self.db.execute("""INSERT INTO store_entitlements
            (user_id,product_id,platform,transaction_id,state,granted_at,updated_at)
            VALUES ('account-A','remove.ads','google','remove-tx','active',100,100)""")
        self.db.execute("""INSERT INTO store_grant_journal
            (platform,transaction_id,user_id,product_id,product_kind,state,grant_payload_json,created_at,applied_at)
            VALUES ('google','remove-tx','account-A','remove.ads','non_consumable','applied','{}',100,100)""")
        self.db.execute("UPDATE store_purchase_history SET state='refunded', checked_at=200 WHERE transaction_id='remove-tx'")
        self.assertEqual(self.db.execute("SELECT state FROM store_entitlements").fetchone()[0], "revoked")
        self.assertEqual(self.db.execute("SELECT state FROM store_grant_journal").fetchone()[0], "reversed")


if __name__ == "__main__":
    unittest.main(verbosity=2)
