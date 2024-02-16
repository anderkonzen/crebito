defmodule CrebitoWeb.Router do
  use CrebitoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CrebitoWeb do
    pipe_through :api

    post "/clientes/:id/transacoes", ClientController, :create_transaction
    get "/clientes/:id/extrato", ClientController, :get_statement
  end
end
