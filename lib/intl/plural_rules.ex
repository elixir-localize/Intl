defmodule Intl.PluralRules do
  @moduledoc """
  Plural-sensitive number categorization, modelled on
  [`Intl.PluralRules`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules).

  Returns the CLDR plural category (`:zero`, `:one`, `:two`, `:few`,
  `:many`, or `:other`) for a given number and locale.

  Delegates to `Localize.Number.PluralRule` for the underlying
  plural rule evaluation.

  """

  @doc """
  Returns the plural category for a given number.

  ### Arguments

  * `number` is an integer, float, or `Decimal`.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:type` is `:cardinal` or `:ordinal`. The default is
    `:cardinal`.

  ### Returns

  * `{:ok, category}` where `category` is one of `:zero`, `:one`,
    `:two`, `:few`, `:many`, or `:other`.

  * `{:error, reason}` if the locale or number is invalid.

  ### Examples

      iex> Intl.PluralRules.select(1, locale: "en")
      {:ok, :one}

      iex> Intl.PluralRules.select(2, locale: "en")
      {:ok, :other}

      iex> Intl.PluralRules.select(2, locale: "en", type: :ordinal)
      {:ok, :two}

  """
  @spec select(number() | Decimal.t(), Keyword.t()) ::
          {:ok, atom()} | {:error, term()}
  def select(number, options \\ []) do
    case Localize.Number.PluralRule.plural_type(number, options) do
      {:error, _} = error -> error
      category when is_atom(category) -> {:ok, category}
    end
  end

  @doc """
  Returns the plural category, raising on error.

  Same as `select/2` but returns the category atom directly
  or raises.

  ### Arguments

  * `number` is an integer, float, or `Decimal`.

  * `options` is a keyword list of options.

  ### Returns

  * A plural category atom.

  ### Examples

      iex> Intl.PluralRules.select!(1, locale: "en")
      :one

  """
  @spec select!(number() | Decimal.t(), Keyword.t()) :: atom() | no_return()
  def select!(number, options \\ []) do
    case select(number, options) do
      {:ok, category} -> category
      {:error, exception} -> raise exception
    end
  end
end
