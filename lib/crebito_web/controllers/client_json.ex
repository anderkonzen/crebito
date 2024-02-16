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

  def statement(%{client: %Client{} = client, transactions: transactions}) do
    last_transactions =
      Enum.map(transactions, fn txn ->
        %{
          valor: txn.value,
          tipo: txn.type,
          descricao: txn.description,
          realizada_em: txn.inserted_at
        }
      end)

    %{
      saldo: %{
        total: client.current_balance,
        data_extrato: "1",
        limite: client.limit
      },
      ultimas_transacoes: last_transactions
    }
  end
end
