defmodule CrebitoWeb.ClientJSONTest do
  use CrebitoWeb.ConnCase, async: true

  import Crebito.Factory

  alias CrebitoWeb.ClientJSON

  test "renders balance state" do
    client = insert(:client, limit: 10, current_balance: 1)

    assert CrebitoWeb.ClientJSON.balance_state(%{client: client}) ==
             %{
               limite: client.limit,
               saldo: client.current_balance
             }
  end

  test "renders statement" do
    client = insert(:client, limit: 10, current_balance: 1)
    txn = insert(:transaction, client: client, type: "c", value: 1, description: "credit")

    assert %{
             saldo: %{
               total: 1,
               data_extrato: _statement_date,
               limite: 10
             },
             ultimas_transacoes: [
               %{
                 valor: 1,
                 tipo: :c,
                 descricao: "credit",
                 realizada_em: _inserted_at
               }
             ]
           } = ClientJSON.statement(%{client: client, transactions: [txn]})
  end
end
