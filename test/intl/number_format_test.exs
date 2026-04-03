defmodule Intl.NumberFormatTest do
  use ExUnit.Case
  doctest Intl.NumberFormat

  describe "format/2" do
    test "decimal formatting" do
      assert {:ok, "1,234.5"} = Intl.NumberFormat.format(1234.5, locale: :en)
    end

    test "percent formatting" do
      assert {:ok, "56%"} = Intl.NumberFormat.format(0.56, locale: :en, style: :percent)
    end

    test "currency formatting" do
      assert {:ok, "$1,234.50"} =
               Intl.NumberFormat.format(1234.5, locale: :en, style: :currency, currency: :USD)
    end

    test "unit formatting" do
      assert {:ok, _formatted} =
               Intl.NumberFormat.format(42, locale: :en, style: :unit, unit: "meter")
    end

    test "unit style without unit returns error" do
      assert {:error, _} = Intl.NumberFormat.format(42, locale: :en, style: :unit)
    end
  end

  describe "format_range/3" do
    test "range formatting" do
      assert {:ok, result} = Intl.NumberFormat.format_range(100, 200, locale: :en)
      assert String.contains?(result, "100")
      assert String.contains?(result, "200")
    end
  end
end
