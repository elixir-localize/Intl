defmodule Intl.DurationFormat do
  @moduledoc """
  Locale-sensitive duration formatting, modelled on
  [`Intl.DurationFormat`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DurationFormat).

  Formats durations as human-readable strings such as
  "11 months and 30 days" or "2 hours, 30 minutes, and 45 seconds".

  Delegates to `Localize.Duration` for the underlying formatting.

  Accepts either a `Localize.Duration` struct or a plain map with
  duration component keys (matching the JS `DurationFormat` input
  shape).

  """

  @duration_keys [:year, :month, :day, :hour, :minute, :second, :microsecond]

  # JS per-unit option names mapped to the singular Localize unit
  # atoms: {style_option, display_option, unit}.
  @per_unit_options [
    {:years, :years_display, :year},
    {:months, :months_display, :month},
    {:days, :days_display, :day},
    {:hours, :hours_display, :hour},
    {:minutes, :minutes_display, :minute},
    {:seconds, :seconds_display, :second},
    {:microseconds, :microseconds_display, :microsecond}
  ]

  @doc """
  Formats a duration according to locale conventions.

  ### Arguments

  * `duration` is a `Localize.Duration` struct or a map with
    any of the keys `:years`, `:months`, `:days`, `:hours`,
    `:minutes`, `:seconds` (plural, matching the JS API), or
    the singular Elixir equivalents `:year`, `:month`, `:day`,
    `:hour`, `:minute`, `:second`.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:style` is `:long`, `:short`, or `:narrow`. The default
    is `:long`.

  * Per-unit style options — `:years`, `:months`, `:days`,
    `:hours`, `:minutes`, `:seconds`, `:microseconds` — each
    accept `:long`, `:short`, or `:narrow`, overriding `:style`
    for that unit (JS `hours: "narrow"`).

  * Per-unit display options — `:years_display`,
    `:months_display`, `:days_display`, `:hours_display`,
    `:minutes_display`, `:seconds_display`,
    `:microseconds_display` — each accept `:auto` (omit when
    zero, the default) or `:always` (JS `hoursDisplay`).

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if the duration or options are invalid.

  ### Examples

      iex> {:ok, d} = Localize.Duration.new(~D[2019-01-01], ~D[2019-12-31])
      iex> Intl.DurationFormat.format(d, locale: :en)
      {:ok, "11 months and 30 days"}

      iex> Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en)
      {:ok, "2 hours and 30 minutes"}

      iex> Intl.DurationFormat.format(%{hours: 2}, locale: :en, minutes_display: :always)
      {:ok, "2 hours and 0 minutes"}

      iex> Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en, hours: :narrow)
      {:ok, "2h and 30 minutes"}

  """
  @spec format(Localize.Duration.t() | map(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format(duration_or_map, options \\ [])

  def format(%Localize.Duration{} = duration, options) do
    Localize.Duration.to_string(duration, translate_options(options))
  end

  def format(map, options) when is_map(map) do
    duration = to_duration_struct(map)
    Localize.Duration.to_string(duration, translate_options(options))
  end

  @doc """
  Formats a duration into a list of typed parts.

  Modelled on the JS `Intl.DurationFormat.formatToParts()`. Each
  duration field contributes its unit parts, with the numeric
  segments carrying a `:unit` key naming the field; the separators
  between fields are `:literal` parts.

  ### Arguments

  * `duration` is a `Localize.Duration` struct or a map with
    duration component keys.

  * `options` is a keyword list of options. Accepts the same
    options as `format/2`, including the per-unit style and
    display options.

  ### Returns

  * `{:ok, parts}` where `parts` is a list of
    `%{type: atom, value: String.t()}` maps; numeric parts also
    carry a `:unit` key.

  * `{:error, reason}` if the duration or options are invalid.

  ### Examples

      iex> Intl.DurationFormat.format_to_parts(%{hours: 2, minutes: 30}, locale: :en)
      {:ok, [
        %{type: :integer, value: "2", unit: :hour},
        %{type: :literal, value: " "},
        %{type: :unit, value: "hours"},
        %{type: :literal, value: " and "},
        %{type: :integer, value: "30", unit: :minute},
        %{type: :literal, value: " "},
        %{type: :unit, value: "minutes"}
      ]}

  """
  @spec format_to_parts(Localize.Duration.t() | map(), Keyword.t()) ::
          {:ok, [%{type: atom(), value: String.t()}]} | {:error, term()}
  def format_to_parts(duration_or_map, options \\ [])

  def format_to_parts(%Localize.Duration{} = duration, options) do
    Localize.Duration.to_parts(duration, translate_options(options))
  end

  def format_to_parts(map, options) when is_map(map) do
    duration = to_duration_struct(map)
    Localize.Duration.to_parts(duration, translate_options(options))
  end

  @doc """
  Formats a duration into typed parts, raising on error.

  Same as `format_to_parts/2` but returns the parts directly or raises.

  ### Arguments

  * `duration` is a `Localize.Duration` struct or a map.

  * `options` is a keyword list of options.

  ### Returns

  * A list of `%{type: atom, value: String.t()}` maps.

  ### Examples

      iex> Intl.DurationFormat.format_to_parts!(%{hours: 2}, locale: :en) |> length()
      3

  """
  @spec format_to_parts!(Localize.Duration.t() | map(), Keyword.t()) ::
          [%{type: atom(), value: String.t()}] | no_return()
  def format_to_parts!(duration, options \\ []) do
    case format_to_parts(duration, options) do
      {:ok, parts} -> parts
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Formats a duration, raising on error.

  Same as `format/2` but returns the string directly or raises.

  ### Arguments

  * `duration` is a `Localize.Duration` struct or a map.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.DurationFormat.format!(%{hours: 2, minutes: 30}, locale: :en)
      "2 hours and 30 minutes"

  """
  @spec format!(Localize.Duration.t() | map(), Keyword.t()) :: String.t() | no_return()
  def format!(duration, options \\ []) do
    case format(duration, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end

  # The JS-compatible :style option maps to Localize's :format
  # option (Localize deprecated :format's old name :style in 0.43),
  # and the JS per-unit style/display options map to Localize's
  # :styles and :display keyword lists.
  defp translate_options(options) do
    options
    |> translate_style()
    |> translate_per_unit_options()
  end

  defp translate_style(options) do
    case Keyword.pop(options, :style) do
      {nil, options} -> options
      {style, options} -> Keyword.put_new(options, :format, style)
    end
  end

  defp translate_per_unit_options(options) do
    {options, styles, display} =
      Enum.reduce(@per_unit_options, {options, [], []}, fn
        {style_key, display_key, unit}, {options, styles, display} ->
          {style_value, options} = Keyword.pop(options, style_key)
          {display_value, options} = Keyword.pop(options, display_key)

          styles = if style_value, do: [{unit, style_value} | styles], else: styles
          display = if display_value, do: [{unit, display_value} | display], else: display
          {options, styles, display}
      end)

    options
    |> put_unless_empty(:styles, Enum.reverse(styles))
    |> put_unless_empty(:display, Enum.reverse(display))
  end

  defp put_unless_empty(options, _key, []), do: options
  defp put_unless_empty(options, key, value), do: Keyword.put_new(options, key, value)

  defp to_duration_struct(map) do
    normalized =
      Enum.reduce(map, %{}, fn {key, value}, accumulator ->
        singular = singularize(key)

        if singular in @duration_keys do
          Map.put(accumulator, singular, value)
        else
          accumulator
        end
      end)

    struct(Localize.Duration, normalized)
  end

  defp singularize(:years), do: :year
  defp singularize(:months), do: :month
  defp singularize(:days), do: :day
  defp singularize(:hours), do: :hour
  defp singularize(:minutes), do: :minute
  defp singularize(:seconds), do: :second
  defp singularize(:microseconds), do: :microsecond
  defp singularize(key), do: key
end
