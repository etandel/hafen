defmodule Hafen.Repo do
  use Ecto.Repo,
    otp_app: :hafen,
    adapter: Ecto.Adapters.Postgres
end
