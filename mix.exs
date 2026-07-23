defmodule Intl.MixProject do
  use Mix.Project

  @version "1.0.0-rc.0"

  def project do
    [
      app: :intl,
      version: @version,
      name: "Intl",
      source_url: "https://github.com/elixir-cldr/intl",
      docs: docs(),
      deps: deps(),
      description: description(),
      package: package(),
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_add_apps: ~w(mix)a
      ]
    ]
  end

  def description do
    "An Elixir interface to internationalization functions modelled on " <>
      "the JavaScript Intl API. Delegates to the Localize library for " <>
      "locale-aware formatting of numbers, dates, lists, durations, and more."
  end

  def package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
      links: links(),
      files: [
        "lib",
        "mix.exs",
        ".formatter.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*"
      ]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/elixir-cldr/intl",
      "Readme" => "https://hexdocs.pm/intl/readme.html",
      "Changelog" => "https://hexdocs.pm/intl/changelog.html"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      formatters: ["html", "markdown"],
      extras:
        [
          "README.md",
          "LICENSE.md",
          "CHANGELOG.md"
        ] ++ Path.wildcard("guides/*.md"),
      groups_for_modules: groups_for_modules(),
      groups_for_extras: groups_for_extras(),
      skip_undefined_reference_warnings_on:
        [
          "CHANGELOG.md"
        ] ++ Path.wildcard("guides/*.md")
    ]
  end

  def groups_for_modules do
    [
      Formatting:
        ~r/^Intl\.(NumberFormat|DateTimeFormat|ListFormat|RelativeTimeFormat|DurationFormat)$/,
      "Display Names": ~r/^Intl\.DisplayNames$/,
      Linguistic: ~r/^Intl\.(Collator|PluralRules|Segmenter)$/
    ]
  end

  defp groups_for_extras do
    [
      Guides: [
        "guides/getting_started.md",
        "guides/compatibility.md",
        "guides/comparison_with_localize.md"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:localize, "~> 1.0-rc.3"},
      {:unicode_string, "~> 2.3", optional: true},
      {:ex_doc, "~> 0.34", only: [:dev, :release], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ] ++ maybe_json_polyfill()
  end

  defp maybe_json_polyfill do
    if Code.ensure_loaded?(:json) do
      []
    else
      [{:json_polyfill, "~> 0.2 or ~> 1.0"}]
    end
  end
end
