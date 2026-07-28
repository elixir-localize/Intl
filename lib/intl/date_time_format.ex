defmodule Intl.DateTimeFormat do
  @moduledoc """
  Locale-sensitive date and time formatting, modelled on
  [`Intl.DateTimeFormat`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat).

  Formats dates, times, and datetimes according to locale conventions.
  Accepts `Date`, `Time`, `DateTime`, and `NaiveDateTime` structs.

  Delegates to `Localize.DateTime`, `Localize.Date`, and
  `Localize.Time` for the underlying formatting.

  """

  @skeleton_components %{
    era: %{long: "GGGG", short: "G", narrow: "GGGGG"},
    weekday: %{long: "EEEE", short: "EEE", narrow: "EEEEE"},
    year: %{numeric: "y", "2-digit": "yy"},
    month: %{numeric: "M", "2-digit": "MM", long: "MMMM", short: "MMM", narrow: "MMMMM"},
    day: %{numeric: "d", "2-digit": "dd"},
    day_period: %{long: "BBBB", short: "B", narrow: "BBBBB"},
    hour: %{numeric: "h", "2-digit": "hh"},
    minute: %{numeric: "m", "2-digit": "mm"},
    second: %{numeric: "s", "2-digit": "ss"},
    fractional_second_digits: %{1 => "S", 2 => "SS", 3 => "SSS"},
    time_zone_name: %{
      short: "z",
      long: "zzzz",
      short_offset: "O",
      long_offset: "OOOO",
      short_generic: "v",
      long_generic: "vvvv"
    }
  }

  @skeleton_order [
    :era,
    :weekday,
    :year,
    :month,
    :day,
    :day_period,
    :hour,
    :minute,
    :second,
    :fractional_second_digits,
    :time_zone_name
  ]

  # JS hourCycle values mapped to the CLDR hour format symbol.
  @hour_cycle_symbols %{h11: "K", h12: "h", h23: "H", h24: "k"}

  @doc """
  Formats a date, time, or datetime value according to locale conventions.

  ### Arguments

  * `value` is a `Date`, `Time`, `DateTime`, or `NaiveDateTime`
    struct, or a map with date and/or time keys.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:date_style` is `:full`, `:long`, `:medium`, or `:short`.
    Provides a predefined date format. Cannot be combined with
    individual component options.

  * `:time_style` is `:full`, `:long`, `:medium`, or `:short`.
    Provides a predefined time format. Cannot be combined with
    individual component options.

  * `:era` is `:long`, `:short`, or `:narrow` (for example,
    "Anno Domini", "AD", "A").

  * `:weekday` is `:long`, `:short`, or `:narrow`.

  * `:year` is `:numeric` or `:"2-digit"`.

  * `:month` is `:numeric`, `:"2-digit"`, `:long`, `:short`,
    or `:narrow`.

  * `:day` is `:numeric` or `:"2-digit"`.

  * `:hour` is `:numeric` or `:"2-digit"`.

  * `:minute` is `:numeric` or `:"2-digit"`.

  * `:second` is `:numeric` or `:"2-digit"`.

  * `:day_period` is `:long`, `:short`, or `:narrow`. Renders
    flexible day periods such as "in the morning" or "noon".

  * `:fractional_second_digits` is `1`, `2`, or `3`. Renders
    that many fractional-second digits after the seconds field.

  * `:time_zone_name` is `:short`, `:long`, `:short_offset`,
    `:long_offset`, `:short_generic`, or `:long_generic`. Only
    applies to `DateTime` values with a time zone.

  * `:hour12` is a boolean selecting a 12-hour (`true`) or
    24-hour (`false`) clock for the `:hour` component.

  * `:hour_cycle` is `:h11`, `:h12`, `:h23`, or `:h24`. Takes
    precedence over `:hour12`.

  * `:numbering_system` is a CLDR numbering system name (for
    example, `:thai`). All numeric fields render in that system.

  * `:time_zone` is a time zone identifier string (for example,
    `"America/New_York"`).

  * `:calendar` is a calendar type atom (for example,
    `:gregorian`).

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if the value or options are invalid.

  ### Examples

      iex> Intl.DateTimeFormat.format(~D[2017-07-10], locale: :en, date_style: :full)
      {:ok, "Monday, July 10, 2017"}

      iex> Intl.DateTimeFormat.format(~D[2017-07-10], locale: :en, date_style: :short)
      {:ok, "7/10/17"}

      iex> Intl.DateTimeFormat.format(~N[2017-07-10 14:30:00], locale: :en, date_style: :medium, time_style: :short, prefer: :ascii)
      {:ok, "Jul 10, 2017, 2:30 PM"}

      iex> Intl.DateTimeFormat.format(~D[2017-07-10], locale: :en, year: :numeric, month: :long, day: :numeric)
      {:ok, "July 10, 2017"}

      iex> Intl.DateTimeFormat.format(~T[14:30:00], locale: :en, hour: :numeric, minute: :numeric, hour12: false)
      {:ok, "14:30"}

  """
  @spec format(Date.t() | Time.t() | DateTime.t() | NaiveDateTime.t() | map(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format(value, options \\ []) do
    localize_options = translate_options(options)

    cond do
      is_datetime?(value) -> Localize.DateTime.to_string(value, localize_options)
      is_date?(value) -> Localize.Date.to_string(value, localize_options)
      is_time?(value) -> Localize.Time.to_string(value, localize_options)
      true -> {:error, ArgumentError.exception("Unsupported value type: #{inspect(value)}")}
    end
  end

  @doc """
  Formats a date, time, or datetime value, raising on error.

  Same as `format/2` but returns the string directly or raises.

  ### Arguments

  * `value` is a `Date`, `Time`, `DateTime`, or `NaiveDateTime`
    struct, or a map with date and/or time keys.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.DateTimeFormat.format!(~D[2017-07-10], locale: :en, date_style: :full)
      "Monday, July 10, 2017"

  """
  @spec format!(Date.t() | Time.t() | DateTime.t() | NaiveDateTime.t() | map(), Keyword.t()) ::
          String.t() | no_return()
  def format!(value, options \\ []) do
    case format(value, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Formats a date, time, or datetime into a list of typed parts.

  Modelled on the JS `Intl.DateTimeFormat.formatToParts()`. Each
  part is a map with a `:type` and a `:value` key. Part types
  include `:year`, `:month`, `:day`, `:weekday`, `:era`, `:hour`,
  `:minute`, `:second`, `:fractional_second`, `:day_period`,
  `:time_zone_name`, and `:literal`.

  ### Arguments

  * `value` is a `Date`, `Time`, `DateTime`, or `NaiveDateTime`
    struct, or a map with date and/or time keys.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2`.

  ### Returns

  * `{:ok, parts}` where `parts` is a list of
    `%{type: atom, value: String.t()}` maps.

  * `{:error, reason}` if the value or options are invalid.

  ### Examples

      iex> Intl.DateTimeFormat.format_to_parts(~D[2017-07-10], locale: :en, year: :numeric, month: :long, day: :numeric)
      {:ok, [
        %{type: :month, value: "July"},
        %{type: :literal, value: " "},
        %{type: :day, value: "10"},
        %{type: :literal, value: ", "},
        %{type: :year, value: "2017"}
      ]}

  """
  @spec format_to_parts(
          Date.t() | Time.t() | DateTime.t() | NaiveDateTime.t() | map(),
          Keyword.t()
        ) ::
          {:ok, [%{type: atom(), value: String.t()}]} | {:error, term()}
  def format_to_parts(value, options \\ []) do
    localize_options = translate_options(options)

    cond do
      is_datetime?(value) -> Localize.DateTime.to_parts(value, localize_options)
      is_date?(value) -> Localize.Date.to_parts(value, localize_options)
      is_time?(value) -> Localize.Time.to_parts(value, localize_options)
      true -> {:error, ArgumentError.exception("Unsupported value type: #{inspect(value)}")}
    end
  end

  @doc """
  Formats a date, time, or datetime into typed parts, raising on error.

  Same as `format_to_parts/2` but returns the parts directly or raises.

  ### Arguments

  * `value` is a `Date`, `Time`, `DateTime`, or `NaiveDateTime`
    struct, or a map with date and/or time keys.

  * `options` is a keyword list of options.

  ### Returns

  * A list of `%{type: atom, value: String.t()}` maps.

  ### Examples

      iex> Intl.DateTimeFormat.format_to_parts!(~D[2017-07-10], locale: :en, date_style: :short) |> length()
      5

  """
  @spec format_to_parts!(
          Date.t() | Time.t() | DateTime.t() | NaiveDateTime.t() | map(),
          Keyword.t()
        ) ::
          [%{type: atom(), value: String.t()}] | no_return()
  def format_to_parts!(value, options \\ []) do
    case format_to_parts(value, options) do
      {:ok, parts} -> parts
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Formats a date/time range according to locale conventions.

  ### Arguments

  * `from` is the start date, time, or datetime.

  * `to` is the end date, time, or datetime.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2`.

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if the values or options are invalid.

  ### Examples

      iex> Intl.DateTimeFormat.format_range(~D[2017-07-10], ~D[2017-07-15], locale: :en)
      {:ok, "Jul 10\u2009–\u200915, 2017"}

  """
  @spec format_range(map(), map(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format_range(from, to, options \\ []) do
    localize_options = translate_options(options)
    Localize.Interval.to_string(from, to, localize_options)
  end

  @doc """
  Formats a date/time range into a list of typed parts.

  Modelled on the JS `Intl.DateTimeFormat.formatRangeToParts()`. In
  addition to `:type` and `:value`, each part carries a `:source`
  key: `:start_range`, `:end_range`, or `:shared`. When the range
  endpoints have no practical difference, the single formatted value
  carries source `:shared` throughout, matching JS.

  ### Arguments

  * `from` is the start date, time, or datetime.

  * `to` is the end date, time, or datetime.

  * `options` is a keyword list of options. Accepts the same
    options as `format_range/3`.

  ### Returns

  * `{:ok, parts}` where `parts` is a list of
    `%{type: atom, value: String.t(), source: atom}` maps.

  * `{:error, reason}` if the values or options are invalid.

  ### Examples

      iex> Intl.DateTimeFormat.format_range_to_parts(~D[2022-04-22], ~D[2022-04-25], locale: :en)
      {:ok, [
        %{type: :month, value: "Apr", source: :start_range},
        %{type: :literal, value: " ", source: :start_range},
        %{type: :day, value: "22", source: :start_range},
        %{type: :literal, value: " – ", source: :shared},
        %{type: :day, value: "25", source: :end_range},
        %{type: :literal, value: ", ", source: :end_range},
        %{type: :year, value: "2022", source: :end_range}
      ]}

  """
  @spec format_range_to_parts(map(), map(), Keyword.t()) ::
          {:ok, [%{type: atom(), value: String.t(), source: atom()}]} | {:error, term()}
  def format_range_to_parts(from, to, options \\ []) do
    localize_options = translate_options(options)
    Localize.Interval.to_parts(from, to, localize_options)
  end

  @doc """
  Formats a date/time range into typed parts, raising on error.

  Same as `format_range_to_parts/3` but returns the parts directly or raises.

  ### Arguments

  * `from` is the start date, time, or datetime.

  * `to` is the end date, time, or datetime.

  * `options` is a keyword list of options.

  ### Returns

  * A list of `%{type: atom, value: String.t(), source: atom}` maps.

  ### Examples

      iex> Intl.DateTimeFormat.format_range_to_parts!(~D[2022-04-22], ~D[2022-04-25], locale: :en) |> length()
      7

  """
  @spec format_range_to_parts!(map(), map(), Keyword.t()) ::
          [%{type: atom(), value: String.t(), source: atom()}] | no_return()
  def format_range_to_parts!(from, to, options \\ []) do
    case format_range_to_parts(from, to, options) do
      {:ok, parts} -> parts
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Formats a date/time range, raising on error.

  Same as `format_range/3` but returns the string directly or raises.

  ### Arguments

  * `from` is the start date, time, or datetime.

  * `to` is the end date, time, or datetime.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.DateTimeFormat.format_range!(~D[2017-07-10], ~D[2017-07-15], locale: :en)
      "Jul 10\u2009–\u200915, 2017"

  """
  @spec format_range!(map(), map(), Keyword.t()) :: String.t() | no_return()
  def format_range!(from, to, options \\ []) do
    case format_range(from, to, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end

  defp translate_options(options) do
    options = translate_numbering_system(options)

    cond do
      Keyword.has_key?(options, :date_style) or Keyword.has_key?(options, :time_style) ->
        translate_style_options(options)

      has_component_options?(options) ->
        translate_component_options(options)

      true ->
        options
    end
  end

  # The JS-compatible :numbering_system option maps to Localize's
  # :number_system option.
  defp translate_numbering_system(options) do
    case Keyword.pop(options, :numbering_system) do
      {nil, options} -> options
      {system, options} -> Keyword.put_new(options, :number_system, system)
    end
  end

  defp translate_style_options(options) do
    {date_style, options} = Keyword.pop(options, :date_style)
    {time_style, options} = Keyword.pop(options, :time_style)

    options =
      if date_style do
        Keyword.put(options, :date_format, date_style)
      else
        options
      end

    options =
      if time_style do
        Keyword.put(options, :time_format, time_style)
      else
        options
      end

    format =
      cond do
        date_style && time_style -> date_style
        date_style -> date_style
        time_style -> time_style
      end

    Keyword.put(options, :format, format)
  end

  defp translate_component_options(options) do
    skeleton = build_skeleton(options)

    options
    |> Keyword.drop(Map.keys(@skeleton_components))
    |> Keyword.drop([:hour12, :hour_cycle])
    |> Keyword.put(:format, skeleton)
  end

  # Skeletons must be atoms: Localize treats an atom :format as a
  # skeleton to match against the locale's formats, and a string
  # :format as a literal pattern.
  #
  # The `String.to_atom/1` below is bounded, not a route to atom-table
  # exhaustion: each component contributes a symbol drawn from the
  # compile-time `@skeleton_components` map (an unrecognised value
  # yields "" via `Map.get/3`), and the hour symbol comes from
  # `@hour_cycle_symbols`. Caller-supplied values select among those
  # fixed strings; they never become atoms themselves.
  defp build_skeleton(options) do
    hour_symbol = hour_symbol(options)

    @skeleton_order
    |> Enum.map(fn component ->
      case Keyword.fetch(options, component) do
        {:ok, value} ->
          components = Map.fetch!(@skeleton_components, component)
          component_symbol(components, value, component, hour_symbol)

        :error ->
          ""
      end
    end)
    |> Enum.join()
    |> String.to_atom()
  end

  defp component_symbol(components, value, :hour, hour_symbol) do
    case Map.get(components, value, "") do
      "" -> ""
      symbol -> String.duplicate(hour_symbol, String.length(symbol))
    end
  end

  defp component_symbol(components, value, _component, _hour_symbol) do
    Map.get(components, value, "")
  end

  defp hour_symbol(options) do
    hour_cycle = Keyword.get(options, :hour_cycle)
    hour12 = Keyword.get(options, :hour12)

    cond do
      hour_cycle -> Map.get(@hour_cycle_symbols, hour_cycle, "h")
      hour12 == true -> "h"
      hour12 == false -> "H"
      true -> "h"
    end
  end

  defp has_component_options?(options) do
    Enum.any?(@skeleton_order, &Keyword.has_key?(options, &1))
  end

  defp is_datetime?(%DateTime{}), do: true
  defp is_datetime?(%NaiveDateTime{}), do: true
  defp is_datetime?(%{year: _, month: _, day: _, hour: _, minute: _}), do: true
  defp is_datetime?(_), do: false

  defp is_date?(%Date{}), do: true
  defp is_date?(%{year: _}), do: true
  defp is_date?(%{month: _}), do: true
  defp is_date?(%{day: _}), do: true
  defp is_date?(_), do: false

  defp is_time?(%Time{}), do: true
  defp is_time?(%{hour: _}), do: true
  defp is_time?(_), do: false
end
