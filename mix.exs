defmodule WhereTZ.MixProject do
  use Mix.Project

  def project do
    [
      app: :wheretz,
      description: "Time zone by geo coordinates lookup",
      version: "0.1.16",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps(),
      package: package(),
      aliases: aliases(),
      # Docs
      name: "WhereTZ",
      source_url: "https://github.com/UA3MQJ/wheretz",
      homepage_url: "https://github.com/UA3MQJ/wheretz",
      docs: [
        main: "WhereTZ", # The main page in the docs
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {WhereTZ.Application, []},
      extra_applications: [:logger],
      included_applications: [:mnesia]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.6"},
      {:geo, "~> 3.3"},
      # {:topo, path: "../topo"}, # for debug
      {:topo, "~> 0.4.0"},
      # {:gnuplot, git: "git@github.com:devstopfix/gnuplot-elixir.git"}, # for debug
      {:excoveralls, "~> 0.12.3", only: :test},
      # Docs dependencies
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:inch_ex, "~> 2.0", only: :docs},
      {:httpoison, "~> 2.1"},
    ]
  end

  defp aliases do
    [
      compile: ["compile"],
      test: ["download_data", "test"]
    ]
  end

  defp package do
    [
      maintainers: [" Alexey Bolshakov "],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/UA3MQJ/wheretz"}
    ]
  end
end
