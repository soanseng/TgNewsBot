defmodule TwMindBot.Subscription do
  import Ecto.Query
  import Ecto.Changeset

  alias TwMindBot.Repo
  alias TwMindBot.User
  alias TwMindBot.Web
  alias TwMindBot.Twitter
  alias TwMindBot.TwitterList

  def create_rss(telegram_id, attrs \\ %{}) do
    user = Repo.get_by(User, telegram_id: telegram_id) |> Repo.preload(:webs)

    %Web{}
    |> Web.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert

  end

  def list_rss(telegram_id) do
    user = Repo.get_by(User, telegram_id: telegram_id) |> Repo.preload(:webs)
    user.webs
  end

  def get_rss(telegram_id, entryname) do
    user = Repo.get_by(User, telegram_id: telegram_id)
    Repo.get_by(Web, entryname: entryname, user_id: user.id )
  end

  def update_rss_time(telegram_id, entryname) do
    rss = get_rss(telegram_id, entryname)
    update = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    Ecto.Changeset.change(rss, last_update: update)
    |> Repo.update!
  end

  def remove_rss(telegram_id, entryname) do
    user = Repo.get_by(User, telegram_id: telegram_id)
    Repo.get_by(Web, entryname: entryname, user_id: user.id )
    |> Repo.delete
  end

  def create_twitter(telegram_id, attrs \\%{}) do
    user = Repo.get_by(User, telegram_id: telegram_id) |> Repo.preload(:twitters)
    # check if this accound exist
    %Twitter{}
    |> Twitter.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert
  end

  def get_twitter(telegram_id, username) do
    user = Repo.get_by(User, telegram_id: telegram_id)
    Repo.get_by(Twitter, screen_name: username, user_id: user.id )
  end

  def remove_twitter(telegram_id, account \\%{}) do
    user = Repo.get_by(User, telegram_id: telegram_id)
    Repo.get_by(Twitter, screen_name: account, user_id: user.id)
    |> Repo.delete
  end

  def create_twitter_list(telegram_id, attrs \\%{}) do
    user = Repo.get_by(User, telegram_id: telegram_id) |> Repo.preload(:twitter_lists)


    %TwitterList{}
    |> TwitterList.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert
  end


  def get_twitter_list(telegram_id, username, slug) do
    user = Repo.get_by(User, telegram_id: telegram_id)
    Repo.get_by(TwitterList, owner_name: username, slug: slug, user_id: user.id )
  end


  def remove_twitter_list(telegram_id, list \\%{ }) do
    user = Repo.get_by(User, telegram_id: telegram_id)
    Repo.get_by(TwitterList, owner_name: list.owner_name, slug: list.slug , user_id: user.id)
    |> Repo.delete
  end

  def list_twitter(telegram_id) do
    query = from u in User, preload: [:twitters, :twitter_lists], where: u.telegram_id == ^telegram_id
    user = Repo.one(query)
    %{twitters: user.twitters, lists: user.twitter_lists}
  end


  def update_twitter_time(telegram_id, owner, since_id) do
    twitter = get_twitter(telegram_id, owner)
    Ecto.Changeset.change(twitter, since_id: since_id)
    |> Repo.update!
  end


  def update_list_time(telegram_id, owner, slug, since_id) do
    twitter = get_twitter_list(telegram_id, owner, slug)
    Ecto.Changeset.change(twitter, since_id: since_id)
    |> Repo.update!
  end





end
