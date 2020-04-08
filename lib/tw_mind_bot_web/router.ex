defmodule TwMindBotWeb.Router do
  use TwMindBotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TwMindBotWeb do
    pipe_through :api
    post "/rss", RssController, :index
  end
end
