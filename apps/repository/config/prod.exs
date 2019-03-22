use Mix.Config

config :repository, Repository.Parear.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "${DATABASE_URL}",
  database: "",
  ssl: true,
  pool_size: 2

config :parear, repository: Repository.ParearEctoImpl
