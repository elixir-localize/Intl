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

    test "invalid style returns error" do
      assert {:error, %ArgumentError{}} = Intl.NumberFormat.format(42, locale: :en, style: :bogus)
    end
  end

  describe "format/2 notation" do
    test "scientific notation" do
      assert {:ok, "1.2345E3"} =
               Intl.NumberFormat.format(1234.5, locale: :en, notation: :scientific)
    end

    test "engineering notation" do
      assert {:ok, "123.456E3"} =
               Intl.NumberFormat.format(123_456, locale: :en, notation: :engineering)
    end

    test "compact notation short and long" do
      assert {:ok, "1.2K"} = Intl.NumberFormat.format(1234, locale: :en, notation: :compact)

      assert {:ok, "1.2 thousand"} =
               Intl.NumberFormat.format(1234,
                 locale: :en,
                 notation: :compact,
                 compact_display: :long
               )
    end

    test "compact currency uses the short currency format" do
      assert {:ok, "$1.2K"} =
               Intl.NumberFormat.format(1234,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 notation: :compact
               )
    end

    test "invalid notation returns error" do
      assert {:error, %ArgumentError{}} =
               Intl.NumberFormat.format(1234, locale: :en, notation: :bogus)
    end

    test "invalid compact display returns error" do
      assert {:error, %ArgumentError{}} =
               Intl.NumberFormat.format(1234,
                 locale: :en,
                 notation: :compact,
                 compact_display: :bogus
               )
    end
  end

  describe "format/2 currency options" do
    test "accounting currency sign" do
      assert {:ok, "($1,234.50)"} =
               Intl.NumberFormat.format(-1234.5,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 currency_sign: :accounting
               )
    end

    test "currency display as code" do
      assert {:ok, "USD\u00A01,234.50"} =
               Intl.NumberFormat.format(1234.5,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 currency_display: :code
               )
    end

    test "currency display as name" do
      assert {:ok, "1,234.50 US dollars"} =
               Intl.NumberFormat.format(1234.5,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 currency_display: :name
               )
    end

    test "invalid currency display returns error" do
      assert {:error, %ArgumentError{}} =
               Intl.NumberFormat.format(1234.5,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 currency_display: :bogus
               )
    end
  end

  describe "format/2 digit options" do
    test "significant digits" do
      assert {:ok, "1,230"} =
               Intl.NumberFormat.format(1234.5, locale: :en, maximum_significant_digits: 3)

      assert {:ok, "1.00"} =
               Intl.NumberFormat.format(1, locale: :en, minimum_significant_digits: 3)
    end

    test "grouping can be disabled" do
      assert {:ok, "1234567"} =
               Intl.NumberFormat.format(1_234_567, locale: :en, use_grouping: false)
    end

    test "min2 grouping" do
      assert {:ok, "1234"} = Intl.NumberFormat.format(1234, locale: :en, use_grouping: :min2)
      assert {:ok, "12,345"} = Intl.NumberFormat.format(12_345, locale: :en, use_grouping: :min2)
    end

    test "rounding increment" do
      assert {:ok, "125"} =
               Intl.NumberFormat.format(123.456,
                 locale: :en,
                 rounding_increment: 5,
                 maximum_fraction_digits: 0
               )
    end

    test "minimum integer digits" do
      assert {:ok, "005"} = Intl.NumberFormat.format(5, locale: :en, minimum_integer_digits: 3)

      assert {:ok, "$005.00"} =
               Intl.NumberFormat.format(5,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 minimum_integer_digits: 3
               )
    end

    test "trailing zero display strip_if_integer" do
      assert {:ok, "1,000"} =
               Intl.NumberFormat.format(1000,
                 locale: :en,
                 minimum_fraction_digits: 2,
                 trailing_zero_display: :strip_if_integer
               )

      assert {:ok, "1,000.50"} =
               Intl.NumberFormat.format(1000.5,
                 locale: :en,
                 minimum_fraction_digits: 2,
                 trailing_zero_display: :strip_if_integer
               )
    end

    test "rounding priority auto ignores fraction bounds when significant digits are set" do
      assert {:ok, "4.32"} =
               Intl.NumberFormat.format(4.321,
                 locale: :en,
                 maximum_fraction_digits: 1,
                 maximum_significant_digits: 3
               )
    end

    test "rounding priority more and less precision" do
      assert {:ok, "4.32"} =
               Intl.NumberFormat.format(4.321,
                 locale: :en,
                 maximum_fraction_digits: 1,
                 maximum_significant_digits: 3,
                 rounding_priority: :more_precision
               )

      assert {:ok, "4.3"} =
               Intl.NumberFormat.format(4.321,
                 locale: :en,
                 maximum_fraction_digits: 1,
                 maximum_significant_digits: 3,
                 rounding_priority: :less_precision
               )
    end

    test "invalid rounding priority returns error" do
      assert {:error, %ArgumentError{}} =
               Intl.NumberFormat.format(1, locale: :en, rounding_priority: :bogus)
    end
  end

  describe "format/2 sign display" do
    test "always shows the sign" do
      assert {:ok, "+1,234.5"} =
               Intl.NumberFormat.format(1234.5, locale: :en, sign_display: :always)

      assert {:ok, "-1,234.5"} =
               Intl.NumberFormat.format(-1234.5, locale: :en, sign_display: :always)
    end

    test "except_zero omits the sign on zero" do
      assert {:ok, "0"} = Intl.NumberFormat.format(0, locale: :en, sign_display: :except_zero)
      assert {:ok, "+1"} = Intl.NumberFormat.format(1, locale: :en, sign_display: :except_zero)
    end

    test "never suppresses the sign" do
      assert {:ok, "1,234.5"} =
               Intl.NumberFormat.format(-1234.5, locale: :en, sign_display: :never)
    end

    test "sign display with currency style" do
      assert {:ok, "+$1,234.50"} =
               Intl.NumberFormat.format(1234.5,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 sign_display: :always
               )
    end

    test "invalid sign display returns error" do
      assert {:error, %Localize.InvalidValueError{}} =
               Intl.NumberFormat.format(1, locale: :en, sign_display: :bogus)
    end
  end

  describe "format/2 numbering system" do
    test "numbering system option" do
      assert {:ok, "๑,๒๓๔.๕"} =
               Intl.NumberFormat.format(1234.5, locale: :en, numbering_system: :thai)
    end

    test "numbering system via locale extension" do
      assert {:ok, "๑,๒๓๔.๕"} = Intl.NumberFormat.format(1234.5, locale: "en-u-nu-thai")
    end
  end

  describe "format/2 negative numbers" do
    test "negative currency renders the sign before the symbol" do
      assert {:ok, "-$1.00"} =
               Intl.NumberFormat.format(-1, locale: :en, style: :currency, currency: :USD)
    end
  end

  describe "format_to_parts/2" do
    test "currency parts" do
      assert {:ok,
              [
                %{type: :currency, value: "$"},
                %{type: :integer, value: "1"},
                %{type: :group, value: ","},
                %{type: :integer, value: "234"},
                %{type: :decimal, value: "."},
                %{type: :fraction, value: "50"}
              ]} =
               Intl.NumberFormat.format_to_parts(1234.5,
                 locale: :en,
                 style: :currency,
                 currency: :USD
               )
    end

    test "compact short affix has no literal when unspaced" do
      assert {:ok,
              [
                %{type: :integer, value: "1"},
                %{type: :decimal, value: "."},
                %{type: :fraction, value: "2"},
                %{type: :compact, value: "K"}
              ]} = Intl.NumberFormat.format_to_parts(1234, locale: :en, notation: :compact)
    end

    test "unit style decomposes with a :unit part" do
      assert {:ok,
              [
                %{type: :integer, value: "1"},
                %{type: :literal, value: " "},
                %{type: :unit, value: "m"}
              ]} = Intl.NumberFormat.format_to_parts(1, locale: :en, style: :unit, unit: "meter")

      assert {:ok,
              [
                %{type: :integer, value: "42"},
                %{type: :literal, value: " "},
                %{type: :unit, value: "meters"}
              ]} =
               Intl.NumberFormat.format_to_parts(42,
                 locale: :en,
                 style: :unit,
                 unit: "meter",
                 unit_display: :long
               )
    end

    test "currency display name decomposes with a :currency name part" do
      assert {:ok, parts} =
               Intl.NumberFormat.format_to_parts(1,
                 locale: :en,
                 style: :currency,
                 currency: :USD,
                 currency_display: :name
               )

      assert %{type: :currency, value: "US dollars"} in parts
    end
  end

  describe "format_range_to_parts/3" do
    test "range parts carry sources" do
      assert {:ok,
              [
                %{type: :integer, value: "3", source: :start_range},
                %{type: :literal, value: "–", source: :shared},
                %{type: :integer, value: "5", source: :end_range}
              ]} = Intl.NumberFormat.format_range_to_parts(3, 5, locale: :en)
    end

    test "currency range parts concatenate to the range string" do
      options = [locale: :en, style: :currency, currency: :USD]
      {:ok, parts} = Intl.NumberFormat.format_range_to_parts(100, 200, options)
      {:ok, string} = Intl.NumberFormat.format_range(100, 200, options)

      assert Enum.map_join(parts, & &1.value) == string
    end
  end

  describe "format_range/3 unit style" do
    test "the unit pattern applies once to the range" do
      assert {:ok, "2–5 kilometers"} =
               Intl.NumberFormat.format_range(2, 5,
                 locale: :en,
                 style: :unit,
                 unit: "kilometer",
                 unit_display: :long
               )
    end
  end

  describe "format_range/3" do
    test "range formatting" do
      assert {:ok, result} = Intl.NumberFormat.format_range(100, 200, locale: :en)
      assert String.contains?(result, "100")
      assert String.contains?(result, "200")
    end

    test "currency range" do
      assert {:ok, "$100.00–$200.00"} =
               Intl.NumberFormat.format_range(100, 200,
                 locale: :en,
                 style: :currency,
                 currency: :USD
               )
    end

    test "percent range" do
      assert {:ok, "10%–20%"} =
               Intl.NumberFormat.format_range(0.1, 0.2, locale: :en, style: :percent)
    end

    test "unit style range returns error" do
      assert {:error, %ArgumentError{}} =
               Intl.NumberFormat.format_range(1, 2, locale: :en, style: :unit)
    end
  end
end
