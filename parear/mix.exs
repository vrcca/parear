defmodule Parear.MixProject do
  use Mix.Project

  def project do
    [
      app: :parear,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/parear/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger],
      mod: {Parear.Application, []}
    ]
  end

  defp deps do
    [{:elixir_uuid, "~> 1.2"}]
  end
end