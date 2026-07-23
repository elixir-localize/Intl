defmodule Intl do
  @moduledoc """
  An Elixir interface to internationalization functions modelled on the
  [JavaScript Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl).

  This module delegates to the `Localize` library for locale-aware
  formatting and provides the top-level `Intl` static methods:
  `get_canonical_locales/1`, `supported_locales_of/1`, and
  `supported_values_of/1`.

  The sub-modules mirror the JS Intl constructors adapted to idiomatic
  Elixir: options are passed as keyword lists, return values use
  `{:ok, result}` / `{:error, reason}` tuples, and bang variants are
  provided for convenience.

  ## Sub-modules

  * `Intl.NumberFormat` — locale-aware number, currency, percent, and unit formatting.

  * `Intl.DateTimeFormat` — locale-aware date and time formatting.

  * `Intl.ListFormat` — locale-aware list joining with conjunctions, disjunctions, or units.

  * `Intl.DisplayNames` — localized display names for regions, languages, and currencies.

  * `Intl.RelativeTimeFormat` — relative time strings such as "3 days ago" or "in 2 hours".

  * `Intl.PluralRules` — plural category selection (zero, one, two, few, many, other).

  * `Intl.Collator` — locale-aware string comparison and sorting.

  * `Intl.DurationFormat` — locale-aware duration formatting.

  * `Intl.Segmenter` — text segmentation into graphemes, words, or sentences.

  """

  @doc """
  Returns canonical locale name strings for the given locale identifiers.

  Parses and canonicalizes each locale string according to BCP 47 /
  RFC 5646 rules.

  ### Arguments

  * `locales` is a locale identifier string or a list of locale
    identifier strings.

  ### Returns

  * `{:ok, list}` where `list` is a list of canonical locale name
    strings.

  * `{:error, reason}` if any locale identifier cannot be parsed.

  ### Examples

      iex> Intl.get_canonical_locales("en-us")
      {:ok, ["en-US"]}

      iex> Intl.get_canonical_locales(["en-us", "fr-FR"])
      {:ok, ["en-US", "fr-FR"]}

  """
  @spec get_canonical_locales(String.t() | [String.t()]) ::
          {:ok, [String.t()]} | {:error, term()}
  def get_canonical_locales(locales) when is_binary(locales) do
    get_canonical_locales([locales])
  end

  def get_canonical_locales(locales) when is_list(locales) do
    results =
      Enum.reduce_while(locales, [], fn locale, accumulator ->
        with {:ok, tag} <- Localize.LanguageTag.parse(locale),
             {:ok, canonical} <- Localize.LanguageTag.canonicalize(tag) do
          {:cont, [Localize.LanguageTag.to_string(canonical) | accumulator]}
        else
          {:error, _} = error -> {:halt, error}
        end
      end)

    case results do
      {:error, _} = error -> error
      list when is_list(list) -> {:ok, Enum.reverse(list)}
    end
  end

  @doc """
  Returns canonical locale name strings, raising on error.

  Same as `get_canonical_locales/1` but returns the list directly
  or raises an exception.

  ### Arguments

  * `locales` is a locale identifier string or a list of locale
    identifier strings.

  ### Returns

  * A list of canonical locale name strings.

  ### Examples

      iex> Intl.get_canonical_locales!("en-us")
      ["en-US"]

  """
  @spec get_canonical_locales!(String.t() | [String.t()]) :: [String.t()] | no_return()
  def get_canonical_locales!(locales) do
    case get_canonical_locales(locales) do
      {:ok, list} -> list
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Returns the subset of the given locales that are supported.

  Modelled on the JS `supportedLocalesOf()` static methods. All
  formatting modules share the same CLDR locale data, so a single
  top-level function replaces the per-constructor JS methods.

  A locale is supported when it resolves to CLDR locale data other
  than the root locale. Requested locales keep their extensions and
  order: `"de-ID"` is supported (falling back to `de` data) while
  `"ban"` (Balinese, no CLDR data) is not. Locales that fail to
  parse are excluded rather than raising, unlike JS.

  ### Arguments

  * `locales` is a locale identifier string or a list of locale
    identifier strings.

  ### Returns

  * `{:ok, list}` where `list` contains the requested locale
    strings that are supported, in the requested order.

  ### Examples

      iex> Intl.supported_locales_of(["ban", "id-u-co-pinyin", "de-ID"])
      {:ok, ["id-u-co-pinyin", "de-ID"]}

      iex> Intl.supported_locales_of("en-US")
      {:ok, ["en-US"]}

  """
  @spec supported_locales_of(String.t() | [String.t()]) :: {:ok, [String.t()]}
  def supported_locales_of(locales) when is_binary(locales) do
    supported_locales_of([locales])
  end

  def supported_locales_of(locales) when is_list(locales) do
    supported =
      Enum.filter(locales, fn locale ->
        case Localize.validate_locale(locale) do
          {:ok, language_tag} -> language_tag.cldr_locale_id != :und
          {:error, _reason} -> false
        end
      end)

    {:ok, supported}
  end

  @doc """
  Returns the supported values for a given internationalization key.

  ### Arguments

  * `key` is one of `:calendar`, `:collation`, `:currency`,
    `:numbering_system`, `:time_zone`, or `:unit`.

  ### Returns

  * `{:ok, list}` where `list` is a list of supported value atoms
    or strings.

  * `{:error, reason}` if the key is not recognized.

  ### Examples

      iex> {:ok, calendars} = Intl.supported_values_of(:calendar)
      iex> :gregorian in calendars
      true

      iex> {:ok, systems} = Intl.supported_values_of(:numbering_system)
      iex> :latn in systems
      true

      iex> {:ok, collations} = Intl.supported_values_of(:collation)
      iex> "emoji" in collations
      true

      iex> {:ok, time_zones} = Intl.supported_values_of(:time_zone)
      iex> "Europe/Paris" in time_zones
      true

  """
  @spec supported_values_of(
          :calendar
          | :collation
          | :currency
          | :numbering_system
          | :time_zone
          | :unit
        ) ::
          {:ok, list()} | {:error, term()}
  def supported_values_of(:calendar) do
    {:ok, Localize.known_calendars()}
  end

  def supported_values_of(:collation) do
    {:ok, Localize.known_collations()}
  end

  def supported_values_of(:time_zone) do
    {:ok, Localize.known_timezones()}
  end

  def supported_values_of(:numbering_system) do
    {:ok, Localize.known_number_systems()}
  end

  def supported_values_of(:currency) do
    {:ok, Localize.Currency.known_currency_codes()}
  end

  def supported_values_of(:unit) do
    {:ok, Localize.Unit.known_units_by_category()}
  end

  def supported_values_of(key) do
    {:error,
     ArgumentError.exception(
       "Unsupported key: #{inspect(key)}. " <>
         "Expected one of :calendar, :collation, :currency, :numbering_system, " <>
         ":time_zone, or :unit"
     )}
  end
end
