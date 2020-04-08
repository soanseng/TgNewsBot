import Config

# Configure your database
config :tw_mind_bot, TwMindBot.Repo,
  username: "postgres",
  password: "postgres",
  database: "tw_mind_bot_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tw_mind_bot, TwMindBotWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
