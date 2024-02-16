defmodule Crebito.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Crebito.Repo

  alias Crebito.Accounts.Client
  alias Crebito.Accounts.Transaction

  def client_factory do
    %Client{limit: 10_000, opening_balance: 0, current_balance: 0}
  end

  def transaction_factory do
    %Transaction{client: build(:client)}
  end
end
