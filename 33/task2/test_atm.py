import pytest
from atm import BankAccount

@pytest.fixture
def account():
    # replaces setUp
    return BankAccount("Alice", 100)


def test_initial_balance(account):
    assert account.balance == 100
    assert isinstance(account.balance, int)


def test_deposit(account):
    account.deposit(50)
    assert account.balance == 150
    assert account.balance > 100


def test_deposit_invalid_amount(account):
    with pytest.raises(ValueError):
        account.deposit(0)


def test_withdraw(account):
    account.withdraw(40)
    assert account.balance == 60
    assert account.balance < 100


def test_withdraw_too_much(account):
    with pytest.raises(ValueError):
        account.withdraw(200)


def test_withdraw_invalid_amount(account):
    with pytest.raises(ValueError):
        account.withdraw(-10)


def test_owner_name(account):
    assert account.owner == "Alice"
    assert account.owner.startswith("A")

