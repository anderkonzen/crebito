defmodule Crebito.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :limit, :integer
      add :opening_balance, :integer
      add :current_balance, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
