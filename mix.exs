defmodule Intl.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :intl,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      name: "Intl",
      source_url: "https://github.com/elixir-cldr/intl",
      description: description(),
      package: package(),
      dialyzer: [
        plt_add_apps: ~w(mix)a
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    An Elixir interface to internationalization functions modelled on
    the JavaScript Intl API. Delegates to the Localize library for
    locale-aware formatting of numbers, dates, lists, durations, and
    more.
    """
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/elixir-cldr/intl",
        "Changelog" => "https://github.com/elixir-cldr/intl/blob/v#{@version}/CHANGELOG.md",
        "Readme" => "https://github.com/elixir-cldr/intl/blob/v#{@version}/README.md"
      },
      files: [
        "lib",
        ".formatter.exs",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE.md",
        "compatibility.md",
        "intl_vs_localize.md"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      logo: "logo.png",
      formatters: ["html", "markdown"],
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE.md",
        "compatibility.md",
        "intl_vs_localize.md"
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md", "intl_vs_localize.md"]
    ]
  end

  defp deps do
    [
      {:localize, "~> 0.14.0"},
      {:unicode_string, "~> 1.8", optional: true},
      {:ex_doc, "~> 0.34", only: [:dev, :release], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
