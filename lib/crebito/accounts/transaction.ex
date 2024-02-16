defmodule Crebito.Accounts.Transaction do
  @moduledoc false

  use Ecto.Schema

  alias Crebito.Accounts.Client

  @type t() :: %__MODULE__{}

  schema "transactions" do
    field :type, Ecto.Enum, values: [:c, :d]
    field :value, :integer
    field :description, :string
    belongs_to :client, Client

    timestamps(type: :utc_datetime)
  end
end
