defmodule WhereTZ.MixProject do
  use Mix.Project

  def project do
    [
      app: :wheretz,
      description: "Time zone by geo coordinates lookup",
      version: "0.1.0",
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
      {:excoveralls, "~> 0.12.1", only: :test},
      {:inch_ex, "~> 2.0", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
    ]
  end

  defp aliases do
    [
      compile: ["compile"],
      test: ["test"]
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
