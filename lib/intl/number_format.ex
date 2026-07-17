defmodule Intl.NumberFormat do
  @moduledoc """
  Locale-sensitive number formatting, modelled on
  [`Intl.NumberFormat`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat).

  Formats numbers as decimals, currencies, percentages, or units
  according to locale conventions.

  Delegates to `Localize.Number` and `Localize.Unit` for the
  underlying formatting.

  """

  @notations [:standard, :scientific, :engineering, :compact]
  @compact_displays [:short, :long]
  @currency_displays [:symbol, :narrow_symbol, :code, :name]
  @currency_signs [:standard, :accounting]
  @use_groupings [:always, :auto, :min2, true, false]

  # Options consumed by this module and translated into Localize
  # options; they must not leak through to Localize.Number.
  @intl_only_options [
    :notation,
    :compact_display,
    :currency_display,
    :currency_sign,
    :use_grouping,
    :unit_display,
    :unit
  ]

  # A minimum-grouping-digits value large enough that no formatted
  # number ever reaches it, which disables grouping entirely.
  @grouping_disabled 10_000

  @doc """
  Formats a number according to locale conventions.

  ### Arguments

  * `number` is an integer, float, or `Decimal`.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:style` is `:decimal`, `:currency`, `:percent`, or `:unit`.
    The default is `:decimal`.

  * `:currency` is a currency code atom (for example, `:USD`,
    `:EUR`). Required when `:style` is `:currency`.

  * `:unit` is a unit identifier string (for example, `"kilometer"`,
    `"liter"`). Required when `:style` is `:unit`.

  * `:unit_display` is `:long`, `:short`, or `:narrow`. Controls
    how the unit is displayed. The default is `:short`.

  * `:notation` is `:standard`, `:scientific`, `:engineering`,
    or `:compact`. When `:compact`, uses abbreviated number
    formatting (for example, "1.2K"). The default is `:standard`.

  * `:compact_display` is `:short` or `:long`. Only used when
    `:notation` is `:compact`. The default is `:short`. Compact
    currency formatting always uses the short form since CLDR
    defines no long compact currency format.

  * `:currency_display` is `:symbol`, `:narrow_symbol`, `:code`,
    or `:name`. Controls how the currency is presented. The
    default is `:symbol`.

  * `:currency_sign` is `:standard` or `:accounting`. When
    `:accounting`, negative currency amounts render in the
    locale's accounting format (for example, "($1,234.50)").
    The default is `:standard`.

  * `:use_grouping` is `:always`, `:auto`, `:min2`, `true`, or
    `false`. `:min2` groups only when there are at least two
    digits in a group; `false` disables grouping. The default
    is `:auto`.

  * `:minimum_fraction_digits` is a non-negative integer.

  * `:maximum_fraction_digits` is a non-negative integer.

  * `:minimum_significant_digits` is an integer in `1..21`.

  * `:maximum_significant_digits` is an integer in `1..21`.
    When set, significant-digit precision overrides
    fraction-digit precision.

  * `:numbering_system` is a numbering system name (for example,
    `:latn`). The system must be one defined for the locale.

  * `:rounding_increment` is a positive integer. The formatted
    value is rounded to the nearest multiple of this increment.

  * `:rounding_mode` is one of `:down`, `:half_up`, `:half_even`,
    `:ceiling`, `:floor`, `:half_down`, `:up`.

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if options or input are invalid.

  ### Examples

      iex> Intl.NumberFormat.format(1234.5, locale: :en)
      {:ok, "1,234.5"}

      iex> Intl.NumberFormat.format(0.56, locale: :en, style: :percent)
      {:ok, "56%"}

      iex> Intl.NumberFormat.format(1234.5, locale: :en, style: :currency, currency: :USD)
      {:ok, "$1,234.50"}

      iex> Intl.NumberFormat.format(1234.5, locale: :en, notation: :scientific)
      {:ok, "1.2345E3"}

      iex> Intl.NumberFormat.format(1234, locale: :en, style: :currency, currency: :USD, notation: :compact)
      {:ok, "$1.2K"}

      iex> Intl.NumberFormat.format(-1234.5, locale: :en, style: :currency, currency: :USD, currency_sign: :accounting)
      {:ok, "($1,234.50)"}

      iex> Intl.NumberFormat.format(1234567, locale: :en, use_grouping: false)
      {:ok, "1234567"}

      iex> Intl.NumberFormat.format(1234.5, locale: :en, maximum_significant_digits: 3)
      {:ok, "1,230"}

  """
  @spec format(number() | Decimal.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format(number, options \\ []) do
    {style, options} = Keyword.pop(options, :style, :decimal)

    case style do
      :unit ->
        format_unit(number, options)

      style when style in [:decimal, :currency, :percent] ->
        with {:ok, localize_options} <- translate_options(style, options) do
          Localize.Number.to_string(number, localize_options)
        end

      other ->
        {:error, invalid_option_error(:style, other, [:decimal, :currency, :percent, :unit])}
    end
  end

  @doc """
  Formats a number, raising on error.

  Same as `format/2` but returns the string directly or raises.

  ### Arguments

  * `number` is an integer, float, or `Decimal`.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.NumberFormat.format!(1234.5, locale: :en)
      "1,234.5"

  """
  @spec format!(number() | Decimal.t(), Keyword.t()) :: String.t() | no_return()
  def format!(number, options \\ []) do
    case format(number, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Formats a range of numbers according to locale conventions.

  ### Arguments

  * `number_start` is the start of the range.

  * `number_end` is the end of the range.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2` (except `:style` must be `:decimal`,
    `:currency`, or `:percent`; `:unit` ranges are not supported).

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if options or input are invalid.

  ### Examples

      iex> Intl.NumberFormat.format_range(100, 200, locale: :en)
      {:ok, "100–200"}

      iex> Intl.NumberFormat.format_range(100, 200, locale: :en, style: :currency, currency: :USD)
      {:ok, "$100.00–$200.00"}

  """
  @spec format_range(number(), number(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format_range(number_start, number_end, options \\ []) do
    {style, options} = Keyword.pop(options, :style, :decimal)

    case style do
      style when style in [:decimal, :currency, :percent] ->
        with {:ok, localize_options} <- translate_options(style, options) do
          Localize.Number.to_range_string(number_start, number_end, localize_options)
        end

      other ->
        {:error, invalid_option_error(:style, other, [:decimal, :currency, :percent])}
    end
  end

  @doc """
  Formats a range of numbers, raising on error.

  Same as `format_range/3` but returns the string directly or raises.

  ### Arguments

  * `number_start` is the start of the range.

  * `number_end` is the end of the range.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.NumberFormat.format_range!(100, 200, locale: :en)
      "100–200"

  """
  @spec format_range!(number(), number(), Keyword.t()) :: String.t() | no_return()
  def format_range!(number_start, number_end, options \\ []) do
    case format_range(number_start, number_end, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end

  defp format_unit(number, options) do
    {unit_name, options} = Keyword.pop(options, :unit)
    {unit_display, options} = Keyword.pop(options, :unit_display, :short)

    if unit_name do
      with {:ok, unit} <- Localize.Unit.new(number, unit_name) do
        Localize.Unit.to_string(unit, Keyword.put(options, :format, unit_display))
      end
    else
      {:error, ArgumentError.exception("The :unit option is required when style is :unit")}
    end
  end

  defp translate_options(style, options) do
    with {:ok, notation} <- validate_option(options, :notation, @notations, :standard),
         {:ok, compact_display} <-
           validate_option(options, :compact_display, @compact_displays, :short),
         {:ok, currency_display} <-
           validate_option(options, :currency_display, @currency_displays, :symbol),
         {:ok, currency_sign} <-
           validate_option(options, :currency_sign, @currency_signs, :standard),
         {:ok, use_grouping} <- validate_option(options, :use_grouping, @use_groupings, :auto) do
      format = resolve_format(style, notation, compact_display, currency_sign, currency_display)

      localize_options =
        options
        |> Keyword.put(:format, format)
        |> put_currency_symbol(style, currency_display)
        |> put_grouping(use_grouping)
        |> translate_option(:minimum_fraction_digits, :min_fractional_digits)
        |> translate_option(:maximum_fraction_digits, :max_fractional_digits)
        |> translate_option(:rounding_increment, :round_nearest)
        |> translate_option(:numbering_system, :number_system)
        |> Keyword.drop(@intl_only_options)

      {:ok, localize_options}
    end
  end

  defp validate_option(options, key, valid_values, default) do
    value = Keyword.get(options, key, default)

    if value in valid_values do
      {:ok, value}
    else
      {:error, invalid_option_error(key, value, valid_values)}
    end
  end

  defp invalid_option_error(key, value, valid_values) do
    ArgumentError.exception(
      "Invalid #{inspect(key)} option: #{inspect(value)}. " <>
        "Valid values are #{inspect(valid_values)}"
    )
  end

  # CLDR defines no long compact currency format, so compact currency
  # always uses :currency_short regardless of :compact_display,
  # matching the browser fallback for Intl.NumberFormat.
  defp resolve_format(:currency, :compact, _compact_display, _sign, _display),
    do: :currency_short

  defp resolve_format(_style, :compact, :short, _sign, _display), do: :decimal_short
  defp resolve_format(_style, :compact, :long, _sign, _display), do: :decimal_long
  defp resolve_format(_style, :scientific, _compact_display, _sign, _display), do: :scientific
  defp resolve_format(_style, :engineering, _compact_display, _sign, _display), do: :engineering

  defp resolve_format(:currency, :standard, _compact_display, :accounting, _display),
    do: :accounting

  defp resolve_format(:currency, :standard, _compact_display, :standard, :name),
    do: :currency_long

  defp resolve_format(:currency, :standard, _compact_display, :standard, _display), do: :currency
  defp resolve_format(:percent, :standard, _compact_display, _sign, _display), do: :percent
  defp resolve_format(:decimal, :standard, _compact_display, _sign, _display), do: :standard

  defp put_currency_symbol(options, :currency, :narrow_symbol),
    do: Keyword.put_new(options, :currency_symbol, :narrow)

  defp put_currency_symbol(options, :currency, :code),
    do: Keyword.put_new(options, :currency_symbol, :iso)

  defp put_currency_symbol(options, _style, _currency_display), do: options

  defp put_grouping(options, :auto), do: options
  defp put_grouping(options, true), do: put_grouping(options, :always)
  defp put_grouping(options, :always), do: Keyword.put_new(options, :minimum_grouping_digits, 1)
  defp put_grouping(options, :min2), do: Keyword.put_new(options, :minimum_grouping_digits, 2)

  defp put_grouping(options, false),
    do: Keyword.put_new(options, :minimum_grouping_digits, @grouping_disabled)

  defp translate_option(options, from_key, to_key) do
    case Keyword.pop(options, from_key) do
      {nil, options} -> options
      {value, options} -> Keyword.put(options, to_key, value)
    end
  end
end
