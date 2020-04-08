defmodule TwMindBot.Repo.Migrations.ChangeBig do
  use Ecto.Migration

  def change do

    alter table(:users) do
      modify :telegram_id, :bigint
    end
  end
end
