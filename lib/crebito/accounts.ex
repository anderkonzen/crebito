defmodule Crebito.Accounts do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Crebito.Accounts.Client
  alias Crebito.Accounts.Repository
  alias Crebito.Accounts.Transaction
  alias Crebito.Repo
  alias Ecto.Multi

  @doc false
  @spec get_client(integer()) :: {:ok, Client.t()} | {:error, :not_found}
  def get_client(id) do
    case Repo.get(Client, id) do
      nil -> {:error, :not_found}
      client -> {:ok, client}
    end
  end

  @doc false
  @spec process_operation(Client.t(), map()) :: {:ok, Client.t(), Transaction.t()} | any()
  def process_operation(client, txn_attrs) do
    Multi.new()
    |> Multi.insert(:transaction, Repository.create_transaction_changeset(client, txn_attrs))
    |> Multi.update(:client, fn changes ->
      new_balance = calculate_new_balance(client, changes)
      Repository.update_client_current_balance_changeset(client, new_balance)
    end)
    |> Repo.transaction()
  end

  defp calculate_new_balance(client, changes) do
    value = changes.transaction.value
    type = changes.transaction.type

    if type == :c do
      client.current_balance + value
    else
      client.current_balance - value
    end
  end

  @doc false
  @spec get_transactions(Client.t(), integer()) :: list(Transaction.t())
  def get_transactions(%Client{} = client, limit \\ 10) do
    Repository.all_client_transactions_queryable(client, limit)
    |> Repo.all()
  end
end
