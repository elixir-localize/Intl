defmodule Intl.ListFormatTest do
  use ExUnit.Case
  doctest Intl.ListFormat

  describe "format/2" do
    test "conjunction with long style" do
      assert {:ok, "a, b, and c"} = Intl.ListFormat.format(["a", "b", "c"], locale: :en)
    end

    test "disjunction with long style" do
      assert {:ok, "a, b, or c"} =
               Intl.ListFormat.format(["a", "b", "c"], locale: :en, type: :disjunction)
    end

    test "unit with narrow style" do
      assert {:ok, _} =
               Intl.ListFormat.format(["a", "b"], locale: :en, type: :unit, style: :narrow)
    end

    test "single element" do
      assert {:ok, "a"} = Intl.ListFormat.format(["a"], locale: :en)
    end

    test "invalid type returns error" do
      assert {:error, _} = Intl.ListFormat.format(["a"], locale: :en, type: :invalid)
    end
  end
end
