defmodule CrebitoWeb.ClientJSON do
  @moduledoc false

  alias Crebito.Accounts.Client

  @doc """
  Renders the client balance state.
  """
  def balance_state(%{client: %Client{} = client}) do
    %{
      limite: client.limit,
      saldo: client.current_balance
    }
  end
end
