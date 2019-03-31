defmodule ParearUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp deps do
    [{:distillery, "~> 2.0"}]
  end

  defp aliases do
    [
      test: "test --exclude integration",
      integration_test: "test --only integration"
    ]
  end
end
