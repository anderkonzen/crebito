defmodule Crebito.Accounts do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Crebito.Accounts.Client
  alias Crebito.Accounts.Repository
  alias Crebito.Accounts.Transaction
  alias Crebito.KV
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
  @spec client_exists?(integer()) :: :ok | {:error, :not_found}
  def client_exists?(id) do
    cond do
      KV.has?(id) == true ->
        :ok

      elem(get_client(id), 0) == :ok ->
        KV.put(id)
        :ok

      true ->
        {:error, :not_found}
    end
  end

  @doc false
  @spec process_operation(map()) :: {:ok, any()}
  def process_operation(txn_attrs) do
    Multi.new()
    |> Multi.insert(:transaction, Repository.create_transaction_changeset(txn_attrs))
    |> Multi.update_all(
      :client,
      fn changes ->
        increment = calculate_increment(changes)

        Client
        |> where(id: ^txn_attrs.client_id)
        |> update(inc: [current_balance: ^increment])
        |> select([c], c)
      end,
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{client: {_, [client]}, transaction: transaction}} ->
        {:ok, %{client: client, transaction: transaction}}

      error ->
        error
    end
  rescue
    error in [Postgrex.Error] ->
      if error.postgres.constraint == "current_balance_within_limit" do
        {:error, Repository.invalid_balance_client_changeset()}
      end
  end

  defp calculate_increment(changes) do
    value = changes.transaction.value
    type = changes.transaction.type

    if type == :c do
      value
    else
      value * -1
    end
  end

  @doc false
  @spec get_transactions(Client.t(), integer()) :: list(Transaction.t())
  def get_transactions(client, limit \\ 10) do
    Repository.all_client_transactions_queryable(client, limit)
    |> Repo.all()
  end
end
