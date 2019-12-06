defmodule Datastore.Repo do
  use Ecto.Repo,
    otp_app: :datastore,
    adapter: Ecto.Adapters.Postgres
end
