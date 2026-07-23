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

  `segment/2` returns a flat list of segment strings for
  simplicity. `segment_with_metadata/2` mirrors the JS segment
  objects, returning maps with `:segment`, `:index`, and
  `:word_like?` keys.

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

  @doc """
  Segments a string into a list of segment maps with metadata.

  Modelled on the JS `Intl.Segmenter` segment objects. Each map has
  a `:segment` (the text), an `:index` (the byte offset of the
  segment in the input, where JS uses UTF-16 code-unit indexes),
  and a `:word_like?` key. `:word_like?` is a boolean for
  `:word` granularity — `true` when the segment contains alphabetic
  or numeric content — and `nil` for other granularities, matching
  the JS `isWordLike` being undefined outside word segmentation.

  ### Arguments

  * `string` is the text to segment.

  * `options` is a keyword list of options. Accepts the same
    options as `segment/2`. With `trim: true`, whitespace-only
    segments are removed after indexing, so the remaining
    `:index` values still refer to the original string.

  ### Returns

  * `{:ok, segments}` where `segments` is a list of
    `%{segment: String.t(), index: non_neg_integer, word_like?: boolean | nil}`
    maps.

  * `{:error, reason}` if the granularity is not supported or
    the `unicode_string` dependency is missing.

  ### Examples

      iex> Intl.Segmenter.segment_with_metadata("Hi there!", granularity: :word)
      {:ok, [
        %{segment: "Hi", index: 0, word_like?: true},
        %{segment: " ", index: 2, word_like?: false},
        %{segment: "there", index: 3, word_like?: true},
        %{segment: "!", index: 8, word_like?: false}
      ]}

  """
  @spec segment_with_metadata(String.t(), Keyword.t()) ::
          {:ok, [%{segment: String.t(), index: non_neg_integer(), word_like?: boolean() | nil}]}
          | {:error, term()}
  def segment_with_metadata(string, options \\ []) do
    {trim, options} = Keyword.pop(options, :trim, false)

    with {:ok, segments} <- segment(string, options) do
      granularity = Keyword.get(options, :granularity, :grapheme)

      metadata =
        segments
        |> attach_metadata(granularity)
        |> maybe_reject_whitespace(trim)

      {:ok, metadata}
    end
  end

  @doc """
  Segments a string into segment maps, raising on error.

  Same as `segment_with_metadata/2` but returns the list directly
  or raises.

  ### Arguments

  * `string` is the text to segment.

  * `options` is a keyword list of options.

  ### Returns

  * A list of `%{segment: String.t(), index: non_neg_integer, word_like?: boolean | nil}` maps.

  ### Examples

      iex> Intl.Segmenter.segment_with_metadata!("Hi", granularity: :word)
      [%{segment: "Hi", index: 0, word_like?: true}]

  """
  @spec segment_with_metadata!(String.t(), Keyword.t()) ::
          [%{segment: String.t(), index: non_neg_integer(), word_like?: boolean() | nil}]
          | no_return()
  def segment_with_metadata!(string, options \\ []) do
    case segment_with_metadata(string, options) do
      {:ok, segments} -> segments
      {:error, exception} -> raise exception
    end
  end

  defp attach_metadata(segments, granularity) do
    {annotated, _offset} =
      Enum.map_reduce(segments, 0, fn segment, offset ->
        metadata = %{
          segment: segment,
          index: offset,
          word_like?: word_like(segment, granularity)
        }

        {metadata, offset + byte_size(segment)}
      end)

    annotated
  end

  defp word_like(segment, :word), do: Unicode.String.word_like?(segment)
  defp word_like(_segment, _granularity), do: nil

  defp maybe_reject_whitespace(annotated, true) do
    Enum.reject(annotated, &(String.trim(&1.segment) == ""))
  end

  defp maybe_reject_whitespace(annotated, false), do: annotated

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
           "Add {:unicode_string, \"~> 2.3\"} to your mix.exs dependencies."
       )}
    end
  end
end
