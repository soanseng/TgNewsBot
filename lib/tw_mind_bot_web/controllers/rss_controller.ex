defmodule TwMindBotWeb.RssController do
  use TwMindBotWeb, :controller
  alias TwMindBot.Bot

  @doc  """
  check the user exist or not;
  if not add this user into database;
  if existed, prin welcome back
  """
  def index(conn, %{"message" => %{"from" => %{"id" => from_id, "username" => username, "is_bot" => is_bot },
                                 "text" => "/start" <> _rest }}) do
    message = Bot.add_user(from_id, username, is_bot)
    send_back(conn, from_id, message)
  end


  @doc """
  /sub with url and entryname
  """
  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/sub" <> " " <> rest }}) do
    message = try do
                [url, entryname] = String.split(rest, " ", trim: true)
                Bot.add_rss(from_id, url, entryname)

              rescue
                _e -> "please follow the instruction"

              end

    send_back(conn, from_id, message)
  end


  @doc """
  list all rss feeds
  """
  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/listrss" <>_rest }}) do
    message = Bot.list_rss(from_id)
    send_back(conn, from_id, message)
  end

  @doc """
  remove rss by its entryname
  """
  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/removerss" <> " " <> entryname }}) do
    message = Bot.remove_rss(from_id, entryname)
    send_back(conn, from_id, message)
  end


  @doc """
  manual fetch specific rss, and then update the last_update time
  """
  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/fetchrss" <> " " <> rest }}) do

    [entryname, count] = String.split(rest, " ", trim: true)
    messages = try do
                 Bot.fetch_rss(from_id, entryname, String.to_integer(count))
                 # send list of messageds to user
               rescue
                 e -> "please enter number 1 to 10"
               end

    if is_list(messages) do
      Enum.each(messages, fn message ->
        Nadia.send_message(from_id, "#{message.title}\n\n#{message.link}")
      end)
    else
      Nadia.send_message(from_id, messages)
    end
    json(conn, %{})
  end


  #### twitter part
  #### list twitter, fetch specifiic twitter, and update
  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/addtwitter" <> " " <> account }}) do
    message = Bot.add_twitter(from_id, account)
    send_back(conn, from_id, message)
  end

  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/addtwlist" <> " " <> list }}) do
    message = try do
                [screen_name, slug] = String.split(list, "/", trim: true)
                Bot.add_twitter_list(from_id, screen_name, slug)
              rescue
                _e -> "please eneter: username/listname for subscribe"
              end
    send_back(conn, from_id, message)
  end


  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/removetw" <> " " <> account }}) do
    message = Bot.remove_twitter(from_id, account)
    send_back(conn, from_id, message)
  end


  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/rmtwlist" <> " " <> list }}) do
    message = try do
                [screen_name, slug] = String.split(list, "/", trim: true)
                Bot.remove_twitter_list(from_id, screen_name, slug)
              rescue
                _e -> "please eneter: username/listname for subscribe"
              end
    send_back(conn, from_id, message)
  end


  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/listtwitter" <>_rest }}) do
    message = Bot.list_twitter(from_id)
    send_back(conn, from_id, message)
  end


  def index(conn, %{"message" => %{"from" => %{"id" => from_id},
                                 "text" => "/doi" <> " " <> doi }}) do
    case Bot.get_paper(doi) do
      {:ok, document} ->
        Nadia.send_message(from_id, "I have this article!!")
        Nadia.send_document(from_id, document)
      {:error, message} ->
        Nadia.send_message(from_id, message)
    end
    json(conn, %{})
  end


  @doc """
  fallback reply
  """
  def index(conn, %{"message" => %{"from" => %{"id" => from_id}, "text" => _text}}) do
    message = "hello, I don't understand your instruction, please try again"
    send_back(conn, from_id, message)
  end


  @doc """
  fallback helper
  """
  def index(conn, _others) do
    json(conn, %{})
  end



  defp send_back(conn, from_id, message) do
    Nadia.send_message(from_id, message)
    json(conn, %{})
  end
end
