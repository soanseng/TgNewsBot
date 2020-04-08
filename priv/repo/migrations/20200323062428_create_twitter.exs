defmodule TwMindBot.Repo.Migrations.CreateTwitter do
  use Ecto.Migration

  def change do
    create table(:twitters) do
      add :twitter_id, :integer
      timestamps()
    end

  end
end
