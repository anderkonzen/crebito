defmodule CrebitoWeb.ClientController do
  @moduledoc false

  use CrebitoWeb, :controller

  alias Crebito.Accounts

  action_fallback CrebitoWeb.FallbackController

  @doc false
  @spec create_transaction(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_transaction(conn, %{"id" => client_id} = params) do
    txn_params = map_txn_params(client_id, params)

    with {:ok, _client} <- Accounts.get_client(client_id),
         {:ok, %{client: client, transaction: _transaction}} <-
           Accounts.process_operation(txn_params) do
      conn
      |> put_status(:ok)
      |> put_view(json: CrebitoWeb.ClientJSON)
      |> render(:balance_state, client: client)
    end
  end

  defp map_txn_params(client_id, params) do
    %{
      value: params["valor"],
      type: params["tipo"],
      description: params["descricao"],
      client_id: client_id
    }
  end

  @doc false
  @spec get_statement(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_statement(conn, %{"id" => client_id}) do
    with {:ok, client} <- Accounts.get_client(client_id),
         transactions <- Accounts.get_transactions(client) do
      conn
      |> put_status(:ok)
      |> put_view(json: CrebitoWeb.ClientJSON)
      |> render(:statement, client: client, transactions: transactions)
    end
  end
end
