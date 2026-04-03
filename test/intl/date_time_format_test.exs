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

  describe "format_range/3" do
    test "date range" do
      assert {:ok, _} =
               Intl.DateTimeFormat.format_range(~D[2017-07-10], ~D[2017-07-15], locale: :en)
    end
  end
end
