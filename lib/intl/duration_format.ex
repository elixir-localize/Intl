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

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if the duration or options are invalid.

  ### Examples

      iex> {:ok, d} = Localize.Duration.new(~D[2019-01-01], ~D[2019-12-31])
      iex> Intl.DurationFormat.format(d, locale: :en)
      {:ok, "11 months and 30 days"}

      iex> Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en)
      {:ok, "2 hours and 30 minutes"}

  """
  @spec format(Localize.Duration.t() | map(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format(duration_or_map, options \\ [])

  def format(%Localize.Duration{} = duration, options) do
    Localize.Duration.to_string(duration, translate_style(options))
  end

  def format(map, options) when is_map(map) do
    duration = to_duration_struct(map)
    Localize.Duration.to_string(duration, translate_style(options))
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
  # option (Localize deprecated :format's old name :style in 0.43).
  defp translate_style(options) do
    case Keyword.pop(options, :style) do
      {nil, options} -> options
      {style, options} -> Keyword.put_new(options, :format, style)
    end
  end

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
