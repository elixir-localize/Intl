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
end
