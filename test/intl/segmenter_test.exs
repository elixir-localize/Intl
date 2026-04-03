defmodule Intl.SegmenterTest do
  use ExUnit.Case
  doctest Intl.Segmenter

  describe "segment/2" do
    test "grapheme segmentation" do
      assert {:ok, ["h", "é", "l", "l", "o"]} =
               Intl.Segmenter.segment("héllo", granularity: :grapheme)
    end

    test "grapheme is the default" do
      assert {:ok, ["a", "b", "c"]} = Intl.Segmenter.segment("abc")
    end

    test "word segmentation" do
      assert {:ok, segments} = Intl.Segmenter.segment("hello world", granularity: :word)
      assert "hello" in segments
      assert "world" in segments
    end

    test "sentence segmentation" do
      assert {:ok, segments} =
               Intl.Segmenter.segment("Hello. World.", granularity: :sentence)

      assert length(segments) >= 2
    end

    test "invalid granularity returns error" do
      assert {:error, _} = Intl.Segmenter.segment("hello", granularity: :invalid)
    end
  end
end
