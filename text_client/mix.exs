defmodule TextClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :text_client,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {TextClient.Application, []}
    ]
  end

  defp deps do
    [
      {:repository, path: "../repository"},
      {:parear, path: "../parear"}
    ]
  end

  defp aliases do
    [
      start: ["deps.get", "run -e TextClient.start()"]
    ]
  end
end
