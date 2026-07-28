defmodule Intl.DocExamplesTest do
  @moduledoc """
  Executes every `iex>` example in the README and the guides so a
  documented result cannot drift from the real one.

  The examples format in `:de`, `:fr`, and `:ar` as well as the
  bundled `:en`. Only `:en` and `:und` ship with Localize, so when the
  other locale data has not been downloaded these examples would
  silently fall back to `:und` and fail on the fallback output rather
  than on a genuine drift. In that case the file doctests are not
  defined at all and `locale_data_test` below reports what to run.

  CI downloads the data, so the examples are always verified there.

      mix localize.download_locales de fr ar

  """

  use ExUnit.Case, async: true

  @doc_locales [:de, :fr, :ar]

  @missing_locales Enum.reject(@doc_locales, fn locale ->
                     :localize
                     |> :code.priv_dir()
                     |> Path.join("localize/locales/#{locale}.etf")
                     |> File.exists?()
                   end)

  if @missing_locales == [] do
    doctest_file("README.md")
    doctest_file("guides/getting_started.md")
  else
    test "locale data for the documentation examples" do
      flunk("""
      Skipping the README and guide examples: no locale data for \
      #{Enum.map_join(@missing_locales, ", ", &inspect/1)}.

      Download it with:

          mix localize.download_locales #{Enum.join(@missing_locales, " ")}
      """)
    end
  end
end
