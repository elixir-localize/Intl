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

  describe "format_to_parts/2" do
    test "elements and literals are tagged" do
      assert {:ok,
              [
                %{type: :element, value: "a"},
                %{type: :literal, value: ", "},
                %{type: :element, value: "b"},
                %{type: :literal, value: ", and "},
                %{type: :element, value: "c"}
              ]} = Intl.ListFormat.format_to_parts(["a", "b", "c"], locale: :en)
    end

    test "type and style apply" do
      {:ok, parts} =
        Intl.ListFormat.format_to_parts(["a", "b"], locale: :en, type: :disjunction)

      assert Enum.map_join(parts, & &1.value) == "a or b"
    end

    test "invalid type returns error" do
      assert {:error, _} = Intl.ListFormat.format_to_parts(["a"], locale: :en, type: :invalid)
    end
  end
end
