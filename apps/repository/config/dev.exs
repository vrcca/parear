use Mix.Config

config :repository, Repository.Parear.Repo,
  database: "parear_db",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :parear, repository: Repository.ParearEctoRepository
config :parear, participant_repository: Repository.ParticipantEctoRepository
