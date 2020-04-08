defmodule TwMindBot.Repo.Migrations.CreateWebs do
  use Ecto.Migration

  def change do
    create table(:webs) do
      add :url, :string

      timestamps()
    end

  end
end
