defmodule Intl.CollatorTest do
  use ExUnit.Case
  doctest Intl.Collator

  describe "compare/3" do
    test "less than" do
      assert :lt = Intl.Collator.compare("a", "b", locale: :en)
    end

    test "greater than" do
      assert :gt = Intl.Collator.compare("b", "a", locale: :en)
    end

    test "equal" do
      assert :eq = Intl.Collator.compare("a", "a", locale: :en)
    end
  end

  describe "sort/2" do
    test "sorts strings by locale" do
      assert ["apple", "banana", "cherry"] =
               Intl.Collator.sort(["banana", "apple", "cherry"], locale: :en)
    end
  end
end
