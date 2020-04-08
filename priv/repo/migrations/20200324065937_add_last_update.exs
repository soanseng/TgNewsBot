defmodule TwMindBot.Repo.Migrations.AddLastUpdate do
  use Ecto.Migration

  def change do

    alter table(:webs) do
      add :last_update, :naive_datetime
    end

  end
end
