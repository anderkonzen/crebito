defmodule Crebito.Accounts.Client do
  @moduledoc false

  use Ecto.Schema

  alias Crebito.Accounts.Transaction

  @type t() :: %__MODULE__{}

  schema "clients" do
    field :limit, :integer
    field :opening_balance, :integer
    field :current_balance, :integer
    has_many :transactions, Transaction

    timestamps(type: :utc_datetime)
  end
end
