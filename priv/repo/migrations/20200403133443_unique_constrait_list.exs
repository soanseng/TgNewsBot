defmodule TwMindBot.Repo.Migrations.UniqueConstraitList do
  use Ecto.Migration

  def change do
    create unique_index(:twitter_lists, [:owner_name, :slug], name: :twttier_list_owner_slug_index)
  end
end
