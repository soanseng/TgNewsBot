defmodule TwMindBot.Repo.Migrations.AddTwiScreenName do
  use Ecto.Migration

  def change do
    alter table(:twitters) do
      modify :twitter_id, :bigint
      add :screen_name, :string
      add :since_id, :bigint
    end


    create table(:twitter_lists) do
      add :slug, :string
      add :owner_name, :string
      add :since_id, :bigint
      add :user_id, references(:users)
      timestamps()
    end

  end
end
