defmodule TwMindBot.Twitter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "twitters" do
    field :twitter_id, :integer
    field :screen_name, :string
    field :since_id, :integer
    belongs_to :user, TwMindBot.User

    timestamps()
  end

  @doc false
  def changeset(twitter, attrs) do
    twitter
    |> cast(attrs, [:twitter_id, :screen_name, :since_id])
    |> validate_required([:screen_name])
    |> unique_constraint(:screen_name)
  end
end
