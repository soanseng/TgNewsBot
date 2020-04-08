defmodule TwMindBot.Web do
  use Ecto.Schema
  import Ecto.Changeset

  schema "webs" do
    field :url, :string
    field :entryname, :string
    field :last_update, :naive_datetime
    belongs_to :user, TwMindBot.User
    timestamps()
  end

  @doc false
  def changeset(web, attrs) do
    web
    |> cast(attrs, [:url, :entryname, :last_update])
    |> validate_required([:url, :entryname])
    |> unique_constraint(:url)
  end
end
