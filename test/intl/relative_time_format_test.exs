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
  end
end
