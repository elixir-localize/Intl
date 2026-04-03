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
    weekday: %{long: "EEEE", short: "EEE", narrow: "EEEEE"},
    year: %{numeric: "y", "2-digit": "yy"},
    month: %{numeric: "M", "2-digit": "MM", long: "MMMM", short: "MMM", narrow: "MMMMM"},
    day: %{numeric: "d", "2-digit": "dd"},
    hour: %{numeric: "h", "2-digit": "hh"},
    minute: %{numeric: "m", "2-digit": "mm"},
    second: %{numeric: "s", "2-digit": "ss"}
  }

  @skeleton_order [:weekday, :year, :month, :day, :hour, :minute, :second]

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

  * `:weekday` is `:long`, `:short`, or `:narrow`.

  * `:year` is `:numeric` or `:"2-digit"`.

  * `:month` is `:numeric`, `:"2-digit"`, `:long`, `:short`,
    or `:narrow`.

  * `:day` is `:numeric` or `:"2-digit"`.

  * `:hour` is `:numeric` or `:"2-digit"`.

  * `:minute` is `:numeric` or `:"2-digit"`.

  * `:second` is `:numeric` or `:"2-digit"`.

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
      {:error, %{__exception__: true} = exception} -> raise exception
      {:error, reason} -> raise ArgumentError, inspect(reason)
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
      {:error, %{__exception__: true} = exception} -> raise exception
      {:error, reason} -> raise ArgumentError, inspect(reason)
    end
  end

  defp translate_options(options) do
    cond do
      Keyword.has_key?(options, :date_style) or Keyword.has_key?(options, :time_style) ->
        translate_style_options(options)

      has_component_options?(options) ->
        translate_component_options(options)

      true ->
        options
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
    |> Keyword.put(:format, skeleton)
  end

  defp build_skeleton(options) do
    @skeleton_order
    |> Enum.map(fn component ->
      case Keyword.fetch(options, component) do
        {:ok, value} ->
          components = Map.fetch!(@skeleton_components, component)
          Map.get(components, value, "")

        :error ->
          ""
      end
    end)
    |> Enum.join()
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
