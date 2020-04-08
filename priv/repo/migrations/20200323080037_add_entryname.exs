defmodule TwMindBot.Repo.Migrations.AddEntryname do
  use Ecto.Migration

  def change do
    alter table(:webs) do
      add :entryname, :string
    end
  end
end
