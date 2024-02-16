defmodule CrebitoWeb.ClientController do
  @moduledoc false

  use CrebitoWeb, :controller

  alias Crebito.Accounts

  action_fallback CrebitoWeb.FallbackController

  def create_transaction(conn, %{"id" => client_id} = params) do
    txn_params = map_txn_params(params)

    with {:ok, client} <- Accounts.get_client(client_id),
         {:ok, %{client: client, transaction: _transaction}} <-
           Accounts.process_operation(client, txn_params) do
      conn
      |> put_status(:ok)
      |> put_view(json: CrebitoWeb.ClientJSON)
      |> render(:balance_state, client: client)
    end
  end

  defp map_txn_params(params) do
    %{
      value: params["valor"],
      type: params["tipo"],
      description: params["descricao"]
    }
  end
end