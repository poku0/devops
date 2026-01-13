import unittest
from atm import BankAccount


class TestBankAccount(unittest.TestCase):

    def setUp(self):
        """Runs before each test"""
        self.account = BankAccount("Alice", 100)

    def tearDown(self):
        """Runs after each test"""
        self.account = None

    def test_initial_balance(self):
        self.assertEqual(self.account.balance, 100)
        self.assertIsInstance(self.account.balance, int)

    def test_deposit(self):
        self.account.deposit(50)
        self.assertEqual(self.account.balance, 150)
        self.assertGreater(self.account.balance, 100)

    def test_deposit_invalid_amount(self):
        with self.assertRaises(ValueError):
            self.account.deposit(0)

    def test_withdraw(self):
        self.account.withdraw(40)
        self.assertEqual(self.account.balance, 60)
        self.assertLess(self.account.balance, 100)

    def test_withdraw_too_much(self):
        with self.assertRaises(ValueError):
            self.account.withdraw(200)

    def test_withdraw_invalid_amount(self):
        with self.assertRaises(ValueError):
            self.account.withdraw(-10)

    def test_owner_name(self):
        self.assertEqual(self.account.owner, "Alice")
        self.assertTrue(self.account.owner.startswith("A"))


if __name__ == "__main__":
    unittest.main()
