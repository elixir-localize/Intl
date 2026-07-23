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
  @rounding_priorities [:auto, :more_precision, :less_precision]

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

  * `:sign_display` is `:auto`, `:always`, `:except_zero`,
    `:negative`, or `:never`. Controls when the sign is
    displayed. The default is `:auto`.

  * `:minimum_integer_digits` is an integer in `1..21`. The
    integer part is zero-padded to at least this many digits.

  * `:minimum_fraction_digits` is a non-negative integer.

  * `:maximum_fraction_digits` is a non-negative integer.

  * `:minimum_significant_digits` is an integer in `1..21`.

  * `:maximum_significant_digits` is an integer in `1..21`.
    When set, significant-digit precision overrides
    fraction-digit precision.

  * `:numbering_system` is a CLDR numbering system name (for
    example, `:latn`, `:thai`). Any valid CLDR numbering system
    may be used with any locale, including algorithmic systems
    such as `:roman`.

  * `:rounding_increment` is a positive integer. The formatted
    value is rounded to the nearest multiple of this increment.

  * `:rounding_mode` is one of `:down`, `:half_up`, `:half_even`,
    `:ceiling`, `:floor`, `:half_down`, `:up`.

  * `:rounding_priority` is `:auto`, `:more_precision`, or
    `:less_precision`. Resolves conflicts when both fraction-digit
    and significant-digit options are given. The default is
    `:auto` (significant digits win).

  * `:trailing_zero_display` is `:auto` or `:strip_if_integer`.
    When `:strip_if_integer`, fraction digits are dropped if the
    rounded value is an integer. The default is `:auto`.

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

      iex> Intl.NumberFormat.format(1234.5, locale: :en, sign_display: :always)
      {:ok, "+1,234.5"}

      iex> Intl.NumberFormat.format(1234.5, locale: :en, numbering_system: :thai)
      {:ok, "๑,๒๓๔.๕"}

      iex> Intl.NumberFormat.format(5, locale: :en, minimum_integer_digits: 3)
      {:ok, "005"}

      iex> Intl.NumberFormat.format(1000, locale: :en, minimum_fraction_digits: 2, trailing_zero_display: :strip_if_integer)
      {:ok, "1,000"}

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
    options as `format/2`, including `style: :unit` with `:unit`
    and `:unit_display` (the unit pattern is applied once to the
    range, "2–5 kilometers").

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
      :unit ->
        unit_range(number_start, number_end, options)

      style when style in [:decimal, :currency, :percent] ->
        with {:ok, localize_options} <- translate_options(style, options) do
          Localize.Number.to_range_string(number_start, number_end, localize_options)
        end

      other ->
        {:error, invalid_option_error(:style, other, [:decimal, :currency, :percent, :unit])}
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

  @doc """
  Formats a range of numbers into a list of typed parts.

  Modelled on the JS `Intl.NumberFormat.formatRangeToParts()`. In
  addition to `:type` and `:value`, each part carries a `:source`
  key: `:start_range`, `:end_range`, or `:shared`.

  ### Arguments

  * `number_start` is the start of the range.

  * `number_end` is the end of the range.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2`, including `style: :unit` (the unit
    pattern text carries source `:shared`).

  ### Returns

  * `{:ok, parts}` where `parts` is a list of
    `%{type: atom, value: String.t(), source: atom}` maps.

  * `{:error, reason}` if options or input are invalid.

  ### Examples

      iex> Intl.NumberFormat.format_range_to_parts(3, 5, locale: :en)
      {:ok, [
        %{type: :integer, value: "3", source: :start_range},
        %{type: :literal, value: "–", source: :shared},
        %{type: :integer, value: "5", source: :end_range}
      ]}

  """
  @spec format_range_to_parts(number(), number(), Keyword.t()) ::
          {:ok, [%{type: atom(), value: String.t(), source: atom()}]} | {:error, term()}
  def format_range_to_parts(number_start, number_end, options \\ []) do
    {style, options} = Keyword.pop(options, :style, :decimal)

    case style do
      :unit ->
        unit_range_to_parts(number_start, number_end, options)

      style when style in [:decimal, :currency, :percent] ->
        with {:ok, localize_options} <- translate_options(style, options) do
          Localize.Number.to_range_parts(number_start, number_end, localize_options)
        end

      other ->
        {:error, invalid_option_error(:style, other, [:decimal, :currency, :percent, :unit])}
    end
  end

  @doc """
  Formats a range of numbers into typed parts, raising on error.

  Same as `format_range_to_parts/3` but returns the parts directly or raises.

  ### Arguments

  * `number_start` is the start of the range.

  * `number_end` is the end of the range.

  * `options` is a keyword list of options.

  ### Returns

  * A list of `%{type: atom, value: String.t(), source: atom}` maps.

  ### Examples

      iex> Intl.NumberFormat.format_range_to_parts!(3, 5, locale: :en) |> length()
      3

  """
  @spec format_range_to_parts!(number(), number(), Keyword.t()) ::
          [%{type: atom(), value: String.t(), source: atom()}] | no_return()
  def format_range_to_parts!(number_start, number_end, options \\ []) do
    case format_range_to_parts(number_start, number_end, options) do
      {:ok, parts} -> parts
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Formats a number into a list of typed parts.

  Modelled on the JS `Intl.NumberFormat.formatToParts()`. Each part
  is a map with a `:type` and a `:value` key, allowing custom
  rendering of individual segments (for example, styling the
  currency symbol differently from the digits).

  ### Arguments

  * `number` is an integer, float, or `Decimal`.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2`, including `style: :unit` (the unit
    text is a `:unit` part) and `currency_display: :name` (the
    currency name is a `:currency` part).

  ### Returns

  * `{:ok, parts}` on success, where `parts` is a list of
    `%{type: atom, value: String.t()}` maps. Part types include
    `:integer`, `:group`, `:decimal`, `:fraction`, `:currency`,
    `:percent_sign`, `:minus_sign`, `:plus_sign`, `:compact`,
    `:exponent_separator`, `:exponent_integer`, and `:literal`.

  * `{:error, reason}` if options or input are invalid.

  ### Examples

      iex> Intl.NumberFormat.format_to_parts(-1234.5, locale: :en)
      {:ok, [
        %{type: :minus_sign, value: "-"},
        %{type: :integer, value: "1"},
        %{type: :group, value: ","},
        %{type: :integer, value: "234"},
        %{type: :decimal, value: "."},
        %{type: :fraction, value: "5"}
      ]}

      iex> Intl.NumberFormat.format_to_parts(1_500_000, locale: :en, notation: :compact, compact_display: :long)
      {:ok, [
        %{type: :integer, value: "1"},
        %{type: :decimal, value: "."},
        %{type: :fraction, value: "5"},
        %{type: :literal, value: " "},
        %{type: :compact, value: "million"}
      ]}

  """
  @spec format_to_parts(number() | Decimal.t(), Keyword.t()) ::
          {:ok, [%{type: atom(), value: String.t()}]} | {:error, term()}
  def format_to_parts(number, options \\ []) do
    {style, options} = Keyword.pop(options, :style, :decimal)

    case style do
      :unit ->
        unit_to_parts(number, options)

      style when style in [:decimal, :currency, :percent] ->
        with {:ok, localize_options} <- translate_options(style, options),
             {:ok, parts} <- Localize.Number.to_parts(number, localize_options) do
          {:ok, split_compact_literals(parts)}
        end

      other ->
        {:error, invalid_option_error(:style, other, [:decimal, :currency, :percent, :unit])}
    end
  end

  @doc """
  Formats a number into a list of typed parts, raising on error.

  Same as `format_to_parts/2` but returns the parts directly or raises.

  ### Arguments

  * `number` is an integer, float, or `Decimal`.

  * `options` is a keyword list of options.

  ### Returns

  * A list of `%{type: atom, value: String.t()}` maps.

  ### Examples

      iex> Intl.NumberFormat.format_to_parts!(56, locale: :en)
      [%{type: :integer, value: "56"}]

  """
  @spec format_to_parts!(number() | Decimal.t(), Keyword.t()) ::
          [%{type: atom(), value: String.t()}] | no_return()
  def format_to_parts!(number, options \\ []) do
    case format_to_parts(number, options) do
      {:ok, parts} -> parts
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
      {:error, missing_unit_error()}
    end
  end

  defp unit_to_parts(number, options) do
    {unit_name, options} = Keyword.pop(options, :unit)
    {unit_display, options} = Keyword.pop(options, :unit_display, :short)

    if unit_name do
      with {:ok, unit} <- Localize.Unit.new(number, unit_name) do
        Localize.Unit.to_parts(unit, Keyword.put(options, :format, unit_display))
      end
    else
      {:error, missing_unit_error()}
    end
  end

  defp unit_range_to_parts(number_start, number_end, options) do
    {unit_name, options} = Keyword.pop(options, :unit)
    {unit_display, options} = Keyword.pop(options, :unit_display, :short)

    if unit_name do
      with {:ok, unit_start} <- Localize.Unit.new(number_start, unit_name),
           {:ok, unit_end} <- Localize.Unit.new(number_end, unit_name) do
        Localize.Unit.to_range_parts(
          unit_start,
          unit_end,
          Keyword.put(options, :format, unit_display)
        )
      end
    else
      {:error, missing_unit_error()}
    end
  end

  defp unit_range(number_start, number_end, options) do
    {unit_name, options} = Keyword.pop(options, :unit)
    {unit_display, options} = Keyword.pop(options, :unit_display, :short)

    if unit_name do
      with {:ok, unit_start} <- Localize.Unit.new(number_start, unit_name),
           {:ok, unit_end} <- Localize.Unit.new(number_end, unit_name) do
        Localize.Unit.to_range_string(
          unit_start,
          unit_end,
          Keyword.put(options, :format, unit_display)
        )
      end
    else
      {:error, missing_unit_error()}
    end
  end

  defp missing_unit_error do
    ArgumentError.exception("The :unit option is required when style is :unit")
  end

  defp translate_options(style, options) do
    with {:ok, notation} <- validate_option(options, :notation, @notations, :standard),
         {:ok, compact_display} <-
           validate_option(options, :compact_display, @compact_displays, :short),
         {:ok, currency_display} <-
           validate_option(options, :currency_display, @currency_displays, :symbol),
         {:ok, currency_sign} <-
           validate_option(options, :currency_sign, @currency_signs, :standard),
         {:ok, use_grouping} <- validate_option(options, :use_grouping, @use_groupings, :auto),
         {:ok, rounding_priority} <-
           validate_option(options, :rounding_priority, @rounding_priorities, :auto) do
      format = resolve_format(style, notation, compact_display, currency_sign, currency_display)

      localize_options =
        options
        |> Keyword.put(:format, format)
        |> put_currency_symbol(style, currency_display)
        |> put_grouping(use_grouping)
        |> apply_rounding_priority(rounding_priority)
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

  # Localize tags a compact affix as a single :compact part including
  # its spacing (" million"). JS emits the spacing as a separate
  # :literal part, so split leading and trailing whitespace off.
  defp split_compact_literals(parts) do
    Enum.flat_map(parts, fn
      %{type: :compact, value: value} ->
        stripped_leading = String.trim_leading(value)
        stripped = String.trim_trailing(stripped_leading)
        leading = binary_part(value, 0, byte_size(value) - byte_size(stripped_leading))

        trailing =
          binary_part(
            stripped_leading,
            byte_size(stripped),
            byte_size(stripped_leading) - byte_size(stripped)
          )

        literal = fn
          "" -> []
          whitespace -> [%{type: :literal, value: whitespace}]
        end

        literal.(leading) ++ [%{type: :compact, value: stripped}] ++ literal.(trailing)

      part ->
        [part]
    end)
  end

  # ECMA-402 SetNumberFormatDigitOptions: when a significant-digit
  # bound is present and roundingPriority is :auto, the fraction-digit
  # bounds are ignored entirely. Implemented here because Localize's
  # :auto applies both bounds sequentially.
  defp apply_rounding_priority(options, :auto) do
    significant? =
      Keyword.has_key?(options, :minimum_significant_digits) or
        Keyword.has_key?(options, :maximum_significant_digits)

    options = Keyword.delete(options, :rounding_priority)

    if significant? do
      Keyword.drop(options, [:minimum_fraction_digits, :maximum_fraction_digits])
    else
      options
    end
  end

  defp apply_rounding_priority(options, _more_or_less_precision), do: options

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
