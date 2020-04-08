defmodule TwMindBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :telegram_id, :integer
      add :is_bot, :boolean, default: false, null: false
      add :is_active, :boolean, default: false, null: false

      timestamps()
    end

  end
end
