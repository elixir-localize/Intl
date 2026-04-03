defmodule Intl.DisplayNamesTest do
  use ExUnit.Case
  doctest Intl.DisplayNames

  describe "of/2" do
    test "region display name" do
      assert {:ok, "United States"} = Intl.DisplayNames.of("US", type: :region, locale: :en)
    end

    test "language display name" do
      assert {:ok, "French"} = Intl.DisplayNames.of("fr", type: :language, locale: :en)
    end

    test "currency display name" do
      assert {:ok, "Euro"} = Intl.DisplayNames.of("EUR", type: :currency, locale: :en)
    end

    test "script display name" do
      assert {:ok, "Latin"} = Intl.DisplayNames.of(:Latn, type: :script, locale: :en)
    end

    test "script display name with string code" do
      assert {:ok, "Cyrillic"} = Intl.DisplayNames.of("Cyrl", type: :script, locale: :en)
    end

    test "missing type returns error" do
      assert {:error, _} = Intl.DisplayNames.of("US")
    end
  end
end
