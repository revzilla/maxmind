defmodule Maxmind.Mixfile do
  use Mix.Project

  def project do
    [
      app: :maxmind,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: true
      ],
      docs: [extras: ["README.md"]],
      description: "Elixir client for Maxmind's Minfraud API",
      elixir: "~> 1.3",
      homepage_url: "https://github.com/revzilla/maxmind_minfraud",
      name: "Maxmind Minfraud",
      package: package(),
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.html": :test],
      source_url: "https://github.com/bleacherreport/plug_logger_json",
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "1.0.0",
    ]
  end

  def application do
    [applications: [:httpoison, :exconstructor, :iconv]]
  end

  defp deps do
    [
      {:bypass, "~> 0.8.0", only: [:test]},
      {:credo, "~> 0.8.6", only: [:dev]},
      {:dialyxir,    "~> 0.5.1",  only: [:dev]},
      {:exconstructor, "~> 1.1.0"},
      {:excoveralls, "~> 0.7.3", only: [:test]},
      {:httpoison, "~> 0.13.0"},
      {:iconv, "~> 1.0.5"},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/revzilla/maxmind_minfraud"},
      maintainers: ["Revzilla"]
    ]
  end
end
