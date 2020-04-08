defmodule TwMindBot.TwitterList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "twitter_lists" do
    field :owner_name, :string
    field :slug, :string
    field :since_id, :integer
    belongs_to :user, TwMindBot.User

    timestamps()
  end

  @doc false
  def changeset(twitter, attrs) do
    twitter
    |> cast(attrs, [:slug, :owner_name, :since_id])
    |> validate_required([:owner_name, :slug])
    |> unique_constraint(:slug, name: :twttier_list_owner_slug_index)
  end
end
