defmodule Repository.MixProject do
  use Mix.Project

  def project do
    [
      app: :repository,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Repository.Application, []},
      extra_applications: [:logger, :parear, :ecto_sql, :postgrex]
    ]
  end

  defp deps do
    [
      {:parear, in_umbrella: true},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
