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

  describe "segment_with_metadata/2" do
    test "word segments carry word_like? and byte offsets" do
      assert {:ok,
              [
                %{segment: "Hi", index: 0, word_like?: true},
                %{segment: " ", index: 2, word_like?: false},
                %{segment: "there", index: 3, word_like?: true},
                %{segment: "!", index: 8, word_like?: false}
              ]} = Intl.Segmenter.segment_with_metadata("Hi there!", granularity: :word)
    end

    test "trim removes whitespace segments but keeps original offsets" do
      assert {:ok,
              [
                %{segment: "Hi", index: 0, word_like?: true},
                %{segment: "there", index: 3, word_like?: true},
                %{segment: "!", index: 8, word_like?: false}
              ]} =
               Intl.Segmenter.segment_with_metadata("Hi there!",
                 granularity: :word,
                 trim: true
               )
    end

    test "word_like? is nil outside word granularity" do
      {:ok, graphemes} = Intl.Segmenter.segment_with_metadata("hé", granularity: :grapheme)
      assert Enum.all?(graphemes, &is_nil(&1.word_like?))

      {:ok, sentences} =
        Intl.Segmenter.segment_with_metadata("One. Two.", granularity: :sentence)

      assert Enum.all?(sentences, &is_nil(&1.word_like?))
      assert [%{index: 0}, %{index: 5}] = sentences
    end

    test "ideographs and digits are word-like" do
      {:ok, segments} = Intl.Segmenter.segment_with_metadata("世界 42", granularity: :word)

      word_like = for %{word_like?: true} = s <- segments, do: s.segment
      assert "42" in word_like
      assert Enum.any?(word_like, &String.contains?(&1, "世"))
    end
  end
end
