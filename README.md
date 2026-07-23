# Intl

An Elixir interface to internationalization functions modelled on the [JavaScript Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl).

If you are familiar with the JS Intl API, you already know how to use this library. The module names, function purposes, and option names mirror their JS counterparts — adapted to idiomatic Elixir conventions (snake_case, keyword options, `{:ok, result}` / `{:error, reason}` tuples).

## Relationship to Localize

`Intl` is a thin shim over the [Localize](https://hexdocs.pm/localize) library which provides the full CLDR-based locale data and formatting engine. Each `Intl` module translates JS Intl option names and conventions into the corresponding `Localize` calls:

* `Intl.NumberFormat` delegates to `Localize.Number` and `Localize.Unit`.

* `Intl.DateTimeFormat` delegates to `Localize.DateTime`, `Localize.Date`, `Localize.Time`, and `Localize.Interval`.

* `Intl.ListFormat` delegates to `Localize.List`.

* `Intl.DisplayNames` delegates to `Localize.Territory`, `Localize.Language`, `Localize.Currency`, and `Localize.Script`.

* `Intl.RelativeTimeFormat` delegates to `Localize.DateTime.Relative`.

* `Intl.PluralRules` delegates to `Localize.Number.PluralRule`.

* `Intl.Collator` delegates to `Localize.Collation`.

* `Intl.DurationFormat` delegates to `Localize.Duration`.

* `Intl.Segmenter` uses `String.graphemes/1` for grapheme segmentation and the optional `unicode_string` library for word and sentence segmentation.

If you need lower-level control or access to features beyond the Intl API surface (such as unit conversion, message formatting, or calendar metadata), use `Localize` directly.

## Compatibility and Differences

The full compatibility matrix is in [the Compatibility guide](https://hexdocs.pm/intl/compatibility.html). Key points:

* **Functional, not object-oriented.** JS creates formatter instances with `new Intl.NumberFormat(locale, options)`. Elixir passes options directly: `Intl.NumberFormat.format(number, options)`.

* **snake_case options.** JS `minimumFractionDigits` becomes `:minimum_fraction_digits`.

* **Tagged return tuples.** All functions return `{:ok, result}` or `{:error, reason}`. Bang variants (`format!/2`) raise on error.

* **Collator returns atoms.** `Intl.Collator.compare/3` returns `:lt`, `:eq`, or `:gt` instead of -1, 0, or 1.

* **`formatToParts` is supported for numbers** via `Intl.NumberFormat.format_to_parts/2`; the other modules do not yet expose structured parts.

* **`supportedLocalesOf` is one top-level function**, `Intl.supported_locales_of/1`, since all modules share the same CLDR locale data. `resolvedOptions` is not implemented.

* **Segmenter output is simplified.** Returns a flat list of strings rather than the JS iterable of rich segment objects.

## Examples

### Number Formatting

```elixir
iex> Intl.NumberFormat.format(1_234_567.89, locale: :en)
{:ok, "1,234,567.89"}

iex> Intl.NumberFormat.format(1_234_567.89, locale: :de)
{:ok, "1.234.567,89"}

iex> Intl.NumberFormat.format(0.56, locale: :en, style: :percent)
{:ok, "56%"}

iex> Intl.NumberFormat.format(1234.5, locale: :en, style: :currency, currency: :USD)
{:ok, "$1,234.50"}

iex> Intl.NumberFormat.format(1234, locale: :en, style: :currency, currency: :USD, notation: :compact)
{:ok, "$1.2K"}

iex> Intl.NumberFormat.format(-1234.5, locale: :en, style: :currency, currency: :USD, currency_sign: :accounting)
{:ok, "($1,234.50)"}

iex> Intl.NumberFormat.format(1234.5, locale: :en, notation: :scientific)
{:ok, "1.2345E3"}

iex> Intl.NumberFormat.format(1234.5, locale: :en, maximum_significant_digits: 3)
{:ok, "1,230"}

iex> Intl.NumberFormat.format(1234.5, locale: :en, sign_display: :always)
{:ok, "+1,234.5"}

iex> Intl.NumberFormat.format_to_parts(-1234.5, locale: :en)
{:ok, [
  %{type: :minus_sign, value: "-"},
  %{type: :integer, value: "1"},
  %{type: :group, value: ","},
  %{type: :integer, value: "234"},
  %{type: :decimal, value: "."},
  %{type: :fraction, value: "5"}
]}
```

### Date and Time Formatting

```elixir
iex> Intl.DateTimeFormat.format(~D[2025-03-15], locale: :en, date_style: :full)
{:ok, "Saturday, March 15, 2025"}

iex> Intl.DateTimeFormat.format(~D[2025-03-15], locale: :en, date_style: :short)
{:ok, "3/15/25"}
```

### List Formatting

```elixir
iex> Intl.ListFormat.format(["Monday", "Tuesday", "Wednesday"], locale: :en)
{:ok, "Monday, Tuesday, and Wednesday"}

iex> Intl.ListFormat.format(["tea", "coffee", "juice"], locale: :en, type: :disjunction)
{:ok, "tea, coffee, or juice"}

iex> Intl.ListFormat.format(["lundi", "mardi", "mercredi"], locale: :fr)
{:ok, "lundi, mardi et mercredi"}
```

### Display Names

```elixir
iex> Intl.DisplayNames.of("US", type: :region, locale: :en)
{:ok, "United States"}

iex> Intl.DisplayNames.of("DE", type: :region, locale: :fr)
{:ok, "Allemagne"}

iex> Intl.DisplayNames.of("fr", type: :language, locale: :en)
{:ok, "French"}

iex> Intl.DisplayNames.of(:Latn, type: :script, locale: :en)
{:ok, "Latin"}

iex> Intl.DisplayNames.of("JPY", type: :currency, locale: :en)
{:ok, "Japanese Yen"}

iex> Intl.DisplayNames.of(:gregorian, type: :calendar, locale: :en)
{:ok, "Gregorian Calendar"}
```

### Relative Time

```elixir
iex> Intl.RelativeTimeFormat.format(-1, :day, locale: :en)
{:ok, "yesterday"}

iex> Intl.RelativeTimeFormat.format(3, :hour, locale: :en)
{:ok, "in 3 hours"}

iex> Intl.RelativeTimeFormat.format(-3, :day, locale: :fr)
{:ok, "il y a 3 jours"}
```

### Plural Rules

```elixir
iex> Intl.PluralRules.select(1, locale: "en")
{:ok, :one}

iex> Intl.PluralRules.select(5, locale: "en")
{:ok, :other}

iex> Intl.PluralRules.select(2, locale: "ar")
{:ok, :two}
```

### Collation

```elixir
iex> Intl.Collator.compare("ä", "z", locale: :de, sensitivity: :base)
:lt

iex> Intl.Collator.sort(["banana", "apple", "cherry"], locale: :en)
["apple", "banana", "cherry"]
```

### Duration Formatting

```elixir
iex> Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en)
{:ok, "2 hours and 30 minutes"}
```

### Text Segmentation

```elixir
iex> Intl.Segmenter.segment("héllo", granularity: :grapheme)
{:ok, ["h", "é", "l", "l", "o"]}

iex> Intl.Segmenter.segment("Hello world", granularity: :word, trim: true)
{:ok, ["Hello", "world"]}

iex> Intl.Segmenter.segment("Hello. How are you?", granularity: :sentence)
{:ok, ["Hello. ", "How are you?"]}
```

### Locale Utilities

```elixir
iex> Intl.get_canonical_locales(["en-us", "fr-fr"])
{:ok, ["en-US", "fr-FR"]}

iex> {:ok, calendars} = Intl.supported_values_of(:calendar)
iex> :gregorian in calendars
true
```

## Installation

Add `intl` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:intl, "~> 1.0-rc"}
  ]
end
```

Word and sentence segmentation require the optional `unicode_string` dependency:

```elixir
{:unicode_string, "~> 1.8"}
```

## Locale Data

`Intl` delegates to `Localize` for locale data. The `:en` locale is always available. To use other locales, either pre-download their data at build time:

```bash
mix localize.download_locales de fr ja
```

Or enable runtime downloading in `config/runtime.exs`:

```elixir
config :localize, :allow_runtime_locale_download, true
```

Locale data is loaded lazily into `:persistent_term` on first access. See the [Localize documentation](https://hexdocs.pm/localize) for full configuration details.
