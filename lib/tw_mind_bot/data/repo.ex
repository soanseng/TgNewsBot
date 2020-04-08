defmodule TwMindBot.Repo do
  use Ecto.Repo,
    otp_app: :tw_mind_bot,
    adapter: Ecto.Adapters.Postgres
end
