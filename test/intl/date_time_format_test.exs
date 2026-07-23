defmodule Intl.DateTimeFormatTest do
  use ExUnit.Case
  doctest Intl.DateTimeFormat

  describe "format/2" do
    test "date with full style" do
      assert {:ok, "Monday, July 10, 2017"} =
               Intl.DateTimeFormat.format(~D[2017-07-10], locale: :en, date_style: :full)
    end

    test "date with short style" do
      assert {:ok, "7/10/17"} =
               Intl.DateTimeFormat.format(~D[2017-07-10], locale: :en, date_style: :short)
    end

    test "naive datetime" do
      assert {:ok, _} =
               Intl.DateTimeFormat.format(~N[2017-07-10 14:30:00],
                 locale: :en,
                 date_style: :medium,
                 time_style: :short,
                 prefer: :ascii
               )
    end
  end

  describe "format/2 component options" do
    test "date components match a locale format" do
      assert {:ok, "March 15, 2025"} =
               Intl.DateTimeFormat.format(~D[2025-03-15],
                 locale: :en,
                 year: :numeric,
                 month: :long,
                 day: :numeric
               )
    end

    test "weekday component" do
      assert {:ok, "Saturday, March 15, 2025"} =
               Intl.DateTimeFormat.format(~D[2025-03-15],
                 locale: :en,
                 weekday: :long,
                 year: :numeric,
                 month: :long,
                 day: :numeric
               )
    end

    test "era component" do
      assert {:ok, "Mar 15, 2025 AD"} =
               Intl.DateTimeFormat.format(~D[2025-03-15],
                 locale: :en,
                 era: :short,
                 year: :numeric,
                 month: :short,
                 day: :numeric
               )
    end

    test "day period component" do
      assert {:ok, "9 in the morning"} =
               Intl.DateTimeFormat.format(~T[09:30:00],
                 locale: :en,
                 hour: :numeric,
                 day_period: :long
               )
    end

    test "hour12 false renders a 24-hour clock" do
      assert {:ok, "14:30"} =
               Intl.DateTimeFormat.format(~T[14:30:00],
                 locale: :en,
                 hour: :numeric,
                 minute: :numeric,
                 hour12: false
               )
    end

    test "hour cycle h23 with 2-digit hour" do
      assert {:ok, "09:05"} =
               Intl.DateTimeFormat.format(~T[09:05:00],
                 locale: :en,
                 hour: :"2-digit",
                 minute: :"2-digit",
                 hour_cycle: :h23
               )
    end

    test "time zone name component" do
      utc = DateTime.from_naive!(~N[2025-03-15 14:30:00], "Etc/UTC")

      assert {:ok, formatted} =
               Intl.DateTimeFormat.format(utc,
                 locale: :en,
                 year: :numeric,
                 month: :numeric,
                 day: :numeric,
                 hour: :numeric,
                 minute: :numeric,
                 time_zone_name: :short
               )

      assert String.ends_with?(formatted, "UTC")
    end
  end

  describe "format_to_parts/2" do
    test "component options decompose" do
      assert {:ok,
              [
                %{type: :month, value: "July"},
                %{type: :literal, value: " "},
                %{type: :day, value: "10"},
                %{type: :literal, value: ", "},
                %{type: :year, value: "2017"}
              ]} =
               Intl.DateTimeFormat.format_to_parts(~D[2017-07-10],
                 locale: :en,
                 year: :numeric,
                 month: :long,
                 day: :numeric
               )
    end

    test "style parts concatenate to the formatted string" do
      options = [locale: :en, date_style: :medium, time_style: :short, prefer: :ascii]
      {:ok, parts} = Intl.DateTimeFormat.format_to_parts(~N[2017-07-10 14:30:00], options)
      {:ok, string} = Intl.DateTimeFormat.format(~N[2017-07-10 14:30:00], options)

      assert Enum.map_join(parts, & &1.value) == string
    end
  end

  describe "format/2 fractional seconds" do
    test "fractional_second_digits renders and decomposes" do
      options = [
        locale: :en,
        hour: :numeric,
        minute: :numeric,
        second: :numeric,
        fractional_second_digits: 2
      ]

      assert {:ok, "9:30:12.34 AM"} = Intl.DateTimeFormat.format(~T[09:30:12.345], options)

      {:ok, parts} = Intl.DateTimeFormat.format_to_parts(~T[09:30:12.345], options)
      assert %{type: :fractional_second, value: "34"} in parts
    end
  end

  describe "format_range/3" do
    test "date range" do
      assert {:ok, _} =
               Intl.DateTimeFormat.format_range(~D[2017-07-10], ~D[2017-07-15], locale: :en)
    end
  end

  describe "format_range_to_parts/3" do
    test "range parts carry sources with a shared separator" do
      {:ok, parts} =
        Intl.DateTimeFormat.format_range_to_parts(~D[2022-04-22], ~D[2022-04-25], locale: :en)

      assert %{type: :day, value: "22", source: :start_range} in parts
      assert %{type: :day, value: "25", source: :end_range} in parts
      assert Enum.any?(parts, &(&1.type == :literal and &1.source == :shared))
    end

    test "parts concatenate to the range string" do
      {:ok, parts} =
        Intl.DateTimeFormat.format_range_to_parts(
          ~N[2026-04-08 12:00:00],
          ~N[2026-04-08 14:00:00],
          locale: :en
        )

      {:ok, string} =
        Intl.DateTimeFormat.format_range(
          ~N[2026-04-08 12:00:00],
          ~N[2026-04-08 14:00:00],
          locale: :en
        )

      assert Enum.map_join(parts, & &1.value) == string
    end
  end

  describe "format/2 numbering system" do
    test "numbering_system renders all numeric fields" do
      assert {:ok, "Mar ๑๕, ๒๐๒๕"} =
               Intl.DateTimeFormat.format(~D[2025-03-15],
                 locale: :en,
                 year: :numeric,
                 month: :short,
                 day: :numeric,
                 numbering_system: :thai
               )
    end

    test "invalid numbering system returns an error" do
      assert {:error, %Localize.UnknownNumberSystemError{}} =
               Intl.DateTimeFormat.format(~D[2025-03-15],
                 locale: :en,
                 date_style: :medium,
                 numbering_system: :bogus
               )
    end
  end
end
