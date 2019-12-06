use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :portal, Portal.Endpoint,
  http: [port: 4002],
  server: false

# Configure your database
config :datastore, Datastore.Repo,
  username: "postgres",
  password: "postgres",
  database: "datastore_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
