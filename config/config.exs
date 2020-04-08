# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tw_mind_bot,
  ecto_repos: [TwMindBot.Repo]

# Configures the endpoint
config :tw_mind_bot, TwMindBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BLXWuAIh4zqRjlkVbUsNllxm3R5EbNW3anD1cVcPMyTlel5AdjHPJP7LTtE8oY8W",
  render_errors: [view: TwMindBotWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TwMindBot.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "bLitRLmY"]

# Configures Elixir's Logger
# config :logger, :console,
#   format: "$time $metadata[$level] $message\n",
#   metadata: [:request_id]
config :logger, level: :debug

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason



#setup cronjob
config :tw_mind_bot, TwMindBot.Scheduler, jobs: [
# {"* * * * *", fn -> File.write!("task.txt", "#{Timex.now}\n", [:append]) end }
  {"*/30 * * * *", {TwMindBot.Bot, :send_update_feeds, []} },
  {"*/30 * * * *", {TwMindBot.Bot, :send_update_tweets, []} },
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
