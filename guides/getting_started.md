# Getting Started

This guide introduces `Intl`, an Elixir interface modelled on the [JavaScript Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl) and backed by the [Localize](https://hexdocs.pm/localize) library.

## Installation

Add `intl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:intl, "~> 0.1.0"}
  ]
end
```

Word and sentence segmentation require the optional `unicode_string` dependency:

```elixir
{:unicode_string, "~> 1.8"}
```

## Locale data

`Intl` delegates to `Localize` for locale data. The `:en` locale is always available. To use other locales, either pre-download their data at build time:

```bash
mix localize.download_locales de fr ja
```

Or enable runtime downloading in `config/runtime.exs`:

```elixir
config :localize, :allow_runtime_locale_download, true
```

Locale data is loaded lazily into `:persistent_term` on first access. See the [Localize documentation](https://hexdocs.pm/localize) for full configuration details.

## Key conventions

If you know the JS Intl API, these are the adaptations to keep in mind:

* **Functional style, no constructors.** JS creates formatter instances with `new Intl.NumberFormat(locale, options)`. Elixir passes options directly: `Intl.NumberFormat.format(number, options)`.

* **snake_case options.** JS `minimumFractionDigits` becomes `:minimum_fraction_digits`.

* **Tagged return tuples.** All functions return `{:ok, result}` or `{:error, reason}`. Bang variants (`format!/2`) raise on error.

* **Collator returns atoms.** `Intl.Collator.compare/3` returns `:lt`, `:eq`, or `:gt` (compatible with `Enum.sort/2`) instead of -1, 0, or 1.

## Available modules

| Module | JS Intl Equivalent | Purpose |
|---|---|---|
| `Intl.NumberFormat` | `Intl.NumberFormat` | Numbers, currency, percent, unit |
| `Intl.DateTimeFormat` | `Intl.DateTimeFormat` | Dates, times, date-time ranges |
| `Intl.ListFormat` | `Intl.ListFormat` | List joining with conjunctions/disjunctions |
| `Intl.DisplayNames` | `Intl.DisplayNames` | Localized names for regions, languages, scripts, currencies, calendars |
| `Intl.RelativeTimeFormat` | `Intl.RelativeTimeFormat` | Relative time strings ("3 days ago") |
| `Intl.PluralRules` | `Intl.PluralRules` | CLDR plural category selection |
| `Intl.Collator` | `Intl.Collator` | Locale-aware string comparison and sorting |
| `Intl.DurationFormat` | `Intl.DurationFormat` | Localized duration formatting |
| `Intl.Segmenter` | `Intl.Segmenter` | Grapheme, word, sentence segmentation |

Plus two top-level functions on the `Intl` module:

* `Intl.get_canonical_locales/1` — canonicalize BCP 47 locale tags.

* `Intl.supported_values_of/1` — discover available calendars, currencies, numbering systems, and units.

## A first example

```elixir
iex> Intl.NumberFormat.format(1234.5, locale: :en, style: :currency, currency: :USD)
{:ok, "$1,234.50"}

iex> Intl.DateTimeFormat.format(~D[2025-03-15], locale: :en, date_style: :full)
{:ok, "Saturday, March 15, 2025"}

iex> Intl.ListFormat.format(["Monday", "Tuesday", "Wednesday"], locale: :en)
{:ok, "Monday, Tuesday, and Wednesday"}
```

## Next steps

* Read the [Compatibility](compatibility.html) guide for a detailed matrix of JS Intl features and their status in this library.

* Read the [Comparison with Localize](comparison_with_localize.html) guide to understand what Localize provides beyond the Intl API surface (message formatting, unit conversion, territory metadata, etc.).

* Browse the module docs for per-module option reference and examples.
