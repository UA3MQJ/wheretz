defmodule WhereTZ.MixProject do
  use Mix.Project

  def project do
    [
      app: :wheretz,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:timex, "~> 3.6"},
      {:geo, "~> 3.3"},
      # {:topo, path: "../topo"}, # for debug
      {:topo, "~> 0.4.0"},
      # {:gnuplot, git: "git@github.com:devstopfix/gnuplot-elixir.git"}, # for debug
      {:excoveralls, "~> 0.12.1"},
      {:inch_ex, only: :docs},
    ]
  end
end
