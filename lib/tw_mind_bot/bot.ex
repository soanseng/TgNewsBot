defmodule TwMindBot.Bot do
  alias TwMindBot.Account
  alias TwMindBot.Subscription

  def add_user(from_id, username, is_bot ) do

    if Account.check_user?(from_id) do
      "welcome back #{ username }"
    else
      case Account.create_user(
            %{telegram_id: from_id,
              username: username,
              is_bot: is_bot
            }) do
        {:ok, _user} -> "welcome #{ username }, now you can start use this bot"
        {:error, changeset} -> "Sorry #{ username }, #{changeset.errors}"
      end
    end
  end

  def add_rss(from_id, url, entryname) do
    case Subscription.create_rss(from_id, %{entryname: entryname, url: url}) do
      {:ok, _rss} ->  "your subscription is #{entryname}: #{url}"
      {:error, _changeset} ->"something goes wrong, please try again"
    end
  end

  def list_rss(from_id) do
    Subscription.list_rss(from_id)
    |> Enum.map(fn web -> "- #{web.entryname} is #{web.url}" end)
    |> Enum.join("\n")
  end

  def remove_rss(from_id, entryname) do
    case Subscription.remove_rss(from_id, entryname) do
      {:ok, rss} -> "The rss feed: #{rss.entryname} is deleted"
      {:error, _changeset } -> "something goes wrong, please try again"
    end
  end

  def fetch_rss(from_id, entryname, count) do
    rss = Subscription.get_rss(from_id, entryname)
    case HTTPoison.get!(rss.url).body |> Fiet.parse do
      {:ok, data } ->
        Subscription.update_rss_time(from_id, entryname)
        Enum.take(data.items, count)

      {:error, _reason} -> "something goes wrong about this feed"
    end
  end

  def update_all_feeds() do
    #update all users
    users = Account.get_all_with_webs


    Enum.map(users, fn user ->
      from_id = user.telegram_id
      feeds = Subscription.list_rss(from_id)
      update_list = Enum.map(feeds, fn feed -> update_feed(from_id, feed) end)
      |> Enum.concat |> Enum.uniq

      Enum.each(feeds, fn feed ->
        Subscription.update_rss_time(from_id, feed.entryname)
      end)
      %{from_id: from_id, update_list: update_list}
    end)
  end

  # {from_id, update_list}
  def send_update_feeds() do
    updates = update_all_feeds()
    Enum.each(updates, fn update ->
      if update.update_list != [] do
        Enum.each(update.update_list, fn message ->
          Nadia.send_message(update.from_id, "#{message.title}\n\n#{message.link}" )
        end)
      end
    end)
  end

  ### twitter setting
  ###
  def add_twitter(from_id, account) do
    user = try do
             !!ExTwitter.user(account)
           rescue
              _e -> false
           end

    if user do
      case Subscription.create_twitter(from_id, %{screen_name: account}) do
        {:ok, twitter} ->  "your subscription is @#{twitter.screen_name}"
        {:error, _changeset} ->"something goes wrong, please try again"
      end
    else
      "There is no account"
    end

  end

  def remove_twitter(from_id, account) do
    case Subscription.remove_twitter(from_id, account) do
      {:ok, twitter} -> "The twitter account: #{twitter.screen_name} is deleted"
      {:error, _changeset } -> "something goes wrong, please try again"
    end
  end


  def add_twitter_list(from_id, owner_name, list_name) do

    list = try do
             !!ExTwitter.request(:get, "1.1/lists/show.json", [slug: list_name, owner_screen_name: owner_name])
           rescue
              _e -> false
           end
    if list do
      case Subscription.create_twitter_list(from_id, %{owner_name: owner_name, slug: list_name}) do
        {:ok, twitter_list} ->  "your subscription is @#{twitter_list.owner_name}'s #{twitter_list.slug}"
        {:error, _changeset} ->"something goes wrong, please try again"
      end
    else
      "This list is not exist"
    end
  end
 

  def remove_twitter_list(from_id, owner_name, list_name) do
    case Subscription.remove_twitter_list(from_id, %{owner_name: owner_name, slug: list_name}) do
      {:ok, twitter_list} -> "The twitter list: #{twitter_list.owner_name}'s #{twitter_list.slug} is deleted"
      {:error, _changeset } -> "something goes wrong, please try again"
    end
  end

  @doc """
    %{twitter: user.twitters, lists: user.twitter_lists}
  """
  def list_twitter(from_id) do
    map = Subscription.list_twitter(from_id)
    list1 = Enum.map(map.twitters, fn twitter ->  "you subscribe @#{twitter.screen_name}" end)
    list2 = Enum.map(map.lists, fn twitter ->  "you subscribe @#{twitter.owner_name}/#{twitter.slug} list" end)
    List.flatten([list1, list2])
    |> Enum.join("\n")
  end


  @doc """
  twitter is %{username: "", slug: ""}
  """
  def fetch_twitter(from_id, twitter, count, type \\ :personal) do
    case type do
      :personal ->
        data = Subscription.get_twitter(from_id, twitter.username)
        try do
          ExTwitter.user_timeline(screen_name: data.screen_name, count: count)
          |> Enum.map(fn data -> data.text end)
        rescue
          _e -> "sorry, there is no account"
        end
      :list ->
        data = Subscription.get_twitter_list(from_id, twitter.username, twitter.slug)
        try do
          ExTwitter.list_timeline(data.slug, data.owner_name, count: count)
          |> Enum.map(fn data -> data.text end)
        rescue
          _e -> "sorry, there is no list"
        end
    end
  end


  def update_all_tweets() do
    # #update all users
    users = Account.get_all_with_twitters

    Enum.map(users, fn user ->
      from_id = user.telegram_id
      # %{twitters: user.twitters, lists: user.twitter_lists}
      data = Subscription.list_twitter(from_id)
      update_list = [Enum.map(data.twitters, fn tw -> update_twitter(from_id, tw, :person) end) |
      Enum.map(data.lists, fn tw -> update_twitter(from_id, tw, :list) end)]
      |> List.flatten |> Enum.uniq

      %{from_id: from_id, update_list: update_list}
    end)
  end


  def send_update_tweets() do
    updates = update_all_tweets()
    Enum.each(updates, fn update ->
      if update.update_list != [] do
        Enum.each(update.update_list, fn message ->
          Nadia.send_message(update.from_id, "#{message.text} from @#{message.user.name}")
        end)
      end
    end)
  end

  #scihub
  def get_paper(doi) do
    baseURL = "https://sci-hub.tw/"

    {:ok, result} = HTTPoison.get(baseURL <> doi)
    if result.body != "" do
      {:ok, document} = Floki.parse_document(result.body)
      #"location.href='//sci-hub.tw/downloads-ii/2020-02-28/ec/oup-accepted-manuscript-2020.pdf?download=true'"
        string = Floki.find(document, "div#buttons > ul > li > a") |> Floki.attribute("onclick") |> Floki.text
        %{"loc"=> loc} = Regex.named_captures(~r/location.href='(?<loc>.+)\?download=true'/, string)
        {:ok, "https:#{loc}"}

    else
      {:error, "I don't have this article"}
    end
  end


  # private method

  defp update_feed(from_id, feed) do
    case HTTPoison.get!(feed.url).body |> Fiet.parse do
      {:ok, data } ->
        Enum.filter(data.items, fn item -> filter_new_feed?(item, feed) end)

      {:error, _reason} -> "something goes wrong about this feed"
    end
  end

  @doc """
  %Fiet.Item{
  description: "Workplace consultant Guenaelle Watson gives seven tips for better video meetings.",
  id: "https://www.bbc.co.uk/news/business-52009076",
  link: "https://www.bbc.co.uk/news/business-52009076",
  published_at: "Tue, 24 Mar 2020 00:51:23 GMT",
  title: "Remote working: Seven tips for successful video meetings"
  }
  return -1, 0, 1
  """
  def filter_new_feed?(fiet_item, feed) do
    post_time = Timex.parse!(fiet_item.published_at, "{RFC1123}") |> Timex.to_naive_datetime
    Timex.compare(post_time, feed.last_update) == 1
  end

  @doc """
  loading from changeset, check if since_id there;
  get all tweets from there, and update since_id;
  if it is first time, no since_idl then get 5 items, update the since_id
  """
  def update_twitter(from_id, twitter, :person) do
    timeline =
    if twitter.since_id == nil do
      ExTwitter.user_timeline(screen_name: twitter.screen_name, count: 5)
    else
      ExTwitter.user_timeline(screen_name: twitter.screen_name, since_id: twitter.since_id)
    end
    try do
      new_id = Kernel.hd(timeline).id
      Subscription.update_twitter_time(from_id, twitter.screen_name, new_id)
      timeline
    rescue
      _e -> []
    end
  end


  def update_twitter(from_id, twitter, :list) do
    timeline = if twitter.since_id == nil do
      ExTwitter.list_timeline(twitter.slug, twitter.owner_name, count: 5)
    else
      ExTwitter.list_timeline(twitter.slug, twitter.owner_name, since_id: twitter.since_id)
    end
    try do
      new_id = timeline |> Kernel.hd |> Map.get(:id)
      Subscription.update_list_time(from_id, twitter.owner_name, twitter.slug, new_id)
      timeline
    rescue
      _e -> []
    end
  end
end
