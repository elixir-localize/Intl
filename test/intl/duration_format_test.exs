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

  describe "format/2 per-unit options" do
    test "per-unit display renders zero-valued units" do
      assert {:ok, "2 hours and 0 minutes"} =
               Intl.DurationFormat.format(%{hours: 2}, locale: :en, minutes_display: :always)
    end

    test "per-unit styles override the base style" do
      assert {:ok, "2h and 30 minutes"} =
               Intl.DurationFormat.format(%{hours: 2, minutes: 30}, locale: :en, hours: :narrow)

      assert {:ok, "2 hr and 30m"} =
               Intl.DurationFormat.format(%{hours: 2, minutes: 30},
                 locale: :en,
                 hours: :short,
                 minutes: :narrow
               )
    end

    test "invalid per-unit values are errors" do
      assert {:error, %Localize.InvalidValueError{}} =
               Intl.DurationFormat.format(%{hours: 2}, locale: :en, hours_display: :sometimes)
    end
  end
end
