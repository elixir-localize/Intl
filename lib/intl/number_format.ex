defmodule Intl.NumberFormat do
  @moduledoc """
  Locale-sensitive number formatting, modelled on
  [`Intl.NumberFormat`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat).

  Formats numbers as decimals, currencies, percentages, or units
  according to locale conventions.

  Delegates to `Localize.Number` and `Localize.Unit` for the
  underlying formatting.

  """

  @style_to_format %{
    decimal: :standard,
    currency: :currency,
    percent: :percent,
    unit: :unit
  }

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

  * `:notation` is `:standard` or `:compact`. When `:compact`,
    uses abbreviated number formatting (for example, "1.2K").
    The default is `:standard`.

  * `:compact_display` is `:short` or `:long`. Only used when
    `:notation` is `:compact`. The default is `:short`.

  * `:minimum_fraction_digits` is a non-negative integer.

  * `:maximum_fraction_digits` is a non-negative integer.

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

  """
  @spec format(number() | Decimal.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format(number, options \\ []) do
    {style, options} = Keyword.pop(options, :style, :decimal)

    case style do
      :unit ->
        format_unit(number, options)

      _ ->
        localize_options = translate_options(style, options)
        Localize.Number.to_string(number, localize_options)
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
      {:error, %{__exception__: true} = exception} -> raise exception
      {:error, reason} -> raise ArgumentError, inspect(reason)
    end
  end

  @doc """
  Formats a range of numbers according to locale conventions.

  ### Arguments

  * `number_start` is the start of the range.

  * `number_end` is the end of the range.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2` (except `:style` must be `:decimal`
    or omitted).

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if options or input are invalid.

  ### Examples

      iex> Intl.NumberFormat.format_range(100, 200, locale: :en)
      {:ok, "100–200"}

  """
  @spec format_range(number(), number(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format_range(number_start, number_end, options \\ []) do
    options = Keyword.delete(options, :style)
    localize_options = translate_options(:decimal, options)
    Localize.Number.to_range_string(number_start, number_end, localize_options)
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
      {:error, %{__exception__: true} = exception} -> raise exception
      {:error, reason} -> raise ArgumentError, inspect(reason)
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
    format = Map.get(@style_to_format, style, :standard)

    options
    |> translate_notation(format)
    |> translate_fraction_digits()
    |> Keyword.delete(:notation)
    |> Keyword.delete(:compact_display)
    |> Keyword.delete(:unit_display)
    |> Keyword.delete(:unit)
  end

  defp translate_notation(options, format) do
    case Keyword.get(options, :notation, :standard) do
      :compact ->
        compact_display = Keyword.get(options, :compact_display, :short)

        compact_format =
          case compact_display do
            :short -> :decimal_short
            :long -> :decimal_long
          end

        Keyword.put(options, :format, compact_format)

      :standard ->
        Keyword.put(options, :format, format)
    end
  end

  defp translate_fraction_digits(options) do
    options
    |> translate_option(:minimum_fraction_digits, :min_fractional_digits)
    |> translate_option(:maximum_fraction_digits, :max_fractional_digits)
  end

  defp translate_option(options, from_key, to_key) do
    case Keyword.pop(options, from_key) do
      {nil, options} -> options
      {value, options} -> Keyword.put(options, to_key, value)
    end
  end
end
