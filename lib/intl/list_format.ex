defmodule Intl.ListFormat do
  @moduledoc """
  Locale-sensitive list formatting, modelled on
  [`Intl.ListFormat`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/ListFormat).

  Joins a list of items into a human-readable string using
  locale-appropriate conjunctions ("and"), disjunctions ("or"),
  or unit-style separators.

  Delegates to `Localize.List` for the underlying formatting.

  """

  @format_map %{
    {:conjunction, :long} => :standard,
    {:conjunction, :short} => :standard_short,
    {:conjunction, :narrow} => :standard_narrow,
    {:disjunction, :long} => :or,
    {:disjunction, :short} => :or_short,
    {:disjunction, :narrow} => :or_narrow,
    {:unit, :long} => :unit,
    {:unit, :short} => :unit_short,
    {:unit, :narrow} => :unit_narrow
  }

  @doc """
  Formats a list into a locale-aware string.

  ### Arguments

  * `list` is a list of terms that implement `String.Chars`.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:type` is `:conjunction`, `:disjunction`, or `:unit`.
    The default is `:conjunction`.

  * `:style` is `:long`, `:short`, or `:narrow`.
    The default is `:long`.

  ### Returns

  * `{:ok, formatted_string}` on success.

  * `{:error, reason}` if the locale or options are invalid.

  ### Examples

      iex> Intl.ListFormat.format(["a", "b", "c"], locale: :en)
      {:ok, "a, b, and c"}

      iex> Intl.ListFormat.format(["a", "b", "c"], locale: :en, type: :disjunction)
      {:ok, "a, b, or c"}

      iex> Intl.ListFormat.format(["a", "b"], locale: :en, type: :unit, style: :narrow)
      {:ok, "a b"}

  """
  @spec format([term()], Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def format(list, options \\ []) do
    {type, options} = Keyword.pop(options, :type, :conjunction)
    {style, options} = Keyword.pop(options, :style, :long)

    case resolve_format(type, style) do
      {:ok, localize_format} ->
        Localize.List.to_string(list, Keyword.put(options, :list_style, localize_format))

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Formats a list into a locale-aware string, raising on error.

  Same as `format/2` but returns the string directly or raises.

  ### Arguments

  * `list` is a list of terms that implement `String.Chars`.

  * `options` is a keyword list of options.

  ### Returns

  * A formatted string.

  ### Examples

      iex> Intl.ListFormat.format!(["a", "b", "c"], locale: :en)
      "a, b, and c"

  """
  @spec format!([term()], Keyword.t()) :: String.t() | no_return()
  def format!(list, options \\ []) do
    case format(list, options) do
      {:ok, string} -> string
      {:error, exception} -> raise exception
    end
  end

  defp resolve_format(type, style) do
    case Map.fetch(@format_map, {type, style}) do
      {:ok, format} ->
        {:ok, format}

      :error ->
        {:error,
         ArgumentError.exception(
           "Invalid type/style combination: #{inspect(type)}/#{inspect(style)}. " <>
             "Type must be :conjunction, :disjunction, or :unit. " <>
             "Style must be :long, :short, or :narrow."
         )}
    end
  end
end
