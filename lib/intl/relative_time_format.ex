defmodule Intl.RelativeTimeFormat do
  @moduledoc """
  Locale-sensitive relative time formatting, modelled on
  [`Intl.RelativeTimeFormat`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/RelativeTimeFormat).

  Produces strings such as "3 days ago", "in 2 hours", "yesterday",
  or "tomorrow" depending on the value, unit, and locale.

  Delegates to `Localize.DateTime.Relative` for the underlying
  formatting.

  """

  @style_to_format %{
    long: :standard,
    short: :short,
    narrow: :narrow
  }

  @doc """
  Formats a relative time value.

  ### Arguments

  * `value` is an integer representing the offset. Negative values
    indicate the past (for example, -1 for "1 day ago"), positive
    values indicate the future (for example, 2 for "in 2 hours").

  * `unit` is the time unit atom: `:second`, `:minute`, `:hour`,
    `:day`, `:week`, `:month`, `:year`, or `:quarter`.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:style` is `:long`, `:short`, or `:narrow`. The default
    is `:long`.

  * `:numeric` is `:always` or `:auto`. When `:auto`, special
    forms like "yesterday" and "tomorrow" may be used instead of
    "1 day ago" and "in 1 day". The default is `:auto`.

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if the value, unit, or options are invalid.

  ### Examples

      iex> Intl.RelativeTimeFormat.format(-1, :day, locale: :en)
      {:ok, "yesterday"}

      iex> Intl.RelativeTimeFormat.format(2, :hour, locale: :en)
      {:ok, "in 2 hours"}

      iex> Intl.RelativeTimeFormat.format(-3, :day, locale: :en)
      {:ok, "3 days ago"}

  """
  @spec format(integer(), atom(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def format(value, unit, options \\ []) do
    {style, options} = Keyword.pop(options, :style, :long)
    {_numeric, options} = Keyword.pop(options, :numeric, :auto)

    localize_format = Map.get(@style_to_format, style, :standard)

    localize_options =
      options
      |> Keyword.put(:unit, unit)
      |> Keyword.put(:format, localize_format)

    Localize.DateTime.Relative.to_string(value, localize_options)
  end

  @doc """
  Formats a relative time value, raising on error.

  Same as `format/3` but returns the string directly or raises.

  ### Arguments

  * `value` is an integer offset.

  * `unit` is the time unit atom.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.RelativeTimeFormat.format!(-1, :day, locale: :en)
      "yesterday"

  """
  @spec format!(integer(), atom(), Keyword.t()) :: String.t() | no_return()
  def format!(value, unit, options \\ []) do
    case format(value, unit, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end
end
