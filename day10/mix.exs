defmodule Day10.MixProject do
  use Mix.Project

  def project do
    [
      app: :day10,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      # Specify runtime application configuration here
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:aja, "~> 0.6.2"}
    ]
  end
end
