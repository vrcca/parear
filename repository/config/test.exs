use Mix.Config

config :repository, Repository.Parear.Repo,
  database: "parear_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
