defmodule TwMindBot.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :is_active, :boolean, default: false
    field :is_bot, :boolean, default: false
    field :telegram_id, :integer
    field :username, :string
    has_many :webs, TwMindBot.Web
    has_many :twitters, TwMindBot.Twitter
    has_many :twitter_lists, TwMindBot.TwitterList

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :telegram_id, :is_bot, :is_active])
    |> validate_required([:username, :telegram_id, :is_bot, :is_active])
  end
end
