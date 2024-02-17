defmodule Crebito.Accounts.Repository do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query

  alias Crebito.Accounts.Client
  alias Crebito.Accounts.Transaction

  @doc false
  @spec create_transaction_changeset(map()) :: Ecto.Changeset.t()
  def create_transaction_changeset(attrs) do
    %Transaction{}
    |> cast(attrs, [:value, :type, :description, :client_id])
    |> validate_required([:value, :type, :description, :client_id])
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, [:c, :d])
    |> validate_length(:description, min: 1, max: 10)
  end

  defp validate_current_balance(changeset, client) do
    new_current_balance = fetch_change!(changeset, :current_balance)

    if abs(new_current_balance) <= client.limit do
      changeset
    else
      add_error(changeset, :current_balance, "has maxed out the limit")
    end
  end

  def invalid_balance_client_changeset do
    client = %Client{limit: 1}

    client
    |> change(%{current_balance: -10, opening_balance: 0})
    |> validate_current_balance(client)
  end

  @doc false
  @spec all_client_transactions_queryable(Client.t(), integer()) :: Ecto.Query.t()
  def all_client_transactions_queryable(%Client{} = client, limit) do
    from(
      t in Transaction,
      where: t.client_id == ^client.id,
      order_by: [desc: t.id],
      limit: ^limit,
      select: t
    )
  end
end
