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

  describe "get_statement" do
    test "returns latest transactions", %{conn: conn} do
      client = insert(:client, limit: 10_000)
      post_transaction(conn, client, "c", 5, "first")
      post_transaction(conn, client, "d", 100, "second")

      conn = get(conn, ~p"/clientes/#{client.id}/extrato")

      assert %{
               "saldo" => %{
                 "total" => -95,
                 "data_extrato" => _,
                 "limite" => 10_000
               },
               "ultimas_transacoes" => [
                 %{
                   "valor" => 100,
                   "tipo" => "d",
                   "descricao" => "second",
                   "realizada_em" => _
                 },
                 %{
                   "valor" => 5,
                   "tipo" => "c",
                   "descricao" => "first",
                   "realizada_em" => _
                 }
               ]
             } = json_response(conn, 200)
    end

    test "returns 404 whe client does not exist", %{conn: conn} do
      conn = post(conn, ~p"/clientes/-1/extrato")
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  defp post_transaction(conn, client, type, value, description) do
    params = %{valor: value, tipo: type, descricao: description}
    post(conn, ~p"/clientes/#{client.id}/transacoes", params)
  end
end
