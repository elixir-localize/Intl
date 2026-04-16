defmodule Intl.DisplayNames do
  @moduledoc """
  Locale-sensitive display name resolution, modelled on
  [`Intl.DisplayNames`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DisplayNames).

  Returns the localized display name for a given code based on its
  type: region, language, currency, script, calendar, or
  date-time field.

  Delegates to `Localize.Territory`, `Localize.Language`,
  `Localize.Currency`, `Localize.Script`, and `Localize.Calendar`
  for the underlying lookups.

  """

  @doc """
  Returns the localized display name for the given code.

  ### Arguments

  * `code` is a string or atom identifying the entity
    (for example, `"US"` for a region, `"fr"` for a language,
    or `"EUR"` for a currency).

  * `options` is a keyword list of options.

  ### Options

  * `:type` is a required option. One of `:region`, `:language`,
    `:currency`, `:script`, `:calendar`, or `:date_time_field`.

  * `:locale` is a locale identifier string or atom. The default
    is the current process locale.

  * `:style` is `:standard`, `:short`, `:long`, `:menu`, or
    `:variant` where applicable. The default varies by type.

  ### Returns

  * `{:ok, display_name}` on success.

  * `{:error, reason}` if the code or type is invalid.

  ### Examples

      iex> Intl.DisplayNames.of("US", type: :region, locale: :en)
      {:ok, "United States"}

      iex> Intl.DisplayNames.of("fr", type: :language, locale: :en)
      {:ok, "French"}

      iex> Intl.DisplayNames.of("EUR", type: :currency, locale: :en)
      {:ok, "Euro"}

      iex> Intl.DisplayNames.of(:Latn, type: :script, locale: :en)
      {:ok, "Latin"}

      iex> Intl.DisplayNames.of(:gregorian, type: :calendar, locale: :en)
      {:ok, "Gregorian Calendar"}

      iex> Intl.DisplayNames.of(:year, type: :date_time_field, locale: :en)
      {:ok, "year"}

  """
  @spec of(String.t() | atom(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def of(code, options \\ []) do
    {type, options} = Keyword.pop(options, :type)

    case type do
      :region ->
        Localize.Territory.display_name(code, options)

      :language ->
        Localize.Language.display_name(code, options)

      :currency ->
        Localize.Currency.display_name(code, options)

      :script ->
        Localize.Script.display_name(code, options)

      :calendar ->
        Localize.Calendar.display_name(:calendar, code, options)

      :date_time_field ->
        Localize.Calendar.display_name(:date_time_field, code, options)

      nil ->
        {:error, ArgumentError.exception("The :type option is required")}

      other ->
        {:error,
         ArgumentError.exception(
           "Unsupported type: #{inspect(other)}. " <>
             "Expected :region, :language, :currency, :script, :calendar, or :date_time_field."
         )}
    end
  end

  @doc """
  Returns the localized display name, raising on error.

  Same as `of/2` but returns the string directly or raises.

  ### Arguments

  * `code` is a string or atom identifying the entity.

  * `options` is a keyword list of options.

  ### Returns

  * A display name string.

  ### Examples

      iex> Intl.DisplayNames.of!("US", type: :region, locale: :en)
      "United States"

  """
  @spec of!(String.t() | atom(), Keyword.t()) :: String.t() | no_return()
  def of!(code, options \\ []) do
    case of(code, options) do
      {:ok, name} -> name
      {:error, exception} -> raise exception
    end
  end
end
