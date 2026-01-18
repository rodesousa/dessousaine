defmodule Dessousaine.Repo do
  use Ecto.Repo,
    otp_app: :dessousaine,
    adapter: Ecto.Adapters.Postgres
end
