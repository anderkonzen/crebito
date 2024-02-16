defmodule Crebito.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :value, :integer
      add :type, :string
      add :description, :string
      add :client_id, references(:clients, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:client_id])
  end
end
