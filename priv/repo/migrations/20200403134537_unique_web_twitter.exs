defmodule TwMindBot.Repo.Migrations.UniqueWebTwitter do
  use Ecto.Migration

  def change do
    create unique_index(:twitters, [:screen_name])
    create unique_index(:webs, [:url])

  end
end
