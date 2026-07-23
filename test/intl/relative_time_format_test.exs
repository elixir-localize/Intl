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
end
