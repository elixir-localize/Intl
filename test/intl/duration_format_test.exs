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
  end
end
