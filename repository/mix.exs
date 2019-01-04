defmodule Repository.MixProject do
  use Mix.Project

  def project do
    [
      app: :repository,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Repository.Application, []},
      extra_applications: [:logger],
      included_applications: [:parear]
    ]
  end

  defp deps do
    [
      {:parear, [path: "../parear"]},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
