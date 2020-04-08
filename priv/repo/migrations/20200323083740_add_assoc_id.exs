defmodule TwMindBot.Repo.Migrations.AddAssocId do
  use Ecto.Migration

  def change do
    alter table(:webs) do
      add :user_id, references(:users)
    end

    alter table(:twitters) do
      add :user_id, references(:users)
    end
  end
end
