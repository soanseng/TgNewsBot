defmodule TwMindBot.Account do
  import Ecto.Query
  import Ecto.Changeset

  alias TwMindBot.Repo
  alias TwMindBot.User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert
  end

  def check_user?(id) do
    Repo.get_by(User, telegram_id: id) != nil
  end

  def get_all_with_webs() do
    Repo.all(User) |> Repo.preload(:webs)
  end


  def get_all_with_twitters() do
    Repo.all(User) |> Repo.preload([:twitters, :twitter_lists])
  end

end
