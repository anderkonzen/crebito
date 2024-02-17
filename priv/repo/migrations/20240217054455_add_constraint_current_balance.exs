defmodule Crebito.Repo.Migrations.AddConstraintCurrentBalance do
  use Ecto.Migration

  def up do
    create constraint("clients", :current_balance_within_limit,
             check: "abs(current_balance) < \"limit\""
           )
  end

  def down do
    drop constraint("clients", :current_balance_within_limit)
  end
end
