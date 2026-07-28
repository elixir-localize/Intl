defmodule Intl.DisplayNamesTest do
  use ExUnit.Case
  doctest Intl.DisplayNames

  describe "of/2" do
    test "region display name" do
      assert {:ok, "United States"} = Intl.DisplayNames.of("US", type: :region, locale: :en)
    end

    test "language display name" do
      assert {:ok, "French"} = Intl.DisplayNames.of("fr", type: :language, locale: :en)
    end

    test "currency display name" do
      assert {:ok, "Euro"} = Intl.DisplayNames.of("EUR", type: :currency, locale: :en)
    end

    test "script display name" do
      assert {:ok, "Latin"} = Intl.DisplayNames.of(:Latn, type: :script, locale: :en)
    end

    test "script display name with string code" do
      assert {:ok, "Cyrillic"} = Intl.DisplayNames.of("Cyrl", type: :script, locale: :en)
    end

    test "calendar display name" do
      assert {:ok, "Gregorian Calendar"} =
               Intl.DisplayNames.of(:gregorian, type: :calendar, locale: :en)
    end

    test "date_time_field display name" do
      assert {:ok, "year"} =
               Intl.DisplayNames.of(:year, type: :date_time_field, locale: :en)
    end

    test "date_time_field accepts the JS field spellings" do
      assert {:ok, "week"} =
               Intl.DisplayNames.of(:week_of_year, type: :date_time_field, locale: :en)

      assert {:ok, "week"} =
               Intl.DisplayNames.of("weekOfYear", type: :date_time_field, locale: :en)

      assert {:ok, "time zone"} =
               Intl.DisplayNames.of(:time_zone_name, type: :date_time_field, locale: :en)

      assert {:ok, "time zone"} =
               Intl.DisplayNames.of("timeZoneName", type: :date_time_field, locale: :en)
    end

    test "date_time_field accepts the Localize field names" do
      assert {:ok, "week"} = Intl.DisplayNames.of(:week, type: :date_time_field, locale: :en)
      assert {:ok, "time zone"} = Intl.DisplayNames.of(:zone, type: :date_time_field, locale: :en)

      assert {:ok, "day of the week"} =
               Intl.DisplayNames.of(:weekday, type: :date_time_field, locale: :en)

      assert {:ok, "AM/PM"} =
               Intl.DisplayNames.of(:day_period, type: :date_time_field, locale: :en)
    end

    test "missing type returns error" do
      assert {:error, _} = Intl.DisplayNames.of("US")
    end

    test "unknown type returns an error rather than raising" do
      assert {:error, %ArgumentError{}} = Intl.DisplayNames.of("US", type: :nonsense)
    end
  end
end
