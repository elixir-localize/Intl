defmodule Intl.Collator do
  @moduledoc """
  Locale-sensitive string comparison, modelled on
  [`Intl.Collator`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/Collator).

  Compares and sorts strings according to the Unicode Collation
  Algorithm with CLDR locale tailoring.

  Delegates to `Localize.Collation` for the underlying comparison.

  Note: the JS Intl.Collator returns -1, 0, or 1 from `compare`.
  This module returns `:lt`, `:eq`, or `:gt` following Elixir
  conventions, making it compatible with `Enum.sort/2`.

  """

  @sensitivity_map %{
    base: :primary,
    accent: :secondary,
    case: :tertiary,
    variant: :quaternary
  }

  @doc """
  Compares two strings according to locale collation rules.

  ### Arguments

  * `string1` is the first string.

  * `string2` is the second string.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:sensitivity` is `:base`, `:accent`, `:case`, or `:variant`.
    The default is `:variant`.

  * `:case_first` is `:upper`, `:lower`, or `:false`.
    Determines whether upper or lower case sorts first.

  * `:numeric` is a boolean. When `true`, numeric substrings
    are compared as numbers (so "2" < "10"). The default is `false`.

  * `:ignore_punctuation` is a boolean. When `true`, punctuation
    is ignored during comparison. The default is `false`.

  ### Returns

  * `:lt` if `string1` sorts before `string2`.

  * `:eq` if the strings are equal under the collation rules.

  * `:gt` if `string1` sorts after `string2`.

  ### Examples

      iex> Intl.Collator.compare("a", "b", locale: :en)
      :lt

      iex> Intl.Collator.compare("b", "a", locale: :en)
      :gt

      iex> Intl.Collator.compare("a", "a", locale: :en)
      :eq

  """
  @spec compare(String.t(), String.t(), Keyword.t()) :: :lt | :eq | :gt
  def compare(string1, string2, options \\ []) do
    localize_options = translate_options(options)
    Localize.Collation.compare(string1, string2, localize_options)
  end

  @doc """
  Sorts a list of strings according to locale collation rules.

  This is an Elixir convenience function not present in the JS
  Intl.Collator API.

  ### Arguments

  * `list` is a list of strings.

  * `options` is a keyword list of options. Accepts the same
    options as `compare/3`.

  ### Returns

  * A sorted list of strings.

  ### Examples

      iex> Intl.Collator.sort(["banana", "apple", "cherry"], locale: :en)
      ["apple", "banana", "cherry"]

  """
  @spec sort([String.t()], Keyword.t()) :: [String.t()]
  def sort(list, options \\ []) do
    localize_options = translate_options(options)
    Localize.Collation.sort(list, localize_options)
  end

  defp translate_options(options) do
    options
    |> translate_sensitivity()
    |> translate_ignore_punctuation()
    |> Keyword.delete(:sensitivity)
    |> Keyword.delete(:ignore_punctuation)
  end

  defp translate_sensitivity(options) do
    case Keyword.fetch(options, :sensitivity) do
      {:ok, sensitivity} ->
        strength = Map.get(@sensitivity_map, sensitivity, sensitivity)
        Keyword.put(options, :strength, strength)

      :error ->
        options
    end
  end

  defp translate_ignore_punctuation(options) do
    case Keyword.pop(options, :ignore_punctuation) do
      {true, rest} -> Keyword.put(rest, :alternate, :shifted)
      {_, _rest} -> options
    end
  end
end
