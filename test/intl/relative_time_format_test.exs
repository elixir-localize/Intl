defmodule Intl.RelativeTimeFormatTest do
  use ExUnit.Case
  doctest Intl.RelativeTimeFormat

  describe "format/3" do
    test "yesterday" do
      assert {:ok, "yesterday"} = Intl.RelativeTimeFormat.format(-1, :day, locale: :en)
    end

    test "tomorrow" do
      assert {:ok, "tomorrow"} = Intl.RelativeTimeFormat.format(1, :day, locale: :en)
    end

    test "days ago" do
      assert {:ok, "3 days ago"} = Intl.RelativeTimeFormat.format(-3, :day, locale: :en)
    end

    test "in hours" do
      assert {:ok, "in 2 hours"} = Intl.RelativeTimeFormat.format(2, :hour, locale: :en)
    end

    test "numeric always forces numeric output" do
      assert {:ok, "1 day ago"} =
               Intl.RelativeTimeFormat.format(-1, :day, locale: :en, numeric: :always)

      assert {:ok, "in 1 day"} =
               Intl.RelativeTimeFormat.format(1, :day, locale: :en, numeric: :always)
    end

    test "zero offset formats with the future pattern" do
      assert {:ok, "in 0 days"} =
               Intl.RelativeTimeFormat.format(0, :day, locale: :en, numeric: :always)
    end
  end

  describe "format_to_parts/3" do
    test "named forms are a single literal part" do
      assert {:ok, [%{type: :literal, value: "yesterday"}]} =
               Intl.RelativeTimeFormat.format_to_parts(-1, :day, locale: :en)
    end

    test "numeric forms tag the integer with its unit" do
      assert {:ok,
              [
                %{type: :integer, value: "3", unit: :day},
                %{type: :literal, value: " days ago"}
              ]} = Intl.RelativeTimeFormat.format_to_parts(-3, :day, locale: :en)
    end

    test "style and numeric options apply" do
      {:ok, parts} =
        Intl.RelativeTimeFormat.format_to_parts(-1, :day,
          locale: :en,
          numeric: :always,
          style: :narrow
        )

      assert Enum.map_join(parts, & &1.value) ==
               Intl.RelativeTimeFormat.format!(-1, :day,
                 locale: :en,
                 numeric: :always,
                 style: :narrow
               )
    end
  end
end
