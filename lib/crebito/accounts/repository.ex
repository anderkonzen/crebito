defmodule Crebito.Accounts.Repository do
  @moduledoc false

  import Ecto.Changeset

  alias Crebito.Accounts.Client

  @doc false
  @spec create_transaction_changeset(Client.t(), map()) :: Ecto.Changeset.t()
  def create_transaction_changeset(%Client{} = client, attrs) do
    client
    |> Ecto.build_assoc(:transactions, attrs)
    |> cast(attrs, [:value, :type, :description])
    |> validate_required([:value, :type, :description, :client_id])
    |> validate_number(:value, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, [:c, :d])
    |> validate_length(:description, min: 1, max: 10)
  end

  @doc false
  @spec update_client_current_balance_changeset(Client.t(), integer()) :: Ecto.Changeset.t()
  def update_client_current_balance_changeset(%Client{} = client, new_current_balance) do
    client
    |> change(%{current_balance: new_current_balance})
    |> validate_current_balance(client)
  end

  defp validate_current_balance(changeset, client) do
    new_current_balance = fetch_change!(changeset, :current_balance)

    if abs(new_current_balance) <= client.limit do
      changeset
    else
      add_error(changeset, :current_balance, "has maxed out the limit")
    end
  end
end
