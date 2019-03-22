defmodule Parear.MixProject do
  use Mix.Project

  def project do
    [
      app: :parear,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger],
      mod: {Parear.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:mox, "~> 0.5", only: :test}
    ]
  end
end
