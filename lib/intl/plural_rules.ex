defmodule Intl.PluralRules do
  @moduledoc """
  Plural-sensitive number categorization, modelled on
  [`Intl.PluralRules`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules).

  Returns the CLDR plural category (`:zero`, `:one`, `:two`, `:few`,
  `:many`, or `:other`) for a given number and locale.

  Delegates to `Localize.Number.PluralRule` for the underlying
  plural rule evaluation.

  """

  @typedoc """
  A CLDR plural category.

  """
  @type plural_category :: :zero | :one | :two | :few | :many | :other

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
          {:ok, plural_category()} | {:error, Exception.t()}
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
  @spec select!(number() | Decimal.t(), Keyword.t()) :: plural_category() | no_return()
  def select!(number, options \\ []) do
    case select(number, options) do
      {:ok, category} -> category
      {:error, exception} -> raise exception
    end
  end

  @doc """
  Returns the plural category for a range of numbers.

  Modelled on the JS `Intl.PluralRules.selectRange()`. The category
  of a range like "1–2 days" is selected from the categories of the
  endpoints using the CLDR plural-ranges data for the locale.

  ### Arguments

  * `start_number` is the start of the range.

  * `end_number` is the end of the range.

  * `options` is a keyword list of options.

  ### Options

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  ### Returns

  * `{:ok, category}` where `category` is one of `:zero`, `:one`,
    `:two`, `:few`, `:many`, or `:other`.

  * `{:error, reason}` if the locale or numbers are invalid.

  ### Examples

      iex> Intl.PluralRules.select_range(1, 2, locale: "fr")
      {:ok, :other}

      iex> Intl.PluralRules.select_range(0, 1, locale: "fr")
      {:ok, :one}

      iex> Intl.PluralRules.select_range(102, 201, locale: "en")
      {:ok, :other}

  """
  @spec select_range(number() | Decimal.t(), number() | Decimal.t(), Keyword.t()) ::
          {:ok, plural_category()} | {:error, Exception.t()}
  def select_range(start_number, end_number, options \\ []) do
    locale = Keyword.get(options, :locale, Localize.get_locale())
    Localize.Number.PluralRule.Range.plural_rule_for(start_number, end_number, locale)
  end

  @doc """
  Returns the plural category for a range, raising on error.

  Same as `select_range/3` but returns the category atom directly
  or raises.

  ### Arguments

  * `start_number` is the start of the range.

  * `end_number` is the end of the range.

  * `options` is a keyword list of options.

  ### Returns

  * A plural category atom.

  ### Examples

      iex> Intl.PluralRules.select_range!(1, 2, locale: "fr")
      :other

  """
  @spec select_range!(number() | Decimal.t(), number() | Decimal.t(), Keyword.t()) ::
          plural_category() | no_return()
  def select_range!(start_number, end_number, options \\ []) do
    case select_range(start_number, end_number, options) do
      {:ok, category} -> category
      {:error, exception} -> raise exception
    end
  end
end
