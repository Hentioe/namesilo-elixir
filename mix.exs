defmodule NameSilo.MixProject do
  use Mix.Project

  @version "0.1.0-dev"

  def project do
    [
      app: :name_silo,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NameSilo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:ex_doc, "~> 0.23.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:elixir_xml_to_map, "~> 2.0"},
      {:httpoison, "~> 1.8"},
      {:typed_struct, "~> 0.2.1"},
      {:atomic_map, "~> 0.9.3"}
    ]
  end
end
