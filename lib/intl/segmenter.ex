defmodule Intl.Segmenter do
  @moduledoc """
  Text segmentation, modelled on
  [`Intl.Segmenter`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/Segmenter).

  Splits text into segments by grapheme cluster, word, or sentence
  boundaries.

  * `:grapheme` segmentation uses Elixir's built-in
    `String.graphemes/1` and is always available.

  * `:word` and `:sentence` segmentation requires the optional
    `unicode_string` dependency. When that library is not
    installed, these granularities return an error.

  Note: the JS `Intl.Segmenter` returns an iterable of rich
  segment objects with `segment`, `index`, `input`, and
  `isWordLike` properties. This module returns a flat list of
  segment strings for simplicity.

  """

  @doc """
  Segments a string into a list of substrings.

  ### Arguments

  * `string` is the text to segment.

  * `options` is a keyword list of options.

  ### Options

  * `:granularity` is `:grapheme`, `:word`, or `:sentence`.
    The default is `:grapheme`.

  * `:locale` is a locale identifier string. Only used for
    `:word` and `:sentence` granularity. The default is `"root"`.

  * `:trim` is a boolean. When `true`, whitespace-only segments
    are removed. Only applies to `:word` and `:sentence`
    granularity. The default is `false`.

  ### Returns

  * `{:ok, segments}` where `segments` is a list of strings.

  * `{:error, reason}` if the granularity is not supported or
    the `unicode_string` dependency is missing.

  ### Examples

      iex> Intl.Segmenter.segment("héllo", granularity: :grapheme)
      {:ok, ["h", "é", "l", "l", "o"]}

  """
  @spec segment(String.t(), Keyword.t()) ::
          {:ok, [String.t()]} | {:error, term()}
  def segment(string, options \\ []) do
    granularity = Keyword.get(options, :granularity, :grapheme)

    case granularity do
      :grapheme ->
        {:ok, String.graphemes(string)}

      :word ->
        segment_with_unicode_string(string, :word, options)

      :sentence ->
        segment_with_unicode_string(string, :sentence, options)

      other ->
        {:error,
         ArgumentError.exception(
           "Unsupported granularity: #{inspect(other)}. " <>
             "Expected :grapheme, :word, or :sentence."
         )}
    end
  end

  @doc """
  Segments a string, raising on error.

  Same as `segment/2` but returns the list directly or raises.

  ### Arguments

  * `string` is the text to segment.

  * `options` is a keyword list of options.

  ### Returns

  * A list of segment strings.

  ### Examples

      iex> Intl.Segmenter.segment!("héllo", granularity: :grapheme)
      ["h", "é", "l", "l", "o"]

  """
  @spec segment!(String.t(), Keyword.t()) :: [String.t()] | no_return()
  def segment!(string, options \\ []) do
    case segment(string, options) do
      {:ok, segments} -> segments
      {:error, exception} -> raise exception
    end
  end

  defp segment_with_unicode_string(string, break_type, options) do
    if Code.ensure_loaded?(Unicode.String) do
      locale = Keyword.get(options, :locale, "root")
      trim = Keyword.get(options, :trim, false)

      unicode_options = [break: break_type, locale: locale, trim: trim]

      case Unicode.String.split(string, unicode_options) do
        {:error, _} = error -> error
        segments when is_list(segments) -> {:ok, segments}
      end
    else
      {:error,
       RuntimeError.exception(
         "The :unicode_string dependency is required for #{inspect(break_type)} segmentation. " <>
           "Add {:unicode_string, \"~> 1.8\"} to your mix.exs dependencies."
       )}
    end
  end
end
