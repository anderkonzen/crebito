defmodule CrebitoWeb.ClientControllerTest do
  use CrebitoWeb.ConnCase

  import Crebito.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create_transaction" do
    test "returns 200 for credit operation", %{conn: conn} do
      client = insert(:client, limit: 10_000, opening_balance: 0, current_balance: 0)
      params = %{valor: 1000, tipo: "c", descricao: "credito"}

      conn = post(conn, ~p"/clientes/#{client.id}/transacoes", params)

      assert %{
               "limite" => 10_000,
               "saldo" => 1000
             } = json_response(conn, 200)
    end

    test "returns 404 when client does not exist", %{conn: conn} do
      conn = post(conn, ~p"/clientes/-1/transacoes")
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test "return 422 when limit is maxed out", %{conn: conn} do
      client = insert(:client, limit: 1000, opening_balance: 0, current_balance: 0)
      params = %{valor: 10_000, tipo: "d", descricao: "debito"}

      conn = post(conn, ~p"/clientes/#{client.id}/transacoes", params)

      assert %{"current_balance" => ["has maxed out the limit"]} ==
               json_response(conn, 422)["errors"]
    end
  end
end
