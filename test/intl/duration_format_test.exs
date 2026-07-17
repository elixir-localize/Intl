defmodule Intl.DurationFormatTest do
  use ExUnit.Case
  doctest Intl.DurationFormat

  describe "format/2" do
    test "duration struct" do
      {:ok, duration} = Localize.Duration.new(~D[2019-01-01], ~D[2019-12-31])
      assert {:ok, result} = Intl.DurationFormat.format(duration, locale: :en)
      assert String.contains?(result, "month")
    end

    test "map with plural keys" do
      assert {:ok, result} = Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en)
      assert String.contains?(result, "hour")
      assert String.contains?(result, "minute")
    end

    test "map with singular keys" do
      assert {:ok, result} = Intl.DurationFormat.format(%{hour: 1, minute: 15}, locale: :en)
      assert String.contains?(result, "hour")
    end

    test "style option maps to the Localize format option" do
      assert {:ok, "2h and 30m"} =
               Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en, style: :narrow)

      assert {:ok, "2 hr and 30 min"} =
               Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en, style: :short)
    end
  end
end
