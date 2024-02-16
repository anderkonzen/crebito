defmodule Crebito.AccountsTest do
  use Crebito.DataCase

  import Crebito.Factory

  alias Crebito.Accounts
  alias Crebito.Accounts.Transaction

  describe "clients" do
    test "get_client/1 returns the client with given id" do
      client = insert(:client)
      assert Accounts.get_client(client.id) == {:ok, client}
    end

    test "get_client/1 returns error when client with given id does not exist" do
      assert Accounts.get_client(-1) == {:error, :not_found}
    end
  end

  describe "transactions" do
    test "process transaction of type credit" do
      client = insert(:client)

      txn_attrs = %{
        value: 1000,
        type: :c,
        description: "credit"
      }

      {:ok, %{client: updated_client, transaction: transaction}} =
        Accounts.process_operation(client, txn_attrs)

      assert updated_client.limit == client.limit
      assert updated_client.opening_balance == client.opening_balance
      assert updated_client.current_balance == client.current_balance + 1000

      assert transaction.value == 1000
      assert transaction.type == :c
      assert transaction.description == "credit"
    end

    test "process transaction of type debit" do
      client = insert(:client)

      txn_attrs = %{
        value: 1000,
        type: :d,
        description: "debit"
      }

      {:ok, %{client: updated_client, transaction: transaction}} =
        Accounts.process_operation(client, txn_attrs)

      assert updated_client.limit == client.limit
      assert updated_client.opening_balance == client.opening_balance
      assert updated_client.current_balance == client.current_balance - 1000

      assert transaction.value == 1000
      assert transaction.type == :d
      assert transaction.description == "debit"
    end

    test "fails transaction when limit is maxed out" do
      client = insert(:client)

      txn_attrs = %{
        value: 100_000,
        type: :d,
        description: "debit"
      }

      {:error, :client, changeset, _} = Accounts.process_operation(client, txn_attrs)

      assert changeset.errors == [current_balance: {"has maxed out the limit", []}]
      assert Repo.all(Transaction) == []
    end
  end
end
