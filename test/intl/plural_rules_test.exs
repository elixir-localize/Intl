defmodule Intl.PluralRulesTest do
  use ExUnit.Case
  doctest Intl.PluralRules

  describe "select/2" do
    test "one for English" do
      assert {:ok, :one} = Intl.PluralRules.select(1, locale: "en")
    end

    test "other for English" do
      assert {:ok, :other} = Intl.PluralRules.select(2, locale: "en")
    end

    test "ordinal type" do
      assert {:ok, :two} = Intl.PluralRules.select(2, locale: "en", type: :ordinal)
    end
  end
end
