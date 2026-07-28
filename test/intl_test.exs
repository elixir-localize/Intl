defmodule IntlTest do
  use ExUnit.Case
  doctest Intl

  describe "supported_values_of(:collation)" do
    test "excludes standard and search per ECMA-402" do
      {:ok, collations} = Intl.supported_values_of(:collation)

      refute "standard" in collations
      refute "search" in collations
      assert "emoji" in collations
      assert "phonebk" in collations
      assert collations == Enum.sort(collations)
    end
  end

  describe "supported_values_of(:unit)" do
    test "returns a flat sorted list, not a map of categories" do
      {:ok, units} = Intl.supported_values_of(:unit)

      assert is_list(units)
      assert Enum.all?(units, &is_binary/1)
      assert units == Enum.sort(units)
      assert units == Enum.uniq(units)
      assert "meter" in units
      assert "byte" in units
    end

    test "lists base names; prefixed forms still format" do
      {:ok, units} = Intl.supported_values_of(:unit)

      refute "kilometer" in units

      assert {:ok, _} =
               Intl.NumberFormat.format(1, locale: :en, style: :unit, unit: "kilometer")
    end

    test "every returned unit is accepted by NumberFormat" do
      {:ok, units} = Intl.supported_values_of(:unit)

      for unit <- units do
        assert {:ok, _} = Intl.NumberFormat.format(1, locale: :en, style: :unit, unit: unit)
      end
    end
  end

  describe "supported_values_of/1" do
    test "unknown key returns an error" do
      assert {:error, %ArgumentError{}} = Intl.supported_values_of(:nonsense)
    end
  end
end
