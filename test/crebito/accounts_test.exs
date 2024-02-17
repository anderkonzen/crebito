defmodule Crebito.AccountsTest do
  use Crebito.DataCase

  import Crebito.Factory

  alias Crebito.Accounts
  alias Crebito.Accounts.Client
  alias Crebito.Accounts.Transaction
  alias Crebito.Repo

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
        description: "credit",
        client_id: client.id
      }

      {:ok, %{client: updated_client, transaction: transaction}} =
        Accounts.process_operation(txn_attrs)

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
        description: "debit",
        client_id: client.id
      }

      {:ok, %{client: updated_client, transaction: transaction}} =
        Accounts.process_operation(txn_attrs)

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
        description: "debit",
        client_id: client.id
      }

      # {:error, :client, changeset, _} =
      Accounts.process_operation(txn_attrs)

      # assert changeset.errors == [current_balance: {"has maxed out the limit", []}]
      assert Repo.all(Transaction) == []
    end

    test "fails transaction when description is too big" do
      client = insert(:client)

      txn_attrs = %{
        value: 1,
        type: :d,
        description: "this description is too big",
        client_id: client.id
      }

      {:error, :transaction, changeset, _} = Accounts.process_operation(txn_attrs)

      assert changeset.errors == [
               description:
                 {"should be at most %{count} character(s)",
                  [count: 10, validation: :length, kind: :max, type: :string]}
             ]

      assert Repo.all(Transaction) == []
    end

    test "debits the right amount given concurrent calls" do
      client = insert(:client)

      txn_attrs = %{
        value: 1,
        type: :d,
        description: "debit",
        client_id: client.id
      }

      1..25
      |> Task.async_stream(fn _ ->
        Accounts.process_operation(txn_attrs)
      end)
      |> Stream.run()

      client = Repo.get!(Client, client.id)
      assert client.current_balance == -25
    end
  end

  describe "statement" do
    test "returns all transactions for a given client" do
      transaction = insert(:transaction)

      assert length(Accounts.get_transactions(transaction.client)) == 1
    end

    test "returns the default limit" do
      client = insert(:client)
      insert_list(20, :transaction, client: client)

      assert length(Accounts.get_transactions(client)) == 10
    end

    test "returns transactions ordered by insertion date" do
      client = insert(:client)
      txn_1 = insert(:transaction, client: client)
      txn_2 = insert(:transaction, client: client)

      [list_txn_2, list_txn_1] = Accounts.get_transactions(client)
      assert list_txn_1.id == txn_1.id
      assert list_txn_2.id == txn_2.id
    end
  end
end
